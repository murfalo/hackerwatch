namespace Upgrades
{
	class RecordUpgradeStep : UpgradeStep
	{
		int m_skillIndex;
		int m_skillLevel;

		RecordUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			m_skillIndex = GetParamInt(UnitPtr(), params, "skill-index", false, -1);
			if (m_skillIndex != -1)
				m_skillLevel = GetParamInt(UnitPtr(), params, "skill-level");
		}

		void DrawShopIcon(Widget@ widget, SpriteBatch& sb, vec2 pos, vec2 size, vec4 color) override
		{
			auto player = GetLocalPlayer();
			if (player is null)
				return;

			if (m_skillIndex != -1)
				player.m_skills[m_skillIndex].m_icon.Draw(sb, pos, g_menuTime);
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			if (m_skillIndex != -1)
			{
				record.levelSkills[m_skillIndex] = m_skillLevel;

				auto player = cast<PlayerBase>(record.actor);
				if (player !is null)
					player.RefreshSkills();
			}

			return true;
		}
	}
}
