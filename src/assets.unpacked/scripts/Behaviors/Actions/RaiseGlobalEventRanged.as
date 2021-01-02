class RaiseGlobalEventRanged : IAction, IEffect
{
	UnitPtr m_unit;
	string m_name;
	int m_radius;

	RaiseGlobalEventRanged(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		m_name = GetParamString(unit, params, "name");
		m_radius = GetParamInt(unit, params, "radius");
	}

	void Update(int dt, int cooldown) {}
	void SetWeaponInformation(uint weapon) {}
	bool NeedNetParams() { return false; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		WorldScript::TriggerGlobalEvent(m_name, pos, m_radius);
		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		WorldScript::TriggerGlobalEvent(m_name, pos, m_radius);
		return true;
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		WorldScript::TriggerGlobalEvent(m_name, pos, m_radius);
		return true;
	}
	
	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) { return true; }
}
