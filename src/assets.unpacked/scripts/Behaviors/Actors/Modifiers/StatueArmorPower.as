namespace Modifiers
{
	class StatueArmorPower : StackedModifier
	{
		vec2 m_mul;

		StatueArmorPower() {}
		StatueArmorPower(UnitPtr unit, SValue &params)
		{
			m_mul = vec2(
				GetParamFloat(unit, params, "mul", false, 0.0f),
				GetParamFloat(unit, params, "mul-resistance", false, 0.0f)
			);
		}

		Modifier@ Instance() override
		{
			auto ret = StatueArmorPower();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamagePower() override { return true; }
		ivec2 DamagePower(PlayerBase@ player, Actor@ enemy) override
		{
			vec2 armor = player.m_currentArmor;
			armor += Tweak::NewGamePlusNegArmor(g_ngp);

			ivec2 ret;

			if (armor.x > 0)
				ret.x += int(armor.x * m_mul.x) * m_stackCount;

			if (armor.y > 0)
				ret.y += int(armor.y * m_mul.y) * m_stackCount;

			return ret;
		}
	}
}
