class Projectile : ProjectileBase
{
	uint m_team;
	uint Team { get override { return m_team; } }
	Actor@ GetOwner() override { return m_owner; }

	int m_ttl;

	float m_liveRangeSq;
	vec3 m_startPos;
	
	Actor@ m_owner;
	
	AnimString@ m_anim;
	array<IEffect@>@ m_effects;
	
	vec2 m_dir;
	float m_selfDmg;
	float m_teamDmg;


	Projectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		m_ttl = GetParamInt(unit, params, "ttl", false, 5000);
		m_liveRangeSq = float(GetParamInt(unit, params, "range", false, -1));
		if (m_liveRangeSq > 0)
			m_liveRangeSq = m_liveRangeSq * m_liveRangeSq;
		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		@m_effects = LoadEffects(unit, params);
		
		auto to = GetParamString(unit, params, "team-override", false, "ERRR");
		m_team = (to == "ERRR") ? 1 : HashString(to);
	}
	
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		SetDirection(dir);
		m_intensity = intensity;
		m_husk = husk;
		PropagateWeaponInformation(m_effects, weapon);

		m_startPos = m_unit.GetPosition();
		PlaySound3D(m_soundShoot, m_unit.GetPosition());
		
		@m_owner = owner;
		if (m_owner !is null && m_team == 1)
			m_team = owner.Team;
			
		SetSeekTarget(target);

		ProjectileBase::Initialize(owner, dir, intensity, husk, target, weapon);
	}

	vec2 GetDirection() override { return m_dir; }	
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x);
		m_unit.SetUnitScene(m_anim.GetSceneName(ang), false);
		SetScriptParams(ang, m_speed);
		
		PhysicsBody@ bdy = m_unit.GetPhysicsBody();
		bdy.SetLinearVelocity(dir * m_speed);
	}
	
	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		if (m_unit.IsDestroyed())
			return;
	
		if (!ShouldCollide(unit, pos, m_dir, m_owner, m_selfDmg, m_teamDmg))
			return;
		
		ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk, m_selfDmg, m_teamDmg);
		PlaySound3D(m_soundHit, xyz(pos));
		Destroy();
	}

	void Update(int dt) override
	{
		m_ttl -= dt;
		bool died = (m_ttl <= 0);

		if (!died && m_liveRangeSq > 0)
			died = (distsq(m_startPos, m_unit.GetPosition()) >= m_liveRangeSq);

		if (died)
		{
			ApplyEffects(m_effects, m_owner, UnitPtr(), xy(m_unit.GetPosition()), m_dir, m_intensity, m_husk, m_selfDmg, m_teamDmg);
			Destroy();
		}
		
		UpdateSeeking(m_dir, dt);
		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
}
