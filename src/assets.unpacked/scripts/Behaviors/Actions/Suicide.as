class Suicide : IAction, IEffect
{
	uint m_weaponInfo;
	bool m_noLoot;
	bool m_noGore;

	Suicide(UnitPtr unit, SValue& params)
	{
		m_noLoot = GetParamBool(unit, params, "no-loot", false, false);
		m_noGore = GetParamBool(unit, params, "no-gore", false, false);
	}
	
	bool NeedNetParams() { return false; }
	void SetWeaponInformation(uint weapon) 
	{
		m_weaponInfo = weapon;
	}
	
	void KillSelf(Actor@ owner)
	{
		if (m_noLoot || m_noGore)
		{
			auto actor = cast<CompositeActorBehavior>(owner);
			if (actor !is null)
			{
				if (m_noLoot)
					@actor.m_lootDef = null;
				if (m_noGore)
					@actor.m_gore = null;
			}
		}
	
		owner.Kill(owner, m_weaponInfo);
	}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		KillSelf(owner);
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		KillSelf(owner);
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		KillSelf(owner);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}