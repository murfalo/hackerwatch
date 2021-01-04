class ApplyBuff : IEffect, IAction
{
	ActorBuffDef@ m_buff;
	bool m_ignoreIntensity;
	uint m_weaponInfo;
	bool m_targetSelf;

	ApplyBuff(UnitPtr unit, SValue& params)
	{
		@m_buff = LoadActorBuff(GetParamString(unit, params, "buff"));
		m_ignoreIntensity = GetParamBool(unit, params, "ignore-intensity", false, false);
		m_targetSelf = GetParamBool(unit, params, "target-self", false, false);
	}

	void Update(int dt, int cooldown)
	{
	}

	bool NeedNetParams() { return true; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		UnitPtr targetUnit;
		if (target !is null)
			targetUnit = target.m_unit;

		builder.PushArray();
		builder.PushInteger(targetUnit.GetId());
		builder.PushFloat(intensity);
		builder.PopArray();

		return Apply(owner, targetUnit, pos, dir, intensity, false);
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		auto arrParams = param.GetArray();

		UnitPtr targetUnit = g_scene.GetUnit(arrParams[0].GetInteger());
		float intensity = arrParams[1].GetFloat();

		return Apply(owner, targetUnit, pos, dir, intensity, true);
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;
			
		if (!FilterHuskDamage(owner, target, husk))
			return false;

		Actor@ actor = null;
		if (m_targetSelf)
			@actor = owner;
		else
			@actor = cast<Actor>(target.GetScriptBehavior());

		return actor.ApplyBuff(ActorBuff(owner, m_buff, m_ignoreIntensity ? 1.0f : intensity, false, m_weaponInfo));
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		if (m_buff is null)
			return false;
			
		if (intensity <= 0)
			return false;

		if (!m_targetSelf)
		{
			Actor@ actor = cast<Actor>(target.GetScriptBehavior());
			if (actor is null)
				return false;
		}

		return true;
	}
}