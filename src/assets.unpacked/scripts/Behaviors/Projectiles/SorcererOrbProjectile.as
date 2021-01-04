class SorcererOrbProjectile : RayProjectile
{
	int m_projDelay;
	int m_projDelayC;
	int m_projNum;
	int m_dist;
	float m_rot;
	
	uint m_weaponInfo;
	
	UnitProducer@ m_projectile;
	

	SorcererOrbProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		m_projDelayC = GetParamInt(unit, params, "delay", false, 500);
		m_projDelay = GetParamInt(unit, params, "proj-delay", false, 40);
		m_dist = GetParamInt(unit, params, "dist", false, 8);
		m_rot = GetParamFloat(unit, params, "rot", false, 1);
		
		@m_projectile = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
		
		m_projNum = 0;
	}
	
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		RayProjectile::Initialize(owner, dir, intensity, husk, target, weapon);
		m_weaponInfo = weapon;
	}
	
	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true) override
	{
		if (!unit.IsValid())
			return true;
		
		ref@ b = unit.GetScriptBehavior();
		if (b is m_owner)
			return true;

		auto dt = cast<IDamageTaker>(b);
		if (dt !is null)
		{
			if (dt.ShootThrough(m_owner, pos, m_dir))
				return true;
		
			bounce = dt.Impenetrable();
			
			/*
			{
				ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk);
				m_unit.Destroy();
				return true;
			}
			*/
			
			auto a = cast<Actor>(b);
			if (m_blockable && a !is null && a.BlockProjectile(this))
			{
				ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk);
				m_unit.Destroy();
				return false;
			}
			
			if (!(FilterAction(a, m_owner, m_selfDmg, m_teamDmg, 1, 1) > 0))
				return true;
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
				
				PlaySound3D(m_soundBounce, xyz(pos));
			}
		}

		return false;
	}
	
	void ShootProj(float angle)
	{
		vec2 dir(cos(angle), sin(angle));
        auto pos = m_unit.GetPosition() + vec3(-dir.y, dir.x, 0) * m_dist;

		auto proj = m_projectile.Produce(g_scene, pos);
		if (!proj.IsValid())
			return;
		
		IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
		if (p is null)
			return;

		p.Initialize(m_owner, dir, 1.0f, m_husk, null, m_weaponInfo);
	}
	
	void Update(int dt) override
	{
		m_projDelayC -= dt;
		while (m_projDelayC <= 0)
		{
			m_projDelayC += m_projDelay;

			float angle = m_projNum * m_rot;

			ShootProj(angle);
			ShootProj(angle + PI);

			m_projNum++;
		}
		
		RayProjectile::Update(dt);
	}
}