class TornadoMovement : ActorMovement
{
	AnimString@ m_walkAnim;

	float m_maxSpeed;
	float m_minSpeed;
	float m_turnSpeed;
	float m_timeScaler;

	int m_targetingC;
	int m_maxTargetingC;
	int m_minTargetingC;
	int m_targetOffset;
	int m_timerOffset;
	int m_getTeamC;
	int m_repulsion_strength;
	int m_repulsion_radius;

	vec2 m_targetPos;
	vec2 m_force;
	array<UnitPtr> m_teamMembers;

	TornadoMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));

		m_maxSpeed = GetParamFloat(unit, params, "max-speed", false, 3);
		m_minSpeed = GetParamFloat(unit, params, "min-speed", false, 1);
		m_turnSpeed = GetParamFloat(unit, params, "turn-speed", false, 1);
		m_timeScaler = GetParamFloat(unit, params, "time-scaler", false, 1);
		m_maxTargetingC = GetParamInt(unit, params, "max-targeting-cooldown", false, 10000);
		m_minTargetingC = GetParamInt(unit, params, "min-targeting-cooldown", false, 5000);		
		m_targetOffset = GetParamInt(unit, params, "target-offset", false, 1500);
		m_repulsion_strength = GetParamInt(unit, params, "repulsion-strength", false, 50000);
		m_repulsion_radius = GetParamInt(unit, params, "repulsion-radius", false, 400);

		m_targetingC = randi(m_maxTargetingC - m_minTargetingC) + m_minTargetingC;
		m_timerOffset = randi(10000) + 1;

		m_getTeamC = 200;
		m_force = 0;
	}

	void UpdateSeeking(int dt)
	{
		m_force = 0;


		for(uint i = 0; i < m_teamMembers.length(); i++)
		{
			float distance = distsq(m_teamMembers[i].GetPosition(), m_unit.GetPosition());

			vec2 force_diff = xy(m_teamMembers[i].GetPosition()) - xy(m_unit.GetPosition());				
			vec2 force_dir = normalize(force_diff);

			m_force += force_dir * (1 / distance) * m_repulsion_strength;
		}


		if (m_behavior.m_target !is null)
		{
			vec2 mypos = xy(m_unit.GetPosition());
			vec2 diff = m_targetPos - mypos;
			vec2 dir = normalize(diff);			

			m_dir = rottowards(m_dir, atan(dir.y, dir.x), m_turnSpeed * dt / 1000.0f);
		}
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
			return;

		ActorMovement::Update(dt, isCasting);

		auto body = m_unit.GetPhysicsBody();

		/*
		if (isCasting)
		{
			body.SetStatic(true);
			body.SetLinearVelocity(vec2());
			return;
		}
		*/

		m_targetingC -= dt;
		m_getTeamC -= dt;

		if (m_targetingC <= 0)
		{	
			array<PlayerRecord@> players;
			for (uint i = 0; i < g_players.length(); i++)
			{	
				if (g_players[i].peer != 255 && !g_players[i].IsDead())
					players.insertLast(g_players[i]);
			}

			if (players.length() > 0)
			{
				int i = randi(players.length());				

				m_targetPos = xy(players[i].actor.m_unit.GetPosition()) + randdir() * randi(m_targetOffset);

				m_targetingC = randi(m_maxTargetingC - m_minTargetingC) + m_minTargetingC;
			}
		}

		if(m_getTeamC <= 0)
		{
			m_getTeamC = 200;
			GetTeam();
		}

		UpdateSeeking(dt);

		float speed = (sin((g_scene.GetTime() + m_timerOffset) / m_timeScaler) + 1) / 2 * (m_maxSpeed - m_minSpeed) + m_minSpeed;
		speed *= m_behavior.m_buffs.MoveSpeedMul();

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		body.SetStatic(false);
		body.SetLinearVelocity((vec2(cos(m_dir), sin(m_dir)) * speed) - m_force);
	}

	void GetTeam() 
	{
		array<UnitPtr>@ targets = g_scene.FetchActorsWithTeam(m_behavior.Team, xy(m_unit.GetPosition()), m_repulsion_radius);

		m_teamMembers.removeRange(0, m_teamMembers.length());

		for (uint i = 0; i < targets.length(); i++)
		{
			if (targets[i].GetUnitProducer() is m_unit.GetUnitProducer() && targets[i] != m_unit)
			{
				m_teamMembers.insertLast(targets[i]);
			}
		}
	}
}
