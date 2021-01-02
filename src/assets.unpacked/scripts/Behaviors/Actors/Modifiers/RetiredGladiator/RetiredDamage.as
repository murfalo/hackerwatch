namespace Modifiers
{
	class RetiredDamage : StackedModifier
	{
		ivec2 m_power;

		RetiredDamage()
		{
		}

		RetiredDamage(UnitPtr unit, SValue& params)
		{
			m_power = ivec2(
				GetParamInt(unit, params, "attack-power", false, 0),
				GetParamInt(unit, params, "spell-power", false, 0));
		}

		Modifier@ Instance() override
		{
			auto ret = RetiredDamage();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamagePower() override { return true; }
		ivec2 DamagePower(PlayerBase@ player, Actor@ enemy) override { return m_power * m_stackCount; }
	}
}
