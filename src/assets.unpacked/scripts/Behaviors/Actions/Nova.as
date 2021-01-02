class Nova : IAction, IEffect
{
	UnitProducer@ m_projectile;
	int m_projectiles;
	float m_projDist;
	uint m_weaponInfo;

	Nova(UnitPtr unit, SValue& params)
	{
		@m_projectile = Resources::GetUnitProducer(GetParamString(unit, params, "projectile", false));
		m_projectiles = GetParamInt(unit, params, "projectiles", false, 1);
		m_projDist = GetParamFloat(unit, params, "proj-dist", false);
	}	
	
	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}
	
	bool NeedNetParams() { return true; }
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		Actor@ targetActor;
		if (target.IsValid())
			@targetActor = cast<Actor>(target.GetScriptBehavior());

		DoNova(owner, targetActor, pos, intensity, husk);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		builder.PushArray();
		builder.PushFloat(intensity);
		
		if (target is null)
			builder.PushInteger(0);
		else
			builder.PushInteger(target.m_unit.GetId());
			
		DoNova(owner, target, pos, intensity, false);
		builder.PopArray();
		
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		array<SValue@>@ arr = param.GetArray();
		float intensity = arr[0].GetFloat();

		UnitPtr targetUnit = g_scene.GetUnit(arr[1].GetInteger());
		Actor@ target;
		if (targetUnit.IsValid())
			@target = cast<Actor>(targetUnit.GetScriptBehavior());

		DoNova(owner, target, pos, intensity, true);
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
	}

	UnitProducer@ GetProducer(Actor@ owner)
	{
		return m_projectile;
	}
	
	void DoNova(Actor@ owner, Actor@ target, vec2 pos, float intensity, bool husk)
	{
		auto prod = GetProducer(owner);
		if (prod is null)
		{
			PrintError("Nova projectile is null!");
			return;
		}

		for (int i = 0; i < m_projectiles; i++)
		{
			float ang = i * TwoPI / m_projectiles;
			vec2 shootDir = vec2(cos(ang), sin(ang));
			
			UnitPtr proj = prod.Produce(g_scene, xyz(pos + shootDir * m_projDist));
			if (!proj.IsValid())
				continue;
			
			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				continue;
			
			p.Initialize(owner, shootDir, intensity, husk, target, m_weaponInfo);
		}
	}
}
