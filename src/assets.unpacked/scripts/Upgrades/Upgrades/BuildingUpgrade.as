namespace Upgrades
{
	class BuildingUpgrade : Upgrade
	{
		BuildingUpgrade(SValue& params)
		{
			super(params);
		}

		bool ShouldRemember() override { return false; }

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return BuildingUpgradeStep(this, params, level);
		}

		UpgradeStep@ GetNextStep(PlayerRecord@ record) override
		{
			auto gm = cast<Town>(g_gameMode);
			if (gm is null || gm.m_townLocal is null)
				return null;

			auto building = gm.m_townLocal.GetBuilding(m_id);
			if (building is null)
			{
				PrintError("Building \"" + m_id + "\" doesn't exist!");
				return null;
			}

			for (uint i = 0; i < m_steps.length(); i++)
			{
				auto step = cast<BuildingUpgradeStep>(m_steps[i]);
				if (step.m_buildingLevel > building.m_level)
					return step;
			}

			return null;
		}
	}
}
