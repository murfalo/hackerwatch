class BounceProjectile : RayProjectile
{
	int m_ttlMax;
	int m_floorBounces;
	float m_floorBounceIntensityMul;
	int m_floorBounceHeight;

	BounceProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		m_ttlMax = m_ttl;
		m_floorBounceIntensityMul = GetParamFloat(unit, params, "floor-bounce-intensity-mul", false, 1.0);
		m_floorBounces = GetParamInt(unit, params, "floor-bounces", false, 10);
		m_floorBounceHeight = GetParamInt(unit, params, "floor-bounce-height", false, 20);
	}
	
	void Update(int dt) override
	{
		m_ttl -= dt;
		if (m_ttl <= 0)
		{
			ApplyEffects(m_missEffects, m_owner, UnitPtr(), m_pos, m_dir, m_intensity, m_husk);
			
			m_floorBounces--;
			m_intensity *= m_floorBounceIntensityMul;
			m_ttl = m_ttlMax;
			
			if (m_floorBounces <= 0)
			{
				m_unit.Destroy();
				return;
			}
		}

		UpdateSeeking(m_dir, dt);
		
		vec2 from = m_pos;
		m_pos += m_dir * m_speed * dt / 33.0;
	
		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, true))
				return;
				
			if (m_unit.IsDestroyed())
				return;
		}
	
		m_unit.SetPosition(m_pos.x, m_pos.y, sin(PI * m_ttl / float(m_ttlMax)) * m_floorBounceHeight, true);

		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
}
