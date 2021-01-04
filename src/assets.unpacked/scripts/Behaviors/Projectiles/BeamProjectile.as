class BeamProjectile : RayProjectile, IPreRenderable
{
	int m_length;
	float m_lengthC;
	int m_rayNum;
	int m_rayWidth;
	
	int m_cachedLen;
	

	BeamProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_length = GetParamInt(unit, params, "length", false, 50);
		
		m_rayNum = GetParamInt(unit, params, "ray-num", false, 1);
		m_rayWidth = GetParamInt(unit, params, "ray-width", false, m_rayNum * 2);
		
		
		m_preRenderables.insertLast(this);
	}
	
	bool PreRender(int idt)
	{
		if (m_effectParams !is null)
		{
			float d = m_speed * (idt / 33.0 - 1);
			//float d = dist(m_unit.GetPosition(), m_unit.GetInterpolatedPosition(idt));

			if (m_lengthC < m_length)
			{
				if (m_cachedLen >= m_lengthC)
					m_effectParams.Set("length", min(float(m_length), m_lengthC + d));
			}
		    else if (m_cachedLen < m_lengthC)
				m_effectParams.Set("length", max(0.0f, m_cachedLen - d));
		}
		
		return m_unit.IsDestroyed();
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
		
		if (m_lengthC < m_length)
		{
			m_lengthC = min(float(m_length), m_lengthC + m_speed * dt / 33.0);
			if (m_owner !is null && m_owner.IsDead())
				m_length = int(m_lengthC);
		}
		else
		{
			vec2 from = m_pos;
			m_pos += m_dir * m_speed * dt / 33.0;
		
			array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
			for (uint i = 0; i < results.length(); i++)
			{
				RaycastResult res = results[i];
				if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, true) && !m_penetrateAll)
					return;
					
				if (m_unit.IsDestroyed())
					return;
			}

			m_unit.SetPosition(m_pos.x, m_pos.y, 0, true);
		}
		
		
		float minLength = 1.0f;
		array<RaycastResult>@ results = null;
		if (m_rayNum <= 1)
			@results = g_scene.Raycast(m_pos, m_pos + m_dir * m_lengthC, ~0, RaycastType::Shot);
		else
			@results = g_scene.RaycastWide(m_rayNum, m_rayWidth, m_pos, m_pos + m_dir * m_lengthC, ~0, RaycastType::Shot);
		
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			auto unit = res.FetchUnit(g_scene);
			if (!HitUnit(unit, res.point, res.normal, m_selfDmg, false))
			{
				auto dmgTaker = cast<IDamageTaker>(unit.GetScriptBehavior());
				if ((dmgTaker is null || dmgTaker.Impenetrable()) && !m_penetrateAll)
				{
					minLength = min(minLength, res.fraction);
					break;
				}
			}
		}
		
		m_cachedLen = int(minLength * m_lengthC);
		if (m_effectParams !is null)
			m_effectParams.Set("length", m_cachedLen);

		UpdateSpeed(m_dir, dt);
		ProjectileBase::Update(dt);
		
		m_lastCollision = UnitPtr();
	}
}
