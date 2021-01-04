class BossWormSegment : CompositeActorBehavior, IOwnedUnit
{
	int m_ttl;
	float m_speed;
	vec3 m_dir;

	BossWormSegment(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_ttl = GetParamInt(unit, params, "ttl", false, -1);
		
		int moveDist = GetParamInt(unit, params, "move-dist", false, 0);
		m_speed = moveDist / float(m_ttl);
		
		m_unit.SetUpdateDistanceLimit(0);
	}
	
	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		m_transferTarget = owner.m_unit;
		m_unit.SetShouldCollideWithTeam(false);
		
		auto dir = cast<CompositeActorBehavior>(owner).m_movement.m_dir;
		m_dir = vec3(cos(dir), sin(dir), 0);
		
		if (m_effectParams !is null)
			m_effectParams.Set("angle", dir);
	}
	
	void Update(int dt) override
	{
		CompositeActorBehavior::Update(dt);
		
		if (m_ttl > 0 && !IsDead())
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
				OnDeath(DamageInfo(0, null, 1, false, true, 0), vec2(1, 0));
		}
		
		auto p1 = m_unit.GetPosition();
		auto p2 = p1 + m_dir * m_speed * dt;
		
		m_unit.SetPosition(p2);
	}
}
