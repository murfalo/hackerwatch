class Hitscan : IAction, IEffect
{
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
	
	
	int m_penetrating;
	float m_penetratingMul;

	int m_ricochet;
	int m_ricochetExtra;
	float m_ricochetDamageExtra;
	
	
	HitscanShooter@ m_shooter;
	
	
	
	Hitscan(UnitPtr unit, SValue& params)
	{
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_rays = GetParamInt(unit, params, "rays", false, 1);

		m_penetrating = GetParamInt(unit, params, "penetrating", false, 0);
		m_penetratingMul = GetParamFloat(unit, params, "penetrating-mul", false, 1.0f);

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

		
		
		auto hitEffects = LoadEffects(unit, params);
		auto missEffects = LoadEffects(unit, params, "miss-");
		auto shootFx = GetParamString(unit, params, "shoot-fx", false);
		auto hitFx = GetParamString(unit, params, "hit-fx", false);
		auto playMissFx = GetParamBool(unit, params, "miss-fx", false);
		
		@m_shooter = HitscanShooter(hitEffects, missEffects, hitFx, shootFx, playMissFx);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_shooter.m_hitEffects, weapon);
		PropagateWeaponInformation(m_shooter.m_missEffects, weapon);
	}
	
	bool NeedNetParams() { return true; }
	
	vec2 GetShootDir(vec2 dir, int i, bool allowRandom)
	{
		vec2 shootPos = dir;
		if (allowRandom && m_spread > 0)
		{
			float ang = atan(shootPos.y, shootPos.x) + (randf() - 0.5) * m_spread;
			shootPos = vec2(cos(ang), sin(ang));
		}
	
		return shootPos;
	}
	
	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) { return true; }
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		dir = normalize(dir);
		
		for (int i = 0; i < m_rays; i++)
		{
			vec2 shootPos = GetShootDir(dir, i, false);
			shootPos *= m_rangeMin;
			shootPos += pos;

			int ricochet = m_ricochet + m_ricochetExtra;

			m_shooter.m_penetratingMul = m_penetratingMul;
			m_shooter.ShootHitscan(owner, pos, shootPos, m_penetrating, intensity, m_teamDmg, husk, ricochet, m_ricochetDamageExtra);
		}
		
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

		builder.PushArray();
		builder.PushFloat(intensity);
		
		for (int i = 0; i < m_rays; i++)
		{
			vec2 shootPos = GetShootDir(dir, i, true);

			if (m_rangeMin < m_rangeMax)
				shootPos *= m_rangeMin + randi(m_rangeMax - m_rangeMin);
			else
				shootPos *= m_rangeMin;
				
			shootPos += pos;

			int ricochet = m_ricochet + m_ricochetExtra;

			m_shooter.m_penetratingMul = m_penetratingMul;
			m_shooter.ShootHitscan(owner, pos, shootPos, m_penetrating, intensity, m_teamDmg, false, ricochet, m_ricochetDamageExtra);
			builder.PushVector2(shootPos);
			builder.PushInteger(ricochet);
			builder.PushFloat(m_ricochetDamageExtra);
		}

		builder.PopArray();
		
		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		auto rays = param.GetArray();
		float intensity = rays[0].GetFloat();
		
		for (uint i = 1; i < rays.length(); i += 3)
		{
			auto shootPos = rays[i].GetVector2();
			int ricochet = rays[i + 1].GetInteger();
			float ricochetMul = rays[i + 2].GetFloat();

			m_shooter.ShootHitscan(owner, pos, shootPos, m_penetrating, intensity, m_teamDmg, true, ricochet, ricochetMul);
		}
		
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
		if (cooldown <= 0)
			m_spreadTimeC = 0;
	}
}


class HitscanShooter
{
	array<IEffect@>@ m_hitEffects;
	array<IEffect@>@ m_missEffects;
	string m_hitFx;
	string m_shootFx;
	bool m_playMissFx;
	float m_penetratingMul = 1.0f;
	float m_origLength = -1.0f;
	float m_selfDmg = 0.0f;
	
	
	HitscanShooter(array<IEffect@>@ hitEffects, array<IEffect@>@ missEffects, string hitFx, string shootFx, bool playMissFx)
	{
		@m_hitEffects = hitEffects;
		@m_missEffects = missEffects;
		m_hitFx = hitFx;
		m_shootFx = shootFx;
		m_playMissFx = playMissFx;
	}
	
	vec2 ShootHitscan(Actor@ owner, vec2 from, vec2 to, int penetrating, float intensity, float teamDmg, bool husk, int ricochet = 0, float ricochetMul = 1.0f)
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
			
			if (m_hitEffects is null || ApplyEffects(m_hitEffects, owner, res_unit, res.point, dir, intensity, husk, m_selfDmg, teamDmg))
			{
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_hitFx, res.point, ePs);
				hit = true;

				if (ricochet > 0 && (dt is null || dt.Ricochets()))
				{
					vec2 rDir = res.normal * -2 * dot(dir, res.normal) + dir;
					float rDist = (dist(from, to) - dist(from, res.point));
					rDist = min(m_origLength, rDist * 1.5f);
					ShootHitscan(owner, res.point, res.point + rDir * rDist, penetrating, intensity * ricochetMul, teamDmg, husk, ricochet - 1, ricochetMul);
				}

				if (penetrating != 0)
				{
					intensity *= m_penetratingMul;
					if (penetrating > 0)
						penetrating--;
				}
				else
				{
					endPoint = res.point;
					break;
				}
			}
			
			if (dt is null || dt.Impenetrable())
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
				ApplyEffects(m_missEffects, owner, UnitPtr(), to, dir, intensity, husk, m_selfDmg, teamDmg);
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