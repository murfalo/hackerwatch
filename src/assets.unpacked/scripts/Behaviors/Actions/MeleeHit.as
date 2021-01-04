class MeleeHit : IAction
{
	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_missEffects;

	float m_teamDmg;
	uint m_radius;
	int m_dist;

	string m_hitFx;

	SoundEvent@ m_damageSound;

	MeleeHit(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
		@m_missEffects = LoadEffects(unit, params, "miss-");

		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_radius = GetParamInt(unit, params, "radius", false, 24);
		m_dist = GetParamInt(unit, params, "dist", false, m_radius);

		m_hitFx = GetParamString(unit, params, "hit-fx", false);

		@m_damageSound = Resources::GetSoundEvent(GetParamString(unit, params, "damage-sound", false));
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_effects, weapon);
		PropagateWeaponInformation(m_missEffects, weapon);
	}

	bool NeedNetParams() { return true; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		vec2 shootPos = pos + dir * m_dist;
		auto res = g_scene.RaycastClosest(xy(owner.m_unit.GetPosition()), shootPos, ~0, RaycastType::Shot);
		UnitPtr hitUnit = res.FetchUnit(g_scene);
		if (hitUnit.IsValid() && hitUnit != owner.m_unit)
			shootPos = res.point - dir * 2.0f;
	
		builder.PushArray();
		builder.PushFloat(intensity);
		builder.PushVector2(shootPos);
		builder.PopArray();
	
		return DoHit(owner, shootPos, dir, intensity, false);
	}
	
	bool DoHit(Actor@ owner, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		array<UnitPtr> hitUnits;

		bool hitSomething = false;
		const uint numRays = 14;
		for (uint i = 0; i < numRays; i++)
		{
			vec2 upos = pos + vec2(cos(i * TwoPI / numRays), sin(i * TwoPI / numRays)) * m_radius;
			
			RaycastResult rayResults = g_scene.RaycastClosest(pos, upos, ~0, RaycastType::Shot);
			auto hitUnit = rayResults.FetchUnit(g_scene);
			upos = rayResults.point;
			
			if (!hitUnit.IsValid())
				continue;
				
			if (hitUnit == owner.m_unit)
				continue;
				
			bool alreadyHit = false;
			for (uint j = 0; j < hitUnits.length(); j++)
			{
				if (hitUnits[j] == hitUnit)
				{
					alreadyHit = true;
					break;
				}
			}
			
			if (alreadyHit)
				continue;
				
			hitUnits.insertLast(hitUnit);
			ApplyEffects(m_effects, owner, hitUnit, upos, dir, intensity, husk, 0, m_teamDmg);
			hitSomething = true;
		}

		if (!hitSomething)
			ApplyEffects(m_missEffects, owner, UnitPtr(), pos, dir, intensity, husk, 0, m_teamDmg);
		else
			PlaySound3D(m_damageSound, owner.m_unit.GetPosition());

		dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
		PlayEffect(m_hitFx, pos, ePs);

		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		auto d = param.GetArray();
		auto intensity = d[0].GetFloat();
		auto shootPos = d[1].GetVector2();
	
		return DoHit(owner, shootPos, dir, intensity, true);
	}

	void Update(int dt, int cooldown)
	{
	}
}
