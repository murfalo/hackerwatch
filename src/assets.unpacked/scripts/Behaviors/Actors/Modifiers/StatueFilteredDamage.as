namespace Modifiers
{
	class StatueFilteredDamage : StackedModifier
	{
		float m_mulAdd;

		uint64 m_tags;

		StatueFilteredDamage() {}
		StatueFilteredDamage(UnitPtr unit, SValue& params)
		{
			m_mulAdd = GetParamFloat(unit, params, "mul-add", false);

			m_tags = GetBuffTags(params);
		}

		Modifier@ Instance() override
		{
			auto ret = StatueFilteredDamage();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamageMul() override { return true; }
		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override
		{
			vec2 ret(1, 1);

			auto eb = cast<CompositeActorBehavior>(enemy);
			if (eb !is null && eb.m_buffs.HasTags(m_tags))
				ret *= 1.0f + m_mulAdd * m_stackCount;

			return ret;
		}
	}
}

bool HasDamageMul() { return false; }
bool DynamicDamageMul() { return HasDamageMul(); }
