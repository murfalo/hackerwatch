class GiveArmor : IEffect
{
	int m_amount;
	ArmorDef@ m_def;
	bool m_replace;
	bool m_pickup;
	

	GiveArmor(UnitPtr unit, SValue& params)
	{
		m_amount = GetParamInt(unit, params, "amount");
		@m_def = LoadArmorDef(GetParamString(unit, params, "definition"));
		m_replace = GetParamBool(unit, params, "replace");
		m_pickup = GetParamBool(unit, params, "pickup", false, false);
	}
	
	void SetWeaponInformation(uint weapon) {}

	int GetAmount(float intensity)
	{
		return int(float(m_amount) * intensity);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		Player@ plr = cast<Player>(target.GetScriptBehavior());
		return plr.GiveArmor(GetAmount(intensity), m_def, m_replace);
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;
	
		Player@ plr = cast<Player>(target.GetScriptBehavior());
		
		if (plr is null)
			return false;
	
		int amt = GetAmount(intensity);
		if (amt <= 0)
			return false;

		if (!plr.CanGiveArmor(amt, m_def, m_replace))
			return false;

		return true;
	}
}