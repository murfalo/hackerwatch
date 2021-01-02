class ShootBolt : IEffect
{
	UnitScene@ m_fx;
	int m_height;
	int m_spread;
	array<IEffect@>@ m_effects;

	ShootBolt(UnitPtr unit, SValue& params)
	{
		@m_fx = Resources::GetEffect(GetParamString(unit, params, "fx", false));
		m_height = GetParamInt(unit, params, "height", false, 0);
		m_spread = GetParamInt(unit, params, "spread", false, 0);
		@m_effects = LoadEffects(unit, params);
	}

	void SetWeaponInformation(uint weapon) 
	{
		PropagateWeaponInformation(m_effects, weapon);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!target.IsValid())
			return false;
	
		vec2 shooterPos = xy(owner.m_unit.GetPosition());
		auto diff = pos - shooterPos;		
		
		ApplyEffects(m_effects, owner, target, pos, normalize(diff), intensity, husk);
		DrawLightningBolt(m_fx, shooterPos + vec2(randi(m_spread) - m_spread / 2, randi(m_spread) - m_spread / 2 - m_height), pos + vec2(randi(8) - 4, randi(8) - 4));
		
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}