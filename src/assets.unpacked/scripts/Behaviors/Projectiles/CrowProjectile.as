class CrowProjectile : RayProjectile
{
	CrowProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}
	
	void Update(int dt) override
	{
		m_ttl -= dt;
		if (m_ttl <= 0)
		{
			ApplyEffects(m_missEffects, m_owner, UnitPtr(), m_pos, m_dir, m_intensity, m_husk);
			m_unit.Destroy();
			return;
		}

		UpdateSeeking(m_dir, dt);
		
		vec2 from = m_pos;
		m_pos += m_dir * m_speed * dt / 33.0;
	
		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Any);
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, true))
				return;
				
			if (m_unit.IsDestroyed())
				return;
		}
	
		m_unit.SetPosition(m_pos.x, m_pos.y, 0, true);

		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
}
