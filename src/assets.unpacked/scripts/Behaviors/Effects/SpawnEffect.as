class SpawnEffect : IEffect, IAction
{
	UnitScene@ m_effect;
	bool m_cloneEffectParams;

	SpawnEffect(UnitPtr unit, SValue& params)
	{
		@m_effect = Resources::GetEffect(GetParamString(unit, params, "effect"));
		m_cloneEffectParams = GetParamBool(unit, params, "clone-owner-params", false, false);
	}

	bool NeedNetParams() { return false; }
	void SetWeaponInformation(uint weapon) {}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		Do(pos, owner);
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		Do(pos, owner);
		return true;
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		Do(pos, owner);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
	
	void Do(vec2 pos, Actor@ owner)
	{
		if (m_cloneEffectParams && owner !is null)
		{
			auto params = owner.m_unit.GetEffectParams();
			if (params !is null)
				PlayEffect(m_effect, pos, params);
			else
				PlayEffect(m_effect, pos);
		}
		else
			PlayEffect(m_effect, pos);
	}
	
	void Update(int dt, int cooldown)
	{
	}
}