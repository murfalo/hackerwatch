class Decimate : IEffect
{
	float m_hp;
	float m_hpMax;
	float m_mana;
	float m_manaMax;
	uint m_weaponInfo;
	
	Decimate(UnitPtr unit, SValue& params)
	{
		m_hp = GetParamFloat(unit, params, "amount", false, 0.0f);
		m_hpMax = GetParamFloat(unit, params, "amount-max", false, 0.0f);
		m_mana = GetParamFloat(unit, params, "mana", false, 0.0f);
		m_manaMax = GetParamFloat(unit, params, "mana-max", false, 0.0f);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		target.TriggerCallbacks(UnitEventType::Damaged);
	
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		if (!FilterHuskDamage(owner, target, husk))
			return false;
		
		IDamageTaker@ dmgTaker = cast<IDamageTaker>(target.GetScriptBehavior());
		dmgTaker.Decimate(DecimateInfo(owner, m_hp * intensity, m_hpMax * intensity, m_mana * intensity, m_manaMax * intensity, m_weaponInfo), pos, dir);
		
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;
	
		IDamageTaker@ dmgTaker = cast<IDamageTaker>(target.GetScriptBehavior());
		
		if (dmgTaker is null)
			return false;

		return true;
	}
}