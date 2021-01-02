class EffectFilter : IEffect
{
	array<IEffect@>@ m_effects;

	float m_selfDmg;
	float m_teamDmg;

	bool m_negate;

	EffectFilter(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);

		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);

		m_negate = GetParamBool(unit, params, "negate", false);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_effects, weapon);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		ApplyEffects(m_effects, owner, target, pos, dir, intensity, husk, m_selfDmg, m_teamDmg);

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		bool ret = true;

		if (m_negate)
			return !ret;
		return ret;
	}
}
