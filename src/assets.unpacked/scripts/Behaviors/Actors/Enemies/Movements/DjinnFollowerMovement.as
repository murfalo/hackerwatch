class DjinnFollowerMovement : DjinnMovement
{
	int m_runBackDistSq;
	int m_roamingDistSq;
	int m_idleTimer;
	PlayerOwnedActor@ m_ownedBehavior;

	DjinnFollowerMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_roamingDistSq = GetParamInt(unit, params, "roaming-distance", false, 20);
		m_runBackDistSq = GetParamInt(unit, params, "blink-back-distance", false, 200);

		m_roamingDistSq *= m_roamingDistSq;
		m_runBackDistSq *= m_runBackDistSq;

	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		DjinnMovement::Initialize(unit, behavior);

		@m_ownedBehavior = cast<PlayerOwnedActor>(m_behavior);

		m_newIdleTargetC = 500;
	}

	bool BlinkBackUpdate()
	{
		if (m_ownedBehavior !is null && m_ownedBehavior.m_ownerRecord.actor !is null)
		{
			float dis = distsq(xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition()), xy(m_unit.GetPosition()));
			if (dis > m_runBackDistSq)
			{
				vec2 plrPos = xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition());
				m_blinkCooldownC = 0;
				DjinnMovement::BlinkToTarget(plrPos, false);

				float len = randf() * 100 * m_roaming;
				vec2 dr = randdir();
				m_idleTarget = plrPos * len;
				m_dir = atan(dr.y, dr.x);
				return true;
			}
		}

		return false;
	}

	bool IdleUpdate(int dt, float speed) override
	{
		if (BlinkBackUpdate())
			return true;
		
		bool noTarget = m_behavior.m_target is null;
		auto body = m_unit.GetPhysicsBody();
		
		if (!noTarget && m_ownedBehavior !is null && m_ownedBehavior.m_ownerRecord.actor !is null)
		{
			if (distsq(m_ownedBehavior.m_ownerRecord.actor.m_unit, m_behavior.m_target) > m_runBackDistSq)
				noTarget = true;
		}

		if (speed == 0 || (noTarget && m_roaming <= 0))
		{
			body.SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
			return true;
		}

		m_idleTimer += dt;
		if (m_idleTimer <= 750 && noTarget)
		{
			body.SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
			return true;
		}

		if (noTarget)
		{			
			float dis = distsq(m_idleTarget, xy(m_unit.GetPosition()));

			m_newIdleTargetC -= dt;
			if (m_newIdleTargetC <= 0)
			{
				float len = randf() * 100 * m_roaming;
				vec2 dr = randdir();
				m_newIdleTargetC = 2000 + randi(2000 + int(max(0.0f, 1.0f - m_roaming) * 12000));

				vec2 basePos = m_origPos;

				if (m_ownedBehavior !is null && m_ownedBehavior.m_ownerRecord.actor !is null)
				{
					basePos = xy(m_ownedBehavior.m_ownerRecord.actor.m_unit.GetPosition());
					m_newIdleTargetC = 750 + randi(750);
				}

				m_idleTarget = basePos + vec2(dr.x * len, (dr.y * 0.66 - 0.33) * len);

				auto results = g_scene.RaycastClosest(basePos, m_idleTarget, ~0, RaycastType::Any);

				if (results.FetchUnit(g_scene).IsValid())
				{
					m_idleTarget = results.point;
				}
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
			vec2 dir = m_pathFollower.FollowPath(xy(m_unit.GetPosition()), m_idleTarget) * speed;

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

		m_idleTimer = 0;
		return false;
	}
}
