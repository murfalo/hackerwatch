namespace Skills
{
	class PlannedAttackModifier : Modifiers::Modifier
	{
		PlannedAttack@ m_skill;

		PlannedAttackModifier(PlannedAttack@ skill)
		{
			@m_skill = skill;
		}

		bool HasCrit() override { return true; }
		int Crit(PlayerBase@ player, Actor@ enemy, bool spell) override
		{
%if HARDCORE
			if (!spell && m_skill.TakeStack())
				return 1;
%else
			auto tridentSkill = cast<ActiveSkill>(player.m_skills[0]);
			if (tridentSkill is null || !tridentSkill.m_cooldownOverride)
				return 0;

			tridentSkill.m_cooldownOverride = false;

			if (m_skill.TakeStack())
				return 1;
%endif

			return 0;
		}
	}

	class PlannedAttack : StackSkill
	{
		array<Modifiers::Modifier@> m_modifiers;

		PlannedAttack(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_timerC = m_timer;

			m_modifiers.insertLast(PlannedAttackModifier(this));
		}

		void Update(int dt, bool walking) override
		{
			Skill::Update(dt, walking);

			if (m_count < m_maxCount)
			{
				m_timerC -= dt;
				if (m_timerC <= 0)
				{
					m_timerC = m_timer;
					AddStack();
				}
			}
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}

		int GetBuffIconDuration() override
		{
			if (m_destroyed)
				return 0;

			int ret = m_timer - m_timerC;
			if (ret <= 0)
				return m_timer;

			return ret;
		}

		int GetBuffIconCount() override
		{
			if (m_destroyed)
				return 0;

			if (m_count == 0)
				return -1;
			return m_count;
		}
	}
}
