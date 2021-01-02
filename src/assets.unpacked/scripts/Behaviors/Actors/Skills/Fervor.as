namespace Skills
{
	class FervorTrigger : Modifiers::Modifier
	{
		Fervor@ m_skill;
	
		FervorTrigger(Fervor@ skill)
		{
			@m_skill = skill;
		}	

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, Modifiers::EffectTrigger trigger) override
		{ 
			if (trigger == Modifiers::EffectTrigger::Hit)
				m_skill.AddStack();
		}
		
		bool HasEvasion() override { return m_skill.m_stackEvasion > 0.0f; }
		bool Evasion(PlayerBase@ player, Actor@ enemy) override
		{
			if (m_skill.m_stackEvasion == 0.0f)
				return false;
			return roll_chance(player, m_skill.m_stackEvasion * m_skill.m_count);
		}
	}

	class Fervor : StackSkill
	{
		array<Modifiers::Modifier@> m_modifiers;
		
		float m_stackSpeed;
		float m_stackEvasion;
		
	
		Fervor(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			
			m_stackSpeed = GetParamFloat(unit, params, "stack-speed");
			m_stackEvasion = GetParamFloat(unit, params, "stack-evasion", false, 0.0f);
			
			m_modifiers.insertLast(FervorTrigger(this));
		}
		
		void RefreshCount() override
		{
			cast<ActiveSkill>(cast<PlayerBase>(m_owner).m_skills[0]).m_timeScale = (1.0f + m_stackSpeed * m_count);

			StackSkill::RefreshCount();
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
	}
}
