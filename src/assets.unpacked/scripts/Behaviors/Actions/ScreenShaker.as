class ScreenShaker : IAction
{
	int m_time;
	float m_amount;
	float m_range;

	ScreenShaker(UnitPtr unit, SValue& params)
	{
		m_time = GetParamInt(unit, params, "time");
		m_amount = GetParamFloat(unit, params, "amount", false, 1.0);
		m_range = GetParamFloat(unit, params, "range", false, -1.0);
	}

	void Update(int dt, int cooldown) {}
	void SetWeaponInformation(uint weapon) {}
	bool NeedNetParams() { return false; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		gm.ShakeScreen(m_time, m_amount, owner.m_unit.GetPosition(), m_range);
		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		gm.ShakeScreen(m_time, m_amount, owner.m_unit.GetPosition(), m_range);
		return true;
	}
}
