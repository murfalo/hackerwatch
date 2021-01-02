namespace Crowd
{
	class TimeAction : CrowdAction
	{
		float m_amount;
		float m_startAmount;
		float m_minAmount;
		float m_maxAmount;

		int m_timeDivider;

		int m_delay;
		int m_delayC;

		uint64 m_startTime;

		TimeAction(SValue &params)
		{
			super(params);

			m_amount = GetParamFloat(UnitPtr(), params, "amount", false, 1.0f);
			m_startAmount = GetParamFloat(UnitPtr(), params, "start-amount", false, 1.0f);
			m_minAmount = GetParamFloat(UnitPtr(), params, "min-amount", false, -5.0f);
			m_maxAmount = GetParamFloat(UnitPtr(), params, "max-amount", false, 5.0f);

			m_timeDivider = GetParamInt(UnitPtr(), params, "time-divider", false, 10000);

			m_delayC = m_delay = GetParamInt(UnitPtr(), params, "delay", false, 2);
		}

		void Clear() override
		{
			if (m_delayC > 0)
			{
				if (--m_delayC == 0)
				{
					auto gm = cast<Survival>(g_gameMode);
					if (gm !is null)
						m_startTime = gm.m_crowdTimeElapsed;
				}
			}
		}

		void TimeReset() override
		{
			m_delayC = m_delay;
		}

		float GetDelta() override
		{
			auto gm = cast<Survival>(g_gameMode);
			if (gm is null)
				return 0.0f;

			if (m_delayC > 0)
				return m_startAmount;

			uint64 elapsedTime = gm.m_crowdTimeElapsed - m_startTime;
			float delta = m_startAmount + m_amount * (elapsedTime / float(m_timeDivider));
			return clamp(delta, m_minAmount, m_maxAmount);
		}
	}
}
