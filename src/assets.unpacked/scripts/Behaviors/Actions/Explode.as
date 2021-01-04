class Explode : IAction, IEffect
{
	array<IEffect@>@ m_effects;
	string m_fx;
	string m_tileFx;
	int m_radius;
	int m_minRadius;
	float m_distScaling;
	float m_selfDmg;
	float m_teamDmg;
	float m_enemyDmg;
	bool m_raycastCheck;
	
	Explode(UnitPtr unit, SValue& params)
	{
		m_fx = GetParamString(unit, params, "fx", false);
		m_tileFx = GetParamString(unit, params, "tile-fx", false);
		m_radius = GetParamInt(unit, params, "radius");
		m_minRadius = GetParamInt(unit, params, "min-radius", false, 0);
		m_distScaling = GetParamFloat(unit, params, "dist-scaling", false, 3);
		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_enemyDmg = GetParamFloat(unit, params, "enemy-dmg", false, 1);
		m_raycastCheck = GetParamBool(unit, params, "raycast-check", false, true);
		@m_effects = LoadEffects(unit, params);
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_effects, weapon);
	}
	
	bool NeedNetParams() { return true; }
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		builder.PushFloat(intensity);
		return DoExplosion(owner, pos, dir, intensity, false);
	}

	string GetFxName(vec2 pos)
	{
		string fx = m_fx;
		if (m_tileFx != "")
		{
			array<Tileset@>@ tilesets = g_scene.FetchTilesets(pos);
			for (int i = tilesets.length() - 1; i >= 0; i--)
			{
				SValue@ tsd = tilesets[i].GetData();
				if (tsd is null)
					continue;

				SValue@ svExplodeFx = tsd.GetDictionaryEntry(m_tileFx);
				if (svExplodeFx is null || svExplodeFx.GetType() != SValueType::String)
					continue;

				fx = svExplodeFx.GetString();
				break;
			}
		}
		return fx;
	}
	
	bool DoExplosion(Actor@ owner, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		dictionary ePs = { { 'radius', m_radius }, { 'angle', atan(dir.y, dir.x) } };
		PlayEffect(GetFxName(pos), pos, ePs);
		
		array<UnitPtr>@ directHits;
		
		if (m_minRadius > 0)
			@directHits = g_scene.QueryCircle(pos, m_minRadius, ~0, RaycastType::Shot, true);
		else
			@directHits = array<UnitPtr>();
			
		auto results = g_scene.QueryCircle(pos, m_radius, ~0, RaycastType::Shot, true);
		for (uint i = 0; i < results.length(); i++)
		{
			UnitPtr unit = results[i];
			vec2 upos = xy(unit.GetPosition());
			
			bool visible = true;
			float hitDist = m_radius + 1;
			
			for (uint j = 0; j < directHits.length(); j++)
			{
				if (results[i] == directHits[j])
				{
					hitDist = 0;
					break;
				}
			}
			
			if (m_raycastCheck && hitDist > 0)
			{
				auto rayResults = g_scene.Raycast(pos, upos, ~0, RaycastType::Shot);
				if (rayResults.length() <= 0)
					hitDist = 0;
				
				for (uint j = 0; j < rayResults.length(); j++)
				{
					UnitPtr res_unit = rayResults[j].FetchUnit(g_scene);
					if (!res_unit.IsValid())
						continue;

					if (res_unit == unit)
					{
						hitDist = max(0.0, rayResults[j].fraction * length(upos - pos) - m_minRadius);
						upos = rayResults[j].point;
						break;
					}

					auto b = res_unit.GetScriptBehavior();
					auto d = cast<IDamageTaker>(b);
					if (d is null or d.Impenetrable())
					{
						visible = false;
						break;
					}
				}
			}

			if (!visible)
				continue;

			float d = 1.0;
			if (m_radius > 	m_minRadius)
				d = max(0.0, 1.0 - pow(hitDist / (m_radius - m_minRadius), m_distScaling));

			ApplyEffects(m_effects, owner, unit, upos, dir, intensity * d, husk, m_selfDmg, m_teamDmg, m_enemyDmg);
		}

		return true;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		return DoExplosion(owner, pos, dir, param.GetFloat(), true);
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		return DoExplosion(owner, pos, dir, intensity, husk);
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
	}
}