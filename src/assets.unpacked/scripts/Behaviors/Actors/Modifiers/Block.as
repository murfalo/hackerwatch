namespace Modifiers
{
	class Block : Modifier
	{
		float m_chance;
		ivec2 m_amount;
		uint m_timeout;
		uint64 m_timeoutLastFired;

		Block() { }
		Block(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", false, 1.0);
			int physical = GetParamInt(unit, params, "physical", false, 0);
			int magical = GetParamInt(unit, params, "magical", false, 0);
			m_timeout = GetParamInt(unit, params, "timeout", false);
			m_amount = ivec2(physical, magical);
		}

		Modifier@ Instance() override
		{
			auto ret = Block();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamageBlock() override { return true; }
		ivec2 DamageBlock(PlayerBase@ player, Actor@ enemy) override
		{
			if (randf() > m_chance)
				return ivec2();
		
			if (m_timeout > 0)
			{
				uint64 tmNow = g_gameMode.m_gameTime;
				if (m_timeoutLastFired > 0 && (m_timeoutLastFired + m_timeout) > tmNow)
					return ivec2();
				
				m_timeoutLastFired = tmNow;
			}
		
			return m_amount;
		}
	}
}