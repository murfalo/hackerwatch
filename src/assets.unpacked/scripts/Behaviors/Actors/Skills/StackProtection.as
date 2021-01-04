namespace Skills
{
	class StackProtectionTrigger : Modifiers::Modifier
	{
		StackProtection@ m_skill;

		StackProtectionTrigger(StackProtection@ skill)
		{
			@m_skill = skill;
		}

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, Modifiers::EffectTrigger trigger) override
		{
			if (trigger == Modifiers::EffectTrigger::CastSpell)
				m_skill.AddStack();
		}

		bool HasDamageTakenMul() override { return true; }
		float DamageTakenMul(PlayerBase@ player, DamageInfo &di) override
		{
			if (m_skill.m_count > 0)
			{
				m_skill.TakeStack();
				m_skill.m_timerC = m_skill.m_timer;
				return m_skill.m_mul;
			}

			return 1.0f;
		}
	}

	class StackProtection : StackSkill
	{
		array<Modifiers::Modifier@> m_modifiers;

		float m_mul;

		StackProtection(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_mul = GetParamFloat(unit, params, "dmg-taken-mul");

			m_modifiers.insertLast(StackProtectionTrigger(this));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
	}
}
