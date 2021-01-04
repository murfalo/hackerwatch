namespace Upgrades
{
	class BuildingUpgradeStep : UpgradeStep
	{
		int m_buildingLevel;

		BuildingUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			m_buildingLevel = GetParamInt(UnitPtr(), params, "building-level");
		}

		bool BuyNow(PlayerRecord@ record) override
		{
			if (!UpgradeBulding())
				return false;

			//TODO: Is this ok for netsync?
			if (Network::IsServer())
			{
				auto gm = cast<Town>(g_gameMode);
				if (gm !is null)
				{
					if (m_upgrade.m_id != "townhall")
					{
						gm.m_shopMenu.m_upgradedBuilding = true;
						gm.m_upgradedBuildingName = m_upgrade.m_id;
					}
				}
			}

			return true;
		}

		void PayForUpgrade(PlayerRecord@ record) override
		{
			UpgradeStep::PayForUpgrade(record);

			if (m_upgrade.m_id == "townhall")
			{
				// Need to do this here because scripts abort on ChangeLevel
				Stats::Add("buildings-purchased", 1, GetLocalPlayerRecord());

				// Save town
				auto gm = cast<Campaign>(g_gameMode);
				if (gm !is null)
					gm.SaveLocalTown();

				// Change level
				ChangeLevel(GetCurrentLevelFilename());
			}
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			auto gm = cast<Town>(g_gameMode);
			if (gm is null)
				return false;

			TownBuilding@ building = gm.m_townLocal.GetBuilding(m_upgrade.m_id);

			if (building is null)
			{
				PrintError("Building '" + m_upgrade.m_id + "' was not found");
				return false;
			}

			return building.m_level >= m_buildingLevel;
		}

		bool UpgradeBulding()
		{
			//TODO: What do in multiplayer? Only allow host to purchase town upgrades for their own town?
			auto gm = cast<Town>(g_gameMode);
			if (gm is null)
				return false;

			TownBuilding@ building = gm.m_townLocal.GetBuilding(m_upgrade.m_id);

			if (building is null)
			{
				PrintError("Building '" + m_upgrade.m_id + "' was not found");
				return false;
			}

			if (building.m_level >= m_buildingLevel)
			{
				PrintError("Building is already level " + building.m_level + ", no need to upgrade it to level " + m_buildingLevel + "!");
				return false;
			}

			print("Upgrading building \"" + m_name + "\" to level " + m_buildingLevel);

			building.Upgrade(m_buildingLevel);
			return true;
		}
	}
}
