interface IAction
{
	void Update(int dt, int cooldown);
	bool NeedNetParams();
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity);
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir);
	void SetWeaponInformation(uint weapon);
}

class ActionEffectWrapper : IAction
{
	ActionEffectWrapper(IEffect@ effect) { 
		@m_effect = effect; 
	}

	void Update(int dt, int cooldown) {}
	bool NeedNetParams() { return true; }
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity) 
	{
		UnitPtr t;
		if (target !is null)
			t = g_scene.GetUnit(target.m_unit.GetId());

		builder.PushInteger(t.GetId());
		return m_effect.Apply(owner, t, pos, dir, intensity, false);
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir) {
		return m_effect.Apply(owner, g_scene.GetUnit(param.GetInteger()), pos, dir, 1.0f, true);
	}
	
	void SetWeaponInformation(uint weapon) {
		m_effect.SetWeaponInformation(weapon);
	}

	IEffect@ m_effect;
}

void NetDoActions(array<IAction@>@ actions, SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
{
	if (actions is null)
		return;
	
	uint p = 0;
	array<SValue@>@ params = null;
	
	if (param !is null && param.GetType() == SValueType::Array)
		@params = param.GetArray();
	
	for (uint i = 0; i < actions.length(); i++)
	{
		if (actions[i].NeedNetParams() && params.length() > p)
			actions[i].NetDoAction(params[p++], owner, pos, dir);
		else
			actions[i].NetDoAction(null, owner, pos, dir);
	}
}

SValue@ DoActions(array<IAction@>@ actions, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity = 1.0)
{
	if (actions is null)
		return null;

	bool netParams = false;
	for (uint i = 0; i < actions.length(); i++)
	{
		if (actions[i].NeedNetParams())
		{
			netParams = true;
			break;
		}
	}
	
	SValueBuilder@ builder;
	
	if (netParams)
	{
		@builder = SValueBuilder();
		builder.PushArray();
	}

	for (uint i = 0; i < actions.length(); i++)
		actions[i].DoAction(builder, owner, target, pos, dir, intensity);

	if (netParams)
		return builder.Build();
		
	return null;
}

IAction@ LoadAction(UnitPtr owner, SValue& params)
{
	auto cName = GetParamString(owner, params, "class");
	auto c = InstantiateClass(cName, owner, params);
	
	IAction@ action = cast<IAction>(c);
	if (action !is null)
		return action;

	IEffect@ effect = cast<IEffect>(c);
	if (effect !is null)
		return ActionEffectWrapper(effect);
	
	PrintError(cName + " is not an IAction or an IEffect!");
	return null;
}

array<IAction@>@ LoadActions(UnitPtr owner, SValue& params, string prefix = "")
{
	array<IAction@> actions;
	
	array<SValue@>@ effectArr = GetParamArray(owner, params, prefix + "actions", false);
	if (effectArr !is null)
	{
		for (uint i = 0; i < effectArr.length(); i++)
		{
			auto action = LoadAction(owner, effectArr[i]);
			if (action !is null)
				actions.insertLast(action);
		}
	}
	else
	{
		SValue@ dat = GetParamDictionary(owner, params, prefix + "action", false);
		if (dat !is null)
		{
			auto action = LoadAction(owner, dat);
			if (action !is null)
				actions.insertLast(action);
		}
	}
	
	return actions;
}

float FilterAction(Actor@ a, Actor@ owner, float selfDmg, float teamDmg, float enemyDmg, float huskDmg = 0, uint teamOverride = 1)
{
	if (a is null)
		return 1;
		
	if (owner is null)
	{
		if (teamOverride != 1)
			return g_gameMode.FilterAction(a, owner, selfDmg, teamDmg, enemyDmg, teamOverride);
	
		return 1;	
	}

	if (owner is a)
		return selfDmg;

	if (a.IsHusk() && owner.IsHusk())
	{
		if (huskDmg == 0)
			return 0;

		return g_gameMode.FilterAction(a, owner, selfDmg, teamDmg, enemyDmg, teamOverride) * huskDmg;
	}

	return g_gameMode.FilterAction(a, owner, selfDmg, teamDmg, enemyDmg, teamOverride);
}


void PropagateWeaponInformation(array<IAction@>@ actions, uint weapon)
{
	if (actions is null)
		return;
		
	for (uint i = 0; i < actions.length(); i++)
		actions[i].SetWeaponInformation(weapon);
}
