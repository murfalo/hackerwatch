namespace Skills
{
	class StackEvasionTrigger : Modifiers::Modifier
	{
		StackEvasion@ m_skill;

		StackEvasionTrigger(StackEvasion@ skill)
		{
			@m_skill = skill;
		}

		bool HasEvasion() override { return true; }
		float EvadeChance() override { return m_skill.m_chance; }
		bool Evasion(PlayerBase@ player, Actor@ enemy) override
		{
			if (randf() < m_skill.m_chance)
				return true;

			if (m_skill.TakeStack())
				return true;

			return false;
		}
	}

	class StackEvasion : StackSkill
	{
		array<Modifiers::Modifier@> m_modifiers;

		int m_rechargeTime;
		int m_rechargeTimeC;

		float m_chance;

		StackEvasion(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_rechargeTime = GetParamInt(unit, params, "recharge", true, 1000);
			m_rechargeTimeC = m_rechargeTime;

			m_chance = GetParamFloat(unit, params, "chance", false, 1.0f);

			m_modifiers.insertLast(StackEvasionTrigger(this));

			RefreshCount();
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
		
		bool TakeStack(int num = 1) override
		{
			if (m_maxCount == m_count)
				m_rechargeTimeC = m_rechargeTime;
		
			return StackSkill::TakeStack(num);
		}
		
		void Update(int dt, bool walking) override
		{
			m_rechargeTimeC -= dt;
			while (m_rechargeTimeC <= 0)
			{
				AddStack();
				m_rechargeTimeC += m_rechargeTime;
			}
			
			StackSkill::Update(dt, walking);
		}

		int GetBuffIconDuration() override
		{
			if (m_destroyed)
				return 0;

			if (m_count == m_maxCount)
				return m_rechargeTime;
			return max(1, m_rechargeTime - m_rechargeTimeC);
		}

		int GetBuffIconMaxDuration() override
		{
			return m_rechargeTime;
		}

		int GetBuffIconCount() override
		{
			if (m_destroyed)
				return 0;

			if (m_count == 0)
				return -1;
			else
				return m_count;
		}
	}
}
