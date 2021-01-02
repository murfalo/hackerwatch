class MeleeFollowerMovement : MeleeMovement
{
	int m_runBackDistSq;
	int m_roamingDistSq;
	float m_runBackSpeed;
	bool m_runningBack;
	PlayerOwnedActor@ m_ownedBehavior = null;

	MeleeFollowerMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_speed = max(0.0, GetParamFloat(unit, params, "speed", true));
		m_roaming = GetParamFloat(unit, params, "roaming", false, 1.0f);
		m_runBackSpeed = GetParamFloat(unit, params, "run-back-speed", false, 4.0f);
		m_roamingDistSq = GetParamInt(unit, params, "roaming-distance", false, 20);
		m_runBackDistSq = GetParamInt(unit, params, "run-back-distance", false, 200);

		m_stagger = 0;
		m_origPos = xy(unit.GetPosition());
		m_idleTarget = m_origPos;
		m_newIdleTargetC = randi(1000);
		m_runningBack = false;
		m_pathFollower.m_maxRange = -1;
		m_roamingDistSq *= m_roamingDistSq;
		m_runBackDistSq *= m_runBackDistSq;

	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		MeleeMovement::Initialize(unit, behavior);
		m_pathFollower.Initialize(unit, m_behavior.m_maxRange, m_flying);

		@m_ownedBehavior = cast<PlayerOwnedActor>(m_behavior);

		// if (m_standDist <= 0)
			// m_standDist = m_pathFollower.m_unitRadius + 10;
	}

	void QueuedPathfind(array<vec2>@ path) override
	{
		m_pathFollower.QueuedPathfind(path);
		if (m_pathFollower.m_path is null && m_behavior.m_target is null)
		{
			bool hasOwner = (
				m_ownedBehavior !is null &&
				m_ownedBehavior.m_ownerRecord !is null &&
				m_ownedBehavior.m_ownerRecord.actor !is null
			);

			if (hasOwner)
			{
				vec2 playerPos = xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition());
				m_unit.SetPosition(playerPos.x, playerPos.y, 0, false);
			}
		}
	}

	bool IdleUpdate(int dt, float speed) override
	{
		bool noTarget = m_behavior.m_target is null;
		bool hasOwner = (
			m_ownedBehavior !is null &&
			m_ownedBehavior.m_ownerRecord !is null &&
			m_ownedBehavior.m_ownerRecord.actor !is null
		);
		
		if (!noTarget && hasOwner)
		{
			if (distsq(m_ownedBehavior.m_ownerRecord.actor.m_unit, m_behavior.m_target) > m_runBackDistSq)
				noTarget = true;
		}
		
		if (speed == 0 || (noTarget && m_roaming <= 0))
		{
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
			return true;
		}

		if (noTarget)
		{
			auto body = m_unit.GetPhysicsBody();
			float dis = distsq(m_idleTarget, xy(m_unit.GetPosition()));

			m_newIdleTargetC -= dt;
			if (m_newIdleTargetC <= 0)
			{
				float len = randf() * 100 * m_roaming;
				vec2 dr = randdir();
				m_newIdleTargetC = 2000 + randi(2000 + int(max(0.0f, 1.0f - m_roaming) * 12000));

				vec2 basePos = m_origPos;

				if (hasOwner)
				{
					basePos = xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition());
					m_newIdleTargetC = 750 + randi(750);
				}

				m_idleTarget = basePos + vec2(dr.x * len, (dr.y * 0.66 - 0.33) * len);
			}

			if (dis <= m_roamingDistSq)
			{
				body.SetLinearVelocity(0, 0);
				m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
				return true;
			}
			else
				speed *= m_roaming;


			body.SetStatic(false);
			vec2 dir = m_pathFollower.FollowPath(xy(m_unit.GetPosition()), m_idleTarget) * speed * CalcDirSpeed();

			dir = ModifyDir(dir, speed, dt);

			if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
				m_dir = atan(dir.y, dir.x);
			else
				m_dir = m_pathFollower.m_visualDir;

			m_dir = atan(dir.y, dir.x);
			body.SetLinearVelocity(dir);
			SetWalkingAnimation();

			if (m_footsteps !is null)
			{
				m_footsteps.m_facingDirection = m_dir;
				m_footsteps.Update(dt);
			}

			return true;
		}

		return false;
	}

	bool RunBackUpdate(int dt, float speed)
	{
		if (m_ownedBehavior !is null && m_ownedBehavior.m_ownerRecord !is null && m_ownedBehavior.m_ownerRecord.actor !is null)
		{
			vec2 playerPos = xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition());
			float dis = distsq(playerPos, xy(m_unit.GetPosition()));

			if(dis <= m_roamingDistSq) 
			{
				m_runningBack = false;
			}

			if(dis > m_runBackDistSq || m_runningBack)
			{
				m_runningBack = true;

				auto body = m_unit.GetPhysicsBody();

				body.SetStatic(false);
				vec2 dir = m_pathFollower.FollowPath(xy(m_unit.GetPosition()), playerPos) * m_runBackSpeed * CalcDirSpeed();

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

				return true;
			}

		}

		return false;
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

		float speed = m_speed;// + pow(g_ngp + 1.0f, 0.1f) - 1.0f;
		
		if (m_stagger > 0)
		{
			m_stagger -= dt;
			speed *= 0.5;
		}

		speed *= m_behavior.m_buffs.MoveSpeedMul();

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		if (RunBackUpdate(dt, speed))
			return;

		if (MeleeFollowerMovement::IdleUpdate(dt, speed))
			return;

		vec3 posTarget = m_behavior.m_target.m_unit.GetPosition();
		vec3 posMe = m_unit.GetPosition();

		auto body = m_unit.GetPhysicsBody();

		body.SetStatic(false);

		vec2 dir = m_pathFollower.FollowPath(xy(posMe), xy(posTarget)) * speed * CalcDirSpeed();

		dir = ModifyDir(dir, speed, dt);

		if(m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
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
	}
}
