class ToggleCombustion : IEffect
{
	bool m_enable;

	ToggleCombustion(UnitPtr unit, SValue& params)
	{
		m_enable = GetParamBool(unit, params, "enable");
	}
	
	void SetWeaponInformation(uint weapon) {}
	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override { return true; }

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		auto player = cast<Player>(owner);
		

		return true;
	}
}