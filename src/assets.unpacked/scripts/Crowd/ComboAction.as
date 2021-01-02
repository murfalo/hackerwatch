namespace Crowd
{
	class ComboAction : IntValueAction
	{
		ComboAction(SValue &params)
		{
			super(params);
		}

		int GetCombo()
		{
			int maxCombo = 0;

			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255 || g_players[i].actor is null)
					continue;

				auto player = cast<PlayerBase>(g_players[i].actor);
				if (player is null)
					continue;

				if (player.m_comboCount > maxCombo)
					maxCombo = player.m_comboCount;
			}

			return maxCombo;
		}

		float GetDelta() override
		{
			int combo = GetCombo();

			if (combo <= ThresholdNegative())
				return AmountNegative();
			else if (combo >= ThresholdPositive())
				return AmountPositive();
			else
				return AmountNeutral();
		}

		float GetDebugValue() override
		{
			return GetCombo();
		}
	}
}
