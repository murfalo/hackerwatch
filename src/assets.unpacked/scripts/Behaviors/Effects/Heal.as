class Heal : IEffect
{
	int m_heal;
	bool m_pickup;
	uint m_weaponInfo;

	Heal(UnitPtr unit, SValue& params)
	{
		m_heal = GetParamInt(unit, params, "heal");
		m_pickup = GetParamBool(unit, params, "pickup", false, false);
	}

	void SetWeaponInformation(uint weapon) 
	{
		m_weaponInfo = weapon;
	}
	
	int GetAmount(float intensity, Actor@ actor)
	{
		float ret = float(m_heal);

		ret *= intensity;

		if (m_pickup)
		{
			auto player = cast<Player>(actor);
			if (player !is null)
				ret *= player.m_record.GetModifiers().HealthGainScale(player);
				
			if (Fountain::HasEffect("amazing_pickups"))
				ret *= 5;
				
			if (Fountain::HasEffect("bad_pickups"))
				ret *= 0.5f;
		}

		return int(ret);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		Actor@ actor = cast<Actor>(target.GetScriptBehavior());
		int amount = GetAmount(intensity, actor);

		if (m_pickup)
		{
			auto player = cast<PlayerBase>(actor);
			if (player !is null)
				Stats::Add("amount-healed-pickups", amount, player.m_record);
		}
	
		actor.Heal(amount);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;
			
		Actor@ actor = cast<Actor>(target.GetScriptBehavior());
		
		if (actor is null)
			return false;
	
		if (actor.GetHealth() >= 1.0)
			return false;
	
		if (GetAmount(intensity, actor) <= 0)
			return false;
		
		return true;
	}
}