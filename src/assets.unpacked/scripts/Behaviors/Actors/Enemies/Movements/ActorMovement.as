class ActorMovement
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;

	bool m_enabled;
	float m_confuseAngle;
	
	
	float m_rotSpeed;
	private float m_dirCurr;
	private float m_dirTarget;
	float m_dir
	{
		get { return m_dirCurr; }
		set 
		{ 
			m_dirTarget = value;
			if (m_rotSpeed >= 95)
				m_dirCurr = value;
		}
	}
	
	ActorMovement(UnitPtr unit, SValue& params)
	{
		m_rotSpeed = 100; //GetParamFloat(unit, params, "rot-speed", false, 100);
		m_dirCurr = m_dirTarget = randf() * PI * 2;
		m_enabled = true;
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior)
	{
		m_unit = unit;
		@m_behavior = behavior;
		
		//m_unit.SetShouldCollideWithSame(false);
		
		auto body = m_unit.GetPhysicsBody();
		if (body !is null and !body.IsStatic())
		{
			vec3 pos = unit.GetPosition();
			pos.x += randf() / 100.0;
			pos.y += randf() / 100.0;
			unit.SetPosition(pos);
		}
	}

	void OnDeath(DamageInfo di, vec2 dir) {}

	SValue@ Save() { return null; }
	void Load(SValue@ sval) {}
	void PostLoad(SValue@ sval) {}
	
	void MakeAggro() {}
	void OnDamaged(DamageInfo dmg) {}
	void QueuedPathfind(array<vec2>@ path) {}
	bool IsCasting() { return false; }
	
	void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther) {}
	
	void Update(int dt, bool isCasting)
	{
		if (!isCasting)
		{
			if (m_dirCurr != m_dirTarget)
				m_dirCurr = rottowards(m_dirCurr, m_dirTarget, m_rotSpeed * dt / 1000.0f);
		}
	}

	vec2 ModifyDir(vec2 dir, float speed, int dt)
	{
		vec2 ret = dir;

		// Confusion
		if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
		{
			m_confuseAngle += 0.025;
			ret = addrot(ret, sin(m_confuseAngle) * 1.5) * speed * 0.8;
		}

		// Slippery
		float slippery = m_behavior.m_buffs.MoveSlipperyMul();
		if (slippery < 1.0f)
		{
			auto body = m_behavior.m_unit.GetPhysicsBody();
			if (body !is null)
			{
				vec2 currentVelocity = body.GetLinearVelocity();
				ret = lerp(currentVelocity, ret, slippery * (dt / 1000.0f));
			}
		}

		return ret;
	}
}
