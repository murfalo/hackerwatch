namespace Modifiers
{
	class StatueManaDamage : StackedModifier
	{
		float m_manaMul;

		StatueManaDamage() {}
		StatueManaDamage(UnitPtr unit, SValue& params)
		{
			m_manaMul = GetParamFloat(unit, params, "mana-mul", false, 0.2f);
		}

		Modifier@ Instance() override
		{
			auto ret = StatueManaDamage();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasSpellDamageAdd() override { return true; }
		ivec2 SpellDamageAdd(PlayerBase@ player, Actor@ enemy, DamageInfo@ di) override
		{
			if (di is null || di.Weapon <= 1)
				return ivec2();

			if (di.Weapon - 1 >= player.m_skills.length())
			{
				PrintError("Invalid weapon index for statue mana damage!");
				return ivec2();
			}

			auto skill = cast<Skills::ActiveSkill>(player.m_skills[di.Weapon - 1]);
			if (skill is null)
				return ivec2();

			auto modifiers = player.m_record.GetModifiers();
			float manaCostMul = modifiers.SpellCostMul(player);

			int bonusDamage = int((m_manaMul * m_stackCount) * (skill.m_costMana * manaCostMul));
			return ivec2(0, bonusDamage);
		}
	}
}
