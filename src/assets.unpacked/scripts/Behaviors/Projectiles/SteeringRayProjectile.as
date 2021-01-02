DynamicExpression@ GetDynamicExpression(string str)
{
	if (str == "")
		return null;

	DynamicExpression@ ret = DynamicExpression();
	if (!ret.Compile(str)) // { "t", "u" }
		return null;

	return ret;
}

class SteeringRayProjectile : RayProjectile
{
	DynamicExpression@ m_dirSteering;
	DynamicExpression@ m_speedSteering;

	float m_dirOffset;
	float m_speedOffset;
	
	bool m_disableSteerOnBounce;
	

	SteeringRayProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		@m_dirSteering = GetDynamicExpression(GetParamString(unit, params, "dir-steer", false));
		@m_speedSteering = GetDynamicExpression(GetParamString(unit, params, "speed-steer", false));
		
		if (m_bounces > 0)
			m_disableSteerOnBounce = GetParamBool(unit, params, "disable-steer-on-bounce", false, false);
	}
	
	vec2 GetDirection() override { return addrot(m_dir, m_dirOffset); }
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x) + m_dirOffset;
		m_unit.SetUnitScene(m_anim.GetSceneName(ang), false);
		SetScriptParams(ang, m_speed + m_speedOffset);
	}
	
	void OnBounce(vec2 pos) override
	{
		PlaySound3D(m_soundBounce, xyz(pos));
		
		if (m_disableSteerOnBounce)
		{
			@m_dirSteering = null;
			@m_speedSteering = null;
		}
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
		
		if (m_dirSteering !is null)
		{
			//m_dirSteering.SetValues({ "t", m_time / 1000.0f, "u", m_unit.GetId(), "dir", atan(m_dir.y, m_dir.x), "speed", m_speed });
			m_dirOffset = m_dirSteering.Evaluate(m_unit);
			
			//m_dirOffset = m_dirSteering.Evaluate(m_unit, { "t", m_time / 1000.0f, "u", m_unit.GetId(), "dir", atan(m_dir.y, m_dir.x), "speed", m_speed });
			//m_dirOffset = m_dirSteering.Evaluate(m_unit, { m_time / 1000.0f, m_unit.GetId() });
		}
		
		if (m_speedSteering !is null)
		{
			m_speedOffset = m_speedSteering.Evaluate(m_unit);
			//m_speedOffset = m_speedSteering.Evaluate(m_unit, { m_time / 1000.0f, m_unit.GetId() });
		}
		
		SetDirection(m_dir);
		UpdateSeeking(m_dir, dt);
		
		vec2 from = m_pos;
		m_pos += addrot(m_dir, m_dirOffset) * (m_speed + m_speedOffset) * dt / 33.0;
	
		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
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
		
		m_lastCollision = UnitPtr();
	}
}
