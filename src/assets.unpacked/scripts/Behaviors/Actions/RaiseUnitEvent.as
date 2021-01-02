class RaiseUnitEvent : IAction
{
	UnitPtr m_unit;
	string m_name;

	RaiseUnitEvent(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		m_name = GetParamString(unit, params, "name");
	}

	void Update(int dt, int cooldown) {}
	void SetWeaponInformation(uint weapon) {}
	bool NeedNetParams() { return false; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		SValueBuilder sv;
		sv.PushString(m_name);
		m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		SValueBuilder sv;
		sv.PushString(m_name);
		m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		return true;
	}
}
