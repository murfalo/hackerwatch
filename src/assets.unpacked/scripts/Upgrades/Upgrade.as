namespace Upgrades
{
	class Upgrade
	{
		string m_id;
		uint m_idHash;

		ScriptSprite@ m_sprite;

		bool m_small;

		array<UpgradeStep@> m_steps;

		Upgrade(SValue& params)
		{
			m_id = GetParamString(UnitPtr(), params, "id");
			m_idHash = HashString(m_id);

			auto arrSprite = GetParamArray(UnitPtr(), params, "icon", false);
			if (arrSprite !is null)
				@m_sprite = ScriptSprite(arrSprite);

			m_small = GetParamBool(UnitPtr(), params, "small", false);

			auto arrSteps = GetParamArray(UnitPtr(), params, "steps", false);
			if (arrSteps !is null)
			{
				for (uint i = 0; i < arrSteps.length(); i++)
				{
					int level = 1;
					if (m_steps.length() > 0)
						level = m_steps[m_steps.length() - 1].m_level + 1;

					auto newStep = LoadStep(arrSteps[i], level);
					if (newStep !is null)
						m_steps.insertLast(newStep);
				}
			}
		}

		bool ShouldRemember() { return true; }
		bool ShouldBeVisible() { return true; }

		bool IsOwned(PlayerRecord@ record)
		{
			if (m_steps.length() == 0)
				return false;

			return m_steps[0].IsOwned(record);
		}

		UpgradeStep@ LoadStep(SValue@ params, int level)
		{
			return null;
		}

		UpgradeStep@ GetStep(int level)
		{
			for (uint i = 0; i < m_steps.length(); i++)
			{
				if (m_steps[i].m_level == level)
					return m_steps[i];
			}
			return null;
		}

		int GetNextLevel(PlayerRecord@ record)
		{
			for (uint i = 0; i < m_steps.length(); i++)
			{
				if (!m_steps[i].IsOwned(record))
					return m_steps[i].m_level;
			}
			return 0;
		}

		UpgradeStep@ GetNextStep(PlayerRecord@ record)
		{
			for (uint i = 0; i < m_steps.length(); i++)
			{
				if (!m_steps[i].IsOwned(record))
					return m_steps[i];
			}
			return null;
		}
	}
}
