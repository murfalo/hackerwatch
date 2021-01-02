class SetFlag : IEffect, IAction
{
	string m_flag;
	bool m_value;
	bool m_persistent;

	SetFlag(UnitPtr unit, SValue& params)
	{
		m_flag = GetParamString(unit, params, "flag");
		m_value = GetParamBool(unit, params, "value");
		m_persistent = GetParamBool(unit, params, "persistent", false);
	}
	
	void SetWeaponInformation(uint weapon) {}
	bool NeedNetParams() { return false; }
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		Do();
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		Do();
		return true;
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		Do();
		(Network::Message("SyncFlag") << m_flag << m_value << m_persistent).SendToAll();
		
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
	
	void Do()
	{
		if (!m_value)
			g_flags.Delete(m_flag);
		else
			g_flags.Set(m_flag, m_persistent ? FlagState::Run : FlagState::Level);
	}
	
	
	void Update(int dt, int cooldown)
	{
	}
}