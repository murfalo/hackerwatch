namespace Skills
{
	class StackDamageTrigger : Modifiers::Modifier
	{
		StackDamage@ m_skill;

		StackDamageTrigger(StackDamage@ skill)
		{
			@m_skill = skill;
		}

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, Modifiers::EffectTrigger trigger) override
		{
			if (trigger == Modifiers::EffectTrigger::Hit)
				m_skill.AddStack();
		}

		bool HasAttackDamageAdd() override { return true; }
		ivec2 AttackDamageAdd(PlayerBase@ player, Actor@ enemy, DamageInfo@ di) override
		{
			ivec2 ret;
			ret.y = m_skill.m_count * m_skill.m_magicDamage;
			return ret;
		}

		bool HasSpellDamageAdd() override { return true; }
		ivec2 SpellDamageAdd(PlayerBase@ player, Actor@ enemy, DamageInfo@ di) override
		{
			return AttackDamageAdd(player, enemy, di);
		}
	}

	class StackDamage : StackSkill
	{
		array<Modifiers::Modifier@> m_modifiers;

		int m_magicDamage;

		StackDamage(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_magicDamage = GetParamInt(unit, params, "magic-damage", false);

			m_modifiers.insertLast(StackDamageTrigger(this));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
	}
}
