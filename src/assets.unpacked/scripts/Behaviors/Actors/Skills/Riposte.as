namespace Skills
{
	class RiposteTrigger : Modifiers::Modifier
	{
		Riposte@ m_skill;

		int m_timeC;

		RiposteTrigger(Riposte@ skill)
		{
			@m_skill = skill;
		}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt)  override
		{
			if (m_timeC > 0)
				m_timeC -= dt;
		}

		bool HasDamageBlockMul() override { return true; }
		vec2 DamageBlockMul(PlayerBase@ player, Actor@ enemy) override
		{
			if (m_timeC <= 0)
				return vec2(1, 1);

			auto skillTrident = cast<CooldownStackMeleeSwing>(player.m_skills[0]);
			if (skillTrident !is null)
				skillTrident.AddStack();

			m_timeC = 0;

			if (m_skill.m_fxBlock !is null)
				PlayEffect(m_skill.m_fxBlock, player.m_unit.GetPosition());

			return vec2(m_skill.m_block, m_skill.m_block);
		}

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, Modifiers::EffectTrigger trigger) override
		{
			if (trigger != Modifiers::EffectTrigger::Attack)
				return;

			m_timeC = m_skill.m_time;
		}
	}

	class Riposte : Skill
	{
		array<Modifiers::Modifier@> m_modifiers;

		UnitScene@ m_fxBlock;

		float m_block;
		int m_time;

		Riposte(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_block = GetParamFloat(unit, params, "block");
			m_time = GetParamInt(unit, params, "time", false, 200);

			@m_fxBlock = Resources::GetEffect(GetParamString(unit, params, "block-fx", false));

			m_modifiers.insertLast(RiposteTrigger(this));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override { return m_modifiers; }
	}
}
