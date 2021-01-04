class TossProjectile : Projectile
{
	float m_charge;

	int m_animNum;
	int m_maxTtl;
	float m_maxSpeed;
	float m_arcHeight;

	UnitPtr m_lastCollision;
	int m_penetration;

	bool m_onTarget;

	TossProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_animNum = GetParamInt(unit, params, "anim-num");

		m_arcHeight = GetParamFloat(unit, params, "arc-height", false, 12.0);

		m_penetration = GetParamInt(unit, params, "penetration", false, 0);

		m_onTarget = GetParamBool(unit, params, "on-target", false, false);
		
		m_maxTtl = GetParamInt(unit, params, "max-ttl", false, int(m_ttl * 1.5));
		m_maxSpeed = GetParamFloat(unit, params, "max-speed", false, m_speed * 1.5);
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		Initialize(owner, dir, intensity, husk, target, weapon, 1.0);
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon, float charge)
	{
		m_maxTtl = m_ttl = lerp(m_ttl, m_maxTtl, charge);
		m_speed = lerp(m_speed, m_maxSpeed, charge);
		m_charge = charge;

		if (m_onTarget && target !is null)
		{
			vec3 posMe = m_unit.GetPosition();
			vec3 posTarget = target.m_unit.GetPosition();
			float distance = dist(posMe, posTarget);
			m_speed = min(m_speed, (distance / m_speed) / 2.0);
		}

		Projectile::Initialize(owner, dir, intensity, husk, target, weapon);
	}

	vec2 GetDirection() override { return m_dir; }	
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x);
		m_unit.SetUnitScene(m_anim.GetSceneName(ang) + "-" + int(m_charge * (m_animNum - 1)), false);
		SetScriptParams(ang, m_speed);
		
		PhysicsBody@ bdy = m_unit.GetPhysicsBody();
		bdy.SetLinearVelocity(dir * m_speed);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal) override
	{
		if (m_unit.IsDestroyed())
			return;

		if (!ShouldCollide(unit, pos, m_dir, m_owner, m_selfDmg, m_teamDmg))
			return;

		IDamageTaker@ dt = cast<IDamageTaker>(unit.GetScriptBehavior());
		if (dt !is null && m_penetration > 0)
		{
			if (m_lastCollision != unit)
			{
				m_lastCollision = unit;
				ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk, m_selfDmg, m_teamDmg);

				if (--m_penetration <= 0)
					m_unit.Destroy();
			}
		}
		else
			Projectile::Collide(unit, pos, normal);
	}

	void Update(int dt) override
	{
		Projectile::Update(dt);

		float z = sin((1.0 - float(m_ttl) / float(m_maxTtl)) * PI) * m_arcHeight;
		m_unit.SetPositionZ(z, true);
	}

	void Destroyed() override
	{
		PlaySound3D(m_soundHit, m_unit.GetPosition());
	}
}
