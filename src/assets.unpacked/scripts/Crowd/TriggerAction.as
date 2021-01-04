namespace Crowd
{
	class TriggerAction : IntValueAction
	{
		pint m_currentCount;

		bool m_useAverage;

		TriggerAction(SValue &params)
		{
			super(params);

			m_useAverage = GetParamBool(UnitPtr(), params, "use-average", false, true);
		}

		void Trigger(int delta = 1)
		{
			m_currentCount += delta;
		}

		void Clear() override
		{
			m_currentCount = 0;
		}

		int GetTestValue()
		{
			if (!m_useAverage)
				return m_currentCount;

			int numPlayers = 0;
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer != 255)
					numPlayers++;
			}
			return int(float(m_currentCount) / float(numPlayers));
		}

		float GetDelta() override
		{
			int value = GetTestValue();

			if (value <= ThresholdNegative())
				return AmountNegative();
			else if (value >= ThresholdPositive())
				return AmountPositive();
			return AmountNeutral();
		}

		float GetDebugValue() override
		{
			return float(GetTestValue());
		}
	}
}
