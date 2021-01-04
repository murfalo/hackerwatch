class GiveMana : IEffect
{
	int m_mana;
	bool m_pickup;

	GiveMana(UnitPtr unit, SValue& params)
	{
		m_mana = GetParamInt(unit, params, "mana");
		m_pickup = GetParamBool(unit, params, "pickup", false, false);
	}
	
	void SetWeaponInformation(uint weapon) {}

	int GetAmount(float intensity, Player@ player)
	{
		float ret = float(m_mana);

		ret *= intensity;

		if (m_pickup)
		{
			if (player !is null)
				ret *= player.m_record.GetModifiers().ManaGainScale(player);
				
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

		auto player = cast<Player>(target.GetScriptBehavior());
		if (player !is null)
			player.GiveMana(GetAmount(intensity, player));
			
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		auto player = cast<Player>(target.GetScriptBehavior());
		int amount = GetAmount(intensity, player);
		if (amount > 0 && player !is null)
			return player.m_record.mana < 1.0;

		return true;
	}
}