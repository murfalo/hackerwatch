enum MovementStates
{
	Charging = 0,
	Breaking = 1,
	Stopped = 2,
	Searching = 3
}

class ChargeMovement : ActorMovement
{
	AnimString@ m_idleAnim;
	AnimString@ m_walkAnim;
	bool m_flying;

	float m_speed;
	int m_accelerationTimer;
	int m_decelerationTimer;
	float m_turnSpeed;
	float m_currentSpeed;

	float m_crashAngle;

	int m_waitAfterSight;
	int m_waitAfterLost;

	int m_timeLimit;
	int m_timeLimitC;

	int m_visibleWait;
	int m_checkTime;
	int m_idleCheck;

	bool m_immortalCharge;
	bool m_stopWhenCasting;
	
	bool m_searchWhileBreaking;
	int m_breakTime;
	float m_arc;

	vec2 m_targetDir;
	vec2 m_goDir;

	ActorFootsteps@ m_footsteps;
	MovementStates m_state;

	bool m_wasCasting;

	ChargeMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_idleAnim = AnimString(GetParamString(unit, params, "anim-idle"));
		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));

		m_flying = GetParamBool(unit, params, "flying", false, false);
		m_searchWhileBreaking = GetParamBool(unit, params, "search-while-breaking", false, false);
		m_speed = GetParamFloat(unit, params, "speed");
		m_accelerationTimer = max(1, GetParamInt(unit, params, "acceleration-timer", false, 1));
		m_decelerationTimer = max(1, GetParamInt(unit, params, "deceleration-timer", false, 1));
		m_turnSpeed = GetParamFloat(unit, params, "turnspeed", false, 0);

		m_crashAngle = GetParamFloat(unit, params, "crashangle", false, 1.0);

		m_arc = GetParamInt(unit, params, "sight-arc", false, 90) * PI / 180.0f / 2;
		m_arc = dot(vec2(cos(0), sin(0)), vec2(cos(m_arc), sin(m_arc)));

		m_waitAfterSight = GetParamInt(unit, params, "wait-sight-time", false, 1000);
		m_waitAfterLost = GetParamInt(unit, params, "wait-after-lost", false, 1000);
		m_timeLimit = GetParamInt(unit, params, "time-limit", false, -1);

		m_immortalCharge = GetParamBool(unit, params, "immortal-while-charging", false, false);
		m_stopWhenCasting = GetParamBool(unit, params, "stop-when-casting", false, false);

		m_currentSpeed = 0;

		SwitchState(MovementStates::Searching);

%if GFX_VFX_HIGH
		auto svFootsteps = GetParamDictionary(unit, params, "footsteps", false);
		if (svFootsteps !is null)
			@m_footsteps = ActorFootsteps(unit, svFootsteps);
%endif
	}

	void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther) override
	{
		auto behavior = unit.GetScriptBehavior();

		Actor@ actor = cast<Actor>(behavior);
		Breakable@ breakable = cast<Breakable>(behavior);

		if (!m_flying && (breakable is null && (actor is null || actor.Impenetrable()) && !fxOther.IsSensor()))
		{
			auto body = m_unit.GetPhysicsBody();
			vec2 vel = body.GetLinearVelocity();

			if (abs(vel.x * normal.y - normal.x * vel.y) < m_crashAngle)
				SwitchState(MovementStates::Stopped);
		}
		else if (breakable !is null)
		{
			breakable.Damage(DamageInfo(uint8(DamageType::BLUNT), m_behavior, 35, true, true, 0), pos, normal);
		}
	}

	void ClientUpdate(int dt, vec2 dir)
	{
		auto body = m_unit.GetPhysicsBody();
		body.SetLinearVelocity(0, 0);
		body.SetStatic(true);

		if (m_immortalCharge)
			m_behavior.SetImmortal(lengthsq(dir) > 0.01);

		if (dir.x != 0 || dir.y != 0)
		{
			dir = normalize(dir);
			m_dir = atan(dir.y, dir.x);
		}

		SetWalkingAnimation(dt);

		if (m_footsteps !is null)
		{
			m_footsteps.m_facingDirection = m_dir;
			m_footsteps.Update(dt);
		}
	}
	
	bool IsCharging()
	{
		return (m_state == MovementStates::Charging || m_state == MovementStates::Breaking);
	}

	void Update(int dt, bool isCasting) override
	{
		if (isCasting && !m_wasCasting)
			m_wasCasting = true;

		if (isCasting && m_stopWhenCasting && IsCharging())
			SwitchState(MovementStates::Stopped);
	
		if (!m_enabled || isCasting)
			return;

		if (!Network::IsServer())
		{
			ClientUpdate(dt, m_unit.GetMoveDir());
			return;
		}

		if (m_behavior.m_target is null)
		{
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
			return;
		}

		vec2 diff = xy(m_behavior.m_target.m_unit.GetPosition()) - xy(m_unit.GetPosition());
		m_targetDir = normalize(diff);
		m_goDir = vec2(cos(m_dir), sin(m_dir));

		// When returning from a skill cast, reset our direction towards the target.
		// This ensures that we have the right idle animation while the Stopped state
		// is active.
		if (!isCasting && m_wasCasting)
		{
			m_wasCasting = false;
			m_dir = atan(m_targetDir.y, m_targetDir.x);
		}

		switch (m_state)
		{
			case Charging:
				UpdateCharge(dt);
				break;

			case Breaking:
				UpdateBreaking(dt);
				break;

			case Stopped:
				UpdateStopped(dt);
				break;

			case Searching:
				UpdateSearching(dt);
				break;

			default:
				PrintError("No state was found for ChargeMovement.");
		}

		float speed = m_currentSpeed;
		speed *= m_behavior.m_buffs.MoveSpeedMul();

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		m_unit.GetPhysicsBody().SetLinearVelocity(m_goDir * speed);

		if (m_immortalCharge)
			m_behavior.SetImmortal(lengthsq(m_unit.GetMoveDir()) > 0.01);

		SetWalkingAnimation(dt);

		if (m_footsteps !is null)
		{
			m_footsteps.m_facingDirection = m_dir;
			m_footsteps.Update(dt);
		}
	}

	void UpdateCharge(int dt)
	{
		float angle = m_goDir.x * m_targetDir.y - m_targetDir.x * m_goDir.y;
		float add = angle * (m_turnSpeed / 100.0) * (m_currentSpeed / m_speed);
		m_dir = (m_dir + add + PI * 2) % (PI * 2);

		m_currentSpeed += m_speed / m_accelerationTimer * dt;

		if (m_currentSpeed >= m_speed)
			m_currentSpeed = m_speed;

		if (m_timeLimit != -1)
		{
			m_timeLimitC += dt;
			if (m_timeLimitC >= m_timeLimit)
				SwitchState(MovementStates::Breaking);
		}

		if (!IsVisible())
			SwitchState(MovementStates::Breaking);
	}

	void UpdateBreaking(int dt)
	{
		m_currentSpeed -= m_speed / m_decelerationTimer * dt;

		if (IsVisible() && m_searchWhileBreaking)
			SwitchState(MovementStates::Charging);

		if (m_currentSpeed <= 0)
			SwitchState(MovementStates::Stopped);
	}

	void UpdateStopped(int dt)
	{
		m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
		m_currentSpeed = 0;

		m_breakTime += dt;

		if (m_breakTime >= m_waitAfterLost)
			SwitchState(MovementStates::Searching);
	}

	void UpdateSearching(int dt)
	{
		if (IsVisible())
			m_visibleWait += dt;
		else
			m_visibleWait = 0;		

		m_checkTime += dt;

		if (m_checkTime >= 100)
		{
			m_checkTime = 0;

			bool inSight = true;
			if (!m_flying)
			{
				auto rayResults = g_scene.Raycast(xy(m_unit.GetPosition()), xy(m_behavior.m_target.m_unit.GetPosition()), ~0, RaycastType::Aim);
				for (uint i = 0; i < rayResults.length(); i++)
				{
					UnitPtr ray_unit = rayResults[i].FetchUnit(g_scene);

					if (!ray_unit.IsValid())
						continue;

					Actor@ a = cast<Actor>(ray_unit.GetScriptBehavior());
					if (a is null or a.Impenetrable())
					{
						inSight = false;
						break;
					}
				}
			}

			if (inSight)
			{
				m_dir = atan(m_targetDir.y, m_targetDir.x);

				if (m_visibleWait >= m_waitAfterSight)
					SwitchState(MovementStates::Charging);
			}
		}
	}

	bool IsVisible()
	{
		return (dot(m_goDir, m_targetDir) > m_arc);
	}
		
	void SwitchState(MovementStates state)
	{
		m_state = state;
		m_visibleWait = 0;
		m_breakTime = 0;
		m_timeLimitC = 0;
	}
	
	void SetWalkingAnimation(int dt)
	{
		if (lengthsq(m_unit.GetMoveDir()) < 0.01)
			m_idleCheck += dt;
		else
			m_idleCheck = 0;

		if (m_idleCheck >= 100)
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
		else
			m_unit.SetUnitScene(m_walkAnim.GetSceneName(m_dir), false);
	}
}
