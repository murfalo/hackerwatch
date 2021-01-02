class HitscanSpreadDamage
{
	UnitPtr unit;
	int numHits;
	vec2 pos;
	vec2 dir;
	float intensity;
}

class HitscanSpread : IAction, IEffect
{
	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_missEffects;
	
	float m_teamDmg;
	int m_rays;
	
	int m_rangeMin;
	int m_rangeMax;
	
	float m_spread;
	float m_spreadMin;
	float m_spreadMax;
	int m_spreadTime;
	int m_spreadTimeC;
	int m_spreadCooldown;

	float m_spreadMul = 1.0f;
	float m_rangeMul = 1.0f;
	
	string m_shootFx;
	string m_hitFx;
	bool m_playMissFx;
	
	bool m_penetrating;
	bool m_onlyHitTargetsOnce;

	int m_ricochet;
	int m_ricochetExtra;
	float m_ricochetDamageExtra;

	float m_origLength = -1.0f;
	
	array<HitscanSpreadDamage@> m_hitUnits;
	uint m_weaponInfo;
	
	
	
	HitscanSpread(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
		@m_missEffects = LoadEffects(unit, params, "miss-");
		
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_rays = GetParamInt(unit, params, "rays", true, 1);
		m_penetrating = GetParamBool(unit, params, "penetrating", false, false);
		m_onlyHitTargetsOnce = GetParamBool(unit, params, "only-hit-targets-once", false, false);
		
		SValue@ spread = GetParamDictionary(unit, params, "spread", false);
		if (spread !is null)
		{
			m_spreadMin = GetParamInt(unit, spread, "min") * PI / 180.0;
			m_spreadMax = GetParamInt(unit, spread, "max") * PI / 180.0;
			m_spreadTime = GetParamInt(unit, spread, "time");
			m_spreadCooldown = GetParamInt(unit, params, "cooldown", false, 100);
		}
		else
			m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;
			
		SValue@ range = GetParamDictionary(unit, params, "range", false);
		if (range !is null)
		{
			m_rangeMin = GetParamInt(unit, range, "min");
			m_rangeMax = GetParamInt(unit, range, "max");
		}
		else
		{
			m_rangeMin = GetParamInt(unit, params, "range");
			m_rangeMax = -1;
		}

		m_ricochet = GetParamInt(unit, params, "ricochet", false);
		
		m_shootFx = GetParamString(unit, params, "shoot-fx", false);
		m_hitFx = GetParamString(unit, params, "hit-fx", false);
		//m_missFx = GetParamString(unit, params, "miss-fx", false);
		m_playMissFx = GetParamBool(unit, params, "miss-fx", false);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_effects, weapon);
		PropagateWeaponInformation(m_missEffects, weapon);
		
		m_weaponInfo = weapon;
	}
	
	bool NeedNetParams() { return true; }
	
	vec2 GetShootDir(vec2 dir, int i, bool allowRandom)
	{
		vec2 shootPos = dir;
		if (allowRandom && m_spread > 0)
		{
			float ang = atan(shootPos.y, shootPos.x) + (randf() - 0.5) * (m_spread * m_spreadMul);
			shootPos = vec2(cos(ang), sin(ang));
		}
	
		return shootPos;
	}
	
	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) { return true; }
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		dir = normalize(dir);

		int ricochet = m_ricochet + m_ricochetExtra;
		
		for (int i = 0; i < m_rays; i++)
		{
			vec2 shootPos = GetShootDir(dir, i, false);
			shootPos *= m_rangeMin * m_rangeMul;
			shootPos += pos;

			ShootSpreadHitscan(owner, pos, shootPos, intensity, husk, ricochet, m_ricochetDamageExtra);
		}
		
		DoDamageUnits(owner, husk);
		return true;
	}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		if (m_spreadTime > 0)
		{
			m_spread = lerp(m_spreadMin, m_spreadMax, min(1.0, m_spreadTimeC / float(m_spreadTime)));
			m_spreadTimeC = min(m_spreadTime, m_spreadTimeC + m_spreadCooldown);
		}
	
		dir = normalize(dir);

		int ricochet = m_ricochet + m_ricochetExtra;
		
		builder.PushArray();
		builder.PushFloat(intensity);
		builder.PushInteger(ricochet);
		builder.PushFloat(m_ricochetDamageExtra);
			
		for (int i = 0; i < m_rays; i++)
		{
			vec2 shootPos = GetShootDir(dir, i, true);
			
			if (m_rangeMin < m_rangeMax)
				shootPos *= (m_rangeMin + randi(m_rangeMax - m_rangeMin)) * m_rangeMul;
			else
				shootPos *= m_rangeMin * m_rangeMul;
				
			shootPos += pos;

			ShootSpreadHitscan(owner, pos, shootPos, intensity, false, ricochet, m_ricochetDamageExtra);
			builder.PushVector2(shootPos);
		}
		
		DoDamageUnits(owner, false);

		builder.PopArray();
		
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		auto rays = param.GetArray();
		float intensity = rays[0].GetFloat();
		int ricochet = rays[1].GetInteger();
		float ricochetMul = rays[2].GetFloat();
		
		for (uint i = 3; i < rays.length(); i++)
		{
			auto shootPos = rays[i].GetVector2();
			ShootSpreadHitscan(owner, pos, shootPos, intensity, true, ricochet, ricochetMul);
		}
		
		DoDamageUnits(owner, true);
		
		return true;
	}
	
	void DoDamageUnits(Actor@ owner, bool husk)
	{
		for (uint i = 0; i < m_hitUnits.length(); i++)
		{
			auto hitUnit = m_hitUnits[i];
			ApplyEffects(m_effects, owner, hitUnit.unit, hitUnit.pos, hitUnit.dir, hitUnit.intensity * hitUnit.numHits, husk, 0, m_teamDmg);
		}

		m_hitUnits.removeRange(0, m_hitUnits.length());
	}
	
	void Update(int dt, int cooldown)
	{
		if (cooldown <= 0)
			m_spreadTimeC = 0;
	}

	vec2 ShootSpreadHitscan(Actor@ owner, vec2 from, vec2 to, float intensity, bool husk, int ricochet = 0, float ricochetMul = 1.0f)
	{
		if (m_origLength < 0)
			m_origLength = dist(from, to);

		vec2 dir = normalize(to - from);

		vec2 endPoint = to;
		bool hit = false;
		
		UnitPtr lastUnit = UnitPtr();
		
		array<RaycastResult>@ results;
		auto plrHusk = cast<PlayerHusk>(owner);
		if (plrHusk !is null && plrHusk.m_record !is null)
			@results = g_scene.LagCompensation(Lobby::GetPlayerPing(plrHusk.m_record.peer)).Raycast(from, to, ~0, RaycastType::Shot);
		else
			@results = g_scene.Raycast(from, to, ~0, RaycastType::Shot);
			
		for (uint j = 0; j < results.length(); j++)
		{
			RaycastResult res = results[j];
			UnitPtr res_unit = res.FetchUnit(g_scene);
			
			if (!res_unit.IsValid())
				continue;
			
			if (res_unit == lastUnit)
				continue;
				
			lastUnit = res_unit;
			
			auto dt = cast<IDamageTaker>(res_unit.GetScriptBehavior());
			if (dt !is null && dt.ShootThrough(owner, res.point, dir))
				continue;

			if (ricochet > 0 && (dt is null || dt.Ricochets()))
			{
				vec2 rDir = res.normal * -2 * dot(dir, res.normal) + dir;
				float rDist = (dist(from, to) - dist(from, res.point));
				rDist = min(m_origLength, rDist * 1.5f);
				ShootSpreadHitscan(owner, res.point, res.point + rDir * rDist, intensity * ricochetMul, husk, ricochet - 1, ricochetMul);
			}

			if (CanApplyEffects(m_effects, owner, res_unit, res.point, dir, intensity, 0, m_teamDmg))
			{
				bool toAdd = true;
				for (uint i = 0; i < m_hitUnits.length(); i++)
				{
					if (m_hitUnits[i].unit == res_unit)
					{
						if (!m_onlyHitTargetsOnce)
							m_hitUnits[i].numHits++;
						toAdd = false;
						break;
					}
				}
			
				if (toAdd)
				{
					HitscanSpreadDamage hsd;
					hsd.unit = res_unit;
					hsd.numHits = 1;
					hsd.pos = res.point;
					hsd.dir = dir;
					hsd.intensity = intensity;
					
					m_hitUnits.insertLast(hsd);
				}
			
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_hitFx, res.point, ePs);
				hit = true;
				
				if (!m_penetrating)
				{
					endPoint = res.point;
					break;
				}
			}

			if (dt is null or dt.Impenetrable())
			{
				endPoint = res.point;
				break;
			}
		}

		if (!hit)
		{
	%if !GFX_VFX_LOW
			if (m_playMissFx)
			{
				array<Tileset@>@ tilesets = g_scene.FetchTilesets(to);
				for (int j = tilesets.length() - 1; j >= 0; j--)
				{
					SValue@ data = tilesets[j].GetData();
					if (data !is null)
					{
						SValue@ effect = data.GetDictionaryEntry("hit-effect");
						if (effect !is null && effect.GetType() == SValueType::String)
						{
							PlayEffect(effect.GetString(), to);
							break;
						}
					}
				}
			}
	%endif
			if (m_missEffects !is null)
				ApplyEffects(m_missEffects, owner, UnitPtr(), to, dir, intensity, husk, 0, m_teamDmg);
		}

		if (m_shootFx != "")
		{
			vec2 ep = endPoint - from;
			dictionary ePs = { { 'angle', atan(ep.y, ep.x) }, { 'length', length(ep) } };
			PlayEffect(m_shootFx, from, ePs);
		}

		return endPoint;
	}
}
