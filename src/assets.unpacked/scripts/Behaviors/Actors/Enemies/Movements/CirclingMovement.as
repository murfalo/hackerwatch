class CirclingMovement : MeleeMovement
{
	int m_circleDist;
	int m_circleDir;
	int m_lastCircleDir;
	int m_tmDistCheckExtraDelay;
	int m_tmDistCheck;
	int m_circleDirDegree;
	int m_tmFetchCheck;
	int m_degreesMultiplier;
	
	uint m_cachedRayCanSeeTime;
    bool m_cachedRayCanSee;
	
	
	CirclingMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_circleDist = GetParamInt(unit, params, "circle-dist", false, 0);
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		MeleeMovement::Initialize(unit, behavior);
		
		if (m_circleDist <= 0)
			m_circleDist = int(m_standDist * 5);
	}

	vec2 GetMoveDir(float dirAngle)
	{
		m_circleDirDegree = min(20 + m_degreesMultiplier * 7, 65);

		float moveToDir = dirAngle + m_circleDir * m_circleDirDegree * (PI / 180);
		return vec2(cos(moveToDir), sin(moveToDir));
	}

	bool IsRayPathable(vec2 from, vec2 to, RaycastType type = RaycastType::Any)
	{
		auto results = g_scene.Raycast(from, to, ~0, type);

		for(uint i = 0; i < results.length(); i++)
		{
			auto rayRes = results[i];
			UnitPtr unit = rayRes.FetchUnit(g_scene);

			if (!unit.IsValid() || unit == m_unit)
				continue;

			if(rayRes.fixture.IsSensor())
				continue;

			return false;
		}

		return true;
	}

	void FetchActors(vec2 origin, uint radius)
	{
		array<UnitPtr>@ units = g_scene.FetchActorsWithTeam(m_behavior.Team, origin, radius);
		array<CirclingMovement@>  movements;
		
		for (uint i = 0; i < units.length(); i++)
		{
			if (!units[i].IsValid())
				continue;

			auto act = cast<CompositeActorBehavior>(units[i].GetScriptBehavior());

			if (act is null)
				continue;

			auto movement = cast<CirclingMovement>(act.m_movement);

			if (movement !is null)
				movements.insertLast(movement);
		}

		for (uint i = 0; i < movements.length(); i++)
		{
			movements[i].m_degreesMultiplier = movements.length();//1 + randi(2 + movements.length());
			movements[i].m_tmFetchCheck = 3000 + randi(3000);
		}
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled || isCasting)
			return;

		ActorMovement::Update(dt, isCasting);

		if (!Network::IsServer())
		{
			ClientUpdate(dt, isCasting, m_unit.GetMoveDir());
			return;
		}

		float speed = m_speed;

		if (m_stagger > 0)
		{
			m_stagger -= dt;
			speed *= 0.5;
		}

		speed *= m_behavior.m_buffs.MoveSpeedMul();

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		if (MeleeMovement::IdleUpdate(dt, speed))
			return;

		vec3 posTarget = m_behavior.m_target.m_unit.GetPosition();
		vec3 posMe = m_unit.GetPosition();

		auto body = m_unit.GetPhysicsBody();

		float distSq = lengthsq(posMe - posTarget);
		if (distSq <= m_standDist * m_standDist)
		{
			vec2 dir = normalize(xy(posTarget - posMe));
			m_dir = atan(dir.y, dir.x);

			body.SetLinearVelocity(0, 0);
			body.SetStatic(true);

			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);

			return;
		}
 		else if (distSq <= m_circleDist * m_circleDist && (!m_behavior.m_buffs.Confuse() || m_behavior.m_buffs.AntiConfuse()))
		{
			body.SetStatic(false);

			m_tmFetchCheck -= dt;
			if (m_tmFetchCheck <= 0)
				FetchActors(xy(posMe), 50);

			vec2 dir = normalize(xy(posTarget - posMe));
			float dirAngle = atan(dir.y, dir.x);

			if (m_circleDir == 0 && Network::IsServer())
			{
				m_circleDir = (randi(2) == 0 ? -1 : 1);
				//(Network::Message("UnitMovementCircleDir") << m_unit << m_circleDir << xy(posMe)).SendToAll();
			}

			vec2 moveDir = GetMoveDir(dirAngle);

			m_tmDistCheck -= dt;
			if (m_tmDistCheck <= 0)
			{
				if (!IsRayPathable(xy(posMe), xy(posMe) + moveDir * 10))
				{
					m_circleDir *= -1;
					moveDir = GetMoveDir(dirAngle);

					if (!IsRayPathable(xy(posMe), xy(posMe) + moveDir * 10))
					{
						m_circleDir = 0;

						moveDir = GetMoveDir(dirAngle);
					}
				}

				if (m_lastCircleDir == m_circleDir)
					m_tmDistCheckExtraDelay -= 3;
				else
					m_tmDistCheckExtraDelay++;

				m_tmDistCheckExtraDelay = clamp(m_tmDistCheckExtraDelay, 0, 10);

				m_tmDistCheck = 100 + m_tmDistCheckExtraDelay * 100;
			}

			auto currTime = g_scene.GetTime();
			if (m_cachedRayCanSeeTime < currTime)
			{
				m_cachedRayCanSeeTime = currTime + 100 + randi(100);
				m_cachedRayCanSee = rayCanSee(m_unit, m_behavior.m_target.m_unit, RaycastType::Any);
			}

			if (m_cachedRayCanSee)
			{
				body.SetLinearVelocity(moveDir * speed);
				m_dir = atan(moveDir.y, moveDir.x);
				m_lastCircleDir = m_circleDir;

				SetWalkingAnimation();

				if (m_footsteps !is null)
				{
					m_footsteps.m_facingDirection = m_dir;
					m_footsteps.Update(dt);
				}
				
				m_dir = dirAngle; // Is used to rotate enemies towards the target when casting.

				return;
			}
		}

		m_circleDir = 0;

		body.SetStatic(false);

		vec2 dir = m_pathFollower.FollowPath(xy(posMe), xy(posTarget)) * speed * CalcDirSpeed();

		dir = ModifyDir(dir, speed, dt);

		if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
			m_dir = atan(dir.y, dir.x);
		else
			m_dir = m_pathFollower.m_visualDir;

		body.SetLinearVelocity(dir);
		SetWalkingAnimation();

		if (m_footsteps !is null)
		{
			m_footsteps.m_facingDirection = m_dir;
			m_footsteps.Update(dt);
		}

		vec2 castDir = normalize(xy(posTarget) - xy(posMe));
		float castAngle = atan(castDir.y, castDir.x);
	}
}
