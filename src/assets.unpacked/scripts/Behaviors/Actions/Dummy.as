class Dummy : IAction
{
	Dummy(UnitPtr unit, SValue& params)
	{
	}

	void SetWeaponInformation(uint weapon) {}
	bool NeedNetParams() { return false; }
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
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