namespace Upgrades
{
	class UpgradeStep
	{
		Upgrade@ m_upgrade;

		pint m_costGold;
		pint m_costOre;
		pint m_costSkillPoints;

		string m_name;
		string m_description;
		ScriptSprite@ m_sprite;

		int m_level;

		int m_restrictShopLevelMin;
		int m_restrictShopLevelMax;
		int m_restrictPlayerLevelMin;
		int m_restrictPlayerTitleMin;
		string m_restrictFlag;

		UpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			@m_upgrade = upgrade;

			m_costGold = GetParamInt(UnitPtr(), params, "cost-gold", false);
			m_costOre = GetParamInt(UnitPtr(), params, "cost-ore", false);
			m_costSkillPoints = GetParamInt(UnitPtr(), params, "cost-skillpoints", false);

			m_name = GetParamString(UnitPtr(), params, "name", false);
			m_description = GetParamString(UnitPtr(), params, "desc", false);

			auto arrSprite = GetParamArray(UnitPtr(), params, "icon", false);
			if (arrSprite !is null)
				@m_sprite = ScriptSprite(arrSprite);

			m_level = GetParamInt(UnitPtr(), params, "level", false, level);

			m_restrictShopLevelMin = GetParamInt(UnitPtr(), params, "restrict-shop-level-min", false, -1);
			m_restrictShopLevelMax = GetParamInt(UnitPtr(), params, "restrict-shop-level-max", false, -1);
			m_restrictPlayerLevelMin = GetParamInt(UnitPtr(), params, "restrict-player-level-min", false, -1);
			m_restrictPlayerTitleMin = GetParamInt(UnitPtr(), params, "restrict-player-title-min", false, -1);
			m_restrictFlag = GetParamString(UnitPtr(), params, "restrict-flag", false, "");
		}

		string GetButtonText()
		{
			return Resources::GetString(m_name);
		}

		string GetTooltipTitle()
		{
			return Resources::GetString(m_name);
		}

		string GetTooltipDescription()
		{
			return Resources::GetString(m_description);
		}

		ScriptSprite@ GetSprite()
		{
			if (m_sprite is null)
				return m_upgrade.m_sprite;
			return m_sprite;
		}

		void DrawShopIcon(Widget@ widget, SpriteBatch& sb, vec2 pos, vec2 size, vec4 color)
		{
		}

		bool IsOwned(PlayerRecord@ record)
		{
			for (uint i = 0; i < record.upgrades.length(); i++)
			{
				auto ownedUpgrade = record.upgrades[i];
				if (ownedUpgrade.m_idHash == m_upgrade.m_idHash && ownedUpgrade.m_level >= m_level)
					return true;
			}
			return false;
		}

		bool IsRestricted()
		{
			return false;
		}

		string GetRestrictionReason()
		{
			return "";
		}

		bool CanAfford(PlayerRecord@ record)
		{
			float payScale = PayScale(record);

			int costGold = int(int(m_costGold) * payScale);
			int costOre = int(int(m_costOre) * payScale);

			if (!Currency::CanAfford(record, costGold, costOre))
				return false;

			if (m_costSkillPoints > 0 && m_costSkillPoints > record.GetAvailableSkillpoints())
				return false;

			return true;
		}

		float PayScale(PlayerRecord@ record)
		{
			return 1.0f;
		}

		void PayForUpgrade(PlayerRecord@ record)
		{
			if (!CanAfford(record))
			{
				PrintError("Tried paying for upgrade while we can not afford the upgrade. (\"" + m_upgrade.m_id + "\" level " + m_level + ")");
				return;
			}

			float payScale = PayScale(record);

			int costGold = int(int(m_costGold) * payScale);
			int costOre = int(int(m_costOre) * payScale);

			Currency::Spend(record, costGold, costOre);

			Stats::Add("spent-gold", costGold, record);
			Stats::Add("spent-ore", costOre, record);
			Stats::Add("spent-skillpoints", m_costSkillPoints, record);

			print("purchasing upgrade");

			if (record.IsLocalPlayer() && record.statistics !is null && record.statisticsSession !is null)
			{
				auto spent_gold = record.statistics.GetStat("spent-gold");
				auto stored_gold = record.statistics.GetStat("gold-stored");
				auto spent_ore = record.statistics.GetStat("spent-ore");
				auto stored_ore = record.statistics.GetStat("ores-stored");
				auto available_skill_points = record.GetAvailableSkillpoints();
				auto spent_skill_points = record.statistics.GetStat("spent-skillpoints");

				if (spent_skill_points !is null)
				{
					print("reducing skill points spent");
					auto diff = spent_skill_points.ValueInt() - available_skill_points;
					if (diff > 0)
						Stats::Add("spent-skillpoints", -diff, record);
				}

				if (spent_gold !is null && stored_gold !is null)
				{
					print("reducing gold spent");
					auto diff = spent_gold.ValueInt() - stored_gold.ValueInt();
					if (diff > 0)
						Stats::Add("spent-gold", -diff, record);
				}

				if (spent_ore !is null && stored_ore !is null)
				{
					print("reducing ore spent");
					auto diff = spent_ore.ValueInt() - stored_ore.ValueInt();
					if (diff > 0)
						Stats::Add("spent-ore", -diff, record);
				}

				auto session_gold = record.statisticsSession.GetStat("spent-gold");
				auto session_ore = record.statisticsSession.GetStat("spent-ore");
				auto session_skillpoints = record.statisticsSession.GetStat("spent-skillpoints");

				if (session_gold !is null && session_gold.ValueInt() < 0)
					session_gold.Add(-session_gold.ValueInt(), false);

				if (session_ore !is null && session_ore.ValueInt() < 0)
					session_ore.Add(-session_ore.ValueInt(), false);

				if (session_skillpoints !is null && session_skillpoints.ValueInt() < 0)
					session_skillpoints.Add(-session_skillpoints.ValueInt(), false);
			}
		}

		bool BuyNow(PlayerRecord@ record)
		{
			return ApplyNow(record);
		}

		bool ApplyNow(PlayerRecord@ record)
		{
			return false;
		}
	}
}
