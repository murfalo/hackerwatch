class ThrowProjectile : RayProjectile
{
	int m_ttlMax;
	float m_arcHeight;
	string m_speedCalc;

	ThrowProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_arcHeight = GetParamFloat(unit, params, "arc-height", false, 12.0);
		m_ttlMax = m_ttl;
		
		m_speedCalc = GetParamString(unit, params, "speed-calc", false);
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		if (target !is null)
		{
			vec3 posMe = m_unit.GetPosition();
			vec3 posTarget = target.m_unit.GetPosition();
			float distance = dist(posMe, posTarget);
			m_arcHeight = min(distance / 3.0f, m_arcHeight);

			if (m_speedCalc != "")
			{
				DynamicExpression@ speedExpr = DynamicExpression();
				if (speedExpr.Compile(m_speedCalc, { "dist" }))
					m_speed = speedExpr.Evaluate(m_unit, { distance });
				
				m_speedCalc = "";
			}
			
			m_ttlMax = m_ttl = int(distance / m_speed * 33.0f);
		}

		RayProjectile::Initialize(owner, dir, intensity, husk, target, weapon);
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
	
		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, true))
				return;
				
			if (m_unit.IsDestroyed())
				return;
		}
	
		float height = sin(PI * m_ttl / float(m_ttlMax)) * m_arcHeight;
		m_unit.SetPosition(m_pos.x, m_pos.y, height, true);

		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
	
	
	
	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true) override
	{
		if (!unit.IsValid())
			return true;
		
		ref@ b = unit.GetScriptBehavior();
		/*
		IProjectile@ p = cast<IProjectile>(b);
		if (p !is null)
			return true;
		*/

		
		auto dt = cast<IDamageTaker>(b);
		if (dt !is null)
		{
			if (dt.ShootThrough(m_owner, pos, m_dir))
				return true;
		
			bounce = false;
				
			auto a = cast<Actor>(b);
			if (m_blockable && a !is null && a.BlockProjectile(this))
			{
				m_unit.Destroy();
				return false;
			}
		
			if (dt is m_owner && selfDmg > 0)
			{
				if (m_lastCollision != unit)
				{
					m_lastCollision = unit;
					ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity * selfDmg, m_husk);
					
					if (collide)
					{
						if (--m_penetration <= 0)
						{
							PlaySound3D(m_soundHit, xyz(pos));
							m_unit.Destroy();
						}
						else
							m_intensity *= m_penetrationIntensityMul;
					}
				}
				
				return false;
			}
			else if (!(FilterAction(a, m_owner, m_selfDmg, m_teamDmg, 1, 1, Team) > 0))
				return true;
			else if (collide && --m_penetration <= 0)
			{
				PlaySound3D(m_soundHit, xyz(pos));
				m_unit.Destroy();
			}
		}

		if (m_lastCollision != unit)
		{
			m_lastCollision = unit;
			ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk);
			m_intensity *= m_penetrationIntensityMul;
		}
		
		if (bounce)
		{
			if (m_bounces <= 0)
			{
				if (!m_penetrateAll)
					m_unit.Destroy();
			}
			else
			{
				m_lastCollision = unit;
				
				m_bounces--;
				m_speed *= m_bounceSpeedMul;
				SetDirection(normal * -2 * dot(m_dir, normal) + m_dir);
				m_pos = pos;
				
				OnBounce(pos);
			}
		}

		return false;
	}
}
