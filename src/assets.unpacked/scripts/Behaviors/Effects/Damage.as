class Damage : IEffect
{
	int m_physicalDmg;
	int m_magicalDmg;
	bool m_canKill;
	bool m_melee;
	bool m_trueStrike;
	uint m_weaponInfo;
	vec2 m_armorMul;
	CleaveInfo@ m_cleave;

	Damage(UnitPtr unit, SValue& params)
	{
		int dmg = GetParamInt(unit, params, "dmg", false, 0);
	
		m_physicalDmg = GetParamInt(unit, params, "physical", false, dmg);
		m_magicalDmg = GetParamInt(unit, params, "magical", false, 0);
		
		m_armorMul = vec2(
			GetParamFloat(unit, params, "armor-mul", false, 1), 
			GetParamFloat(unit, params, "resistance-mul", false, 1));
		
		m_canKill = GetParamBool(unit, params, "can-kill", false, true);
		m_melee = GetParamBool(unit, params, "melee", false, false);
		m_trueStrike = GetParamBool(unit, params, "true-strike", false, false);
		
		@m_cleave = LoadCleave(params);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}

	int DoDamage(IDamageTaker@ target, DamageInfo di, vec2 pos, vec2 dir)
	{
		return target.Damage(di, pos, dir);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		target.TriggerCallbacks(UnitEventType::Damaged);
	
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		if (!FilterHuskDamage(owner, target, husk))
			return false;
	
		float dmgMul = intensity;
		IDamageTaker@ dmgTaker = cast<IDamageTaker>(target.GetScriptBehavior());
		
		auto dmgInfo = DamageInfo(owner, damage_round(float(m_physicalDmg) * dmgMul), damage_round(float(m_magicalDmg) * dmgMul), m_melee, m_canKill, m_weaponInfo);
		dmgInfo.ArmorMul = m_armorMul;
		dmgInfo.TrueStrike = m_trueStrike;
		@dmgInfo.Cleave = m_cleave;

		DoDamage(dmgTaker, dmgInfo, pos, dir);
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

class BogusDamage : Damage
{
	BogusDamage(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!Damage::CanApply(owner, target, pos, dir, intensity))
			return false;
	
		if (cast<Actor>(target.GetScriptBehavior()) !is null)
			return false;

		return true;
	}
}