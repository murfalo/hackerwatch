namespace Crowd
{
	class HealthAction : FloatValueAction
	{
		HealthAction(SValue &params)
		{
			super(params);
		}

		float GetAvgHealth()
		{
			int numPlayers = 0;
			float totalHealth = 0.0f;

			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255 || g_players[i].actor is null)
					continue;

				numPlayers++;
				totalHealth += g_players[i].hp;
			}

			if (numPlayers == 0)
				return 0.0f;

			return totalHealth / float(numPlayers);
		}

		float GetDelta() override
		{
			float avg = GetAvgHealth();

			if (avg <= ThresholdNegative())
				return AmountNegative();
			else if (avg >= ThresholdPositive())
				return AmountPositive();
			else
				return AmountNeutral();
		}

		float GetDebugValue() override
		{
			return GetAvgHealth();
		}
	}
}
