class AddCurse : IEffect
{
	int m_amount;

	AddCurse(UnitPtr unit, SValue& params)
	{
		m_amount = GetParamInt(unit, params, "amount");
	}
	
	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto plr = cast<PlayerBase>(target.GetScriptBehavior());
		if (plr is null)
			return false;
			
		plr.m_record.GiveCurse(m_amount);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		auto plr = cast<PlayerBase>(target.GetScriptBehavior());
		if (plr is null)
			return false;

		if (m_amount < 0)
			return plr.m_record.curses > 0;

		return true;
	}
}