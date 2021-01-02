namespace Modifiers
{
	class CombustionTriggerEffect : TriggerEffect
	{
		CombustionTriggerEffect(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		}

		Modifier@ Instance() override { return this; }

		void TriggerEffects(PlayerBase@ player, Actor@ enemy, EffectTrigger trigger) override
		{
			if (trigger != EffectTrigger::Hit && trigger != EffectTrigger::SpellHit)
				return;

			if (!roll_chance(player, m_chance))
				return;

			if (m_timeoutC > 0)
				return;

			m_timeoutC = m_timeout;

			if (m_counter > 0)
			{
				if (--m_counterC > 0)
					return;

				m_counterC = m_counter;
			}

			UnitPtr target;
			if (m_targetSelf)
				target = player.m_unit;
			else if (enemy !is null)
			{
				target = enemy.m_unit;
				if (!enemy.IsTargetable())
					return;
			}

			Trigger(player, target);
		}
	}
}
