class DummyHitscan : IAction
{
	array<IEffect@>@ m_effects;

	DummyHitscan(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
	}

	void SetWeaponInformation(uint weapon) 
	{
		PropagateWeaponInformation(m_effects, weapon);
	}
	
	bool NeedNetParams() { return false; }
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		ApplyEffects(m_effects, owner, target.m_unit, xy(target.m_unit.GetPosition()), dir, intensity, false);
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
	}
}