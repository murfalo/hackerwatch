class TargetMovement : MeleeMovement
{
	string m_targetName;
	WorldScript@ m_target;
	int m_targetFindCd;
	int m_newIdlePosTimer;
	vec3 m_targetPos;
	int m_idleRadius;
	

	TargetMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_targetName = GetParamString(unit, params, "target");
		m_idleRadius = GetParamInt(unit, params, "idle-radius", false, 0);
		unit.SetShouldCollideWithSame(false);
	}
	
	void FindTarget()
	{
		if (!Network::IsServer())
			return;
		
		if (g_scene is null)
			return;
			
		if (m_targetFindCd-- > 0)
			return;
			
		m_targetFindCd = 100;
		
		auto res = g_scene.FetchAllWorldScriptsWithComment("ScriptLink", m_targetName);
		if (res.length() > 0)
		{
			int startIdx = randi(res.length());
		
			for (uint i = 0; i < res.length(); i++)
			{
				auto script = res[(startIdx + i) % res.length()];
				if (!script.IsEnabled())
					continue;
		
				@m_target = script;
				m_targetPos = m_target.GetUnit().GetPosition();
				m_newIdlePosTimer = 1000;
				return;
			}
		}
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
			return;
			
		if (!Network::IsServer())
		{
			ClientUpdate(dt, isCasting, m_unit.GetMoveDir());
			return;
		}
		
		if (m_target is null)
			FindTarget();
		
		
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
		
		if (!isCasting)
		{
			if (m_target is null)
			{
				m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
				m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
				return;
			}
			
			vec3 posMe = m_unit.GetPosition();
			auto body = m_unit.GetPhysicsBody();

			float distSq = lengthsq(posMe - m_targetPos);
			if (distSq <= m_standDist * m_standDist)
			{
				m_newIdlePosTimer -= dt;
				if (m_newIdlePosTimer <= 0)
				{
					m_newIdlePosTimer = 1000 + randi(1000);
					m_targetPos = m_target.GetUnit().GetPosition() + xyz(randdir()) * randi(m_idleRadius);
				}
			
				vec2 dir = normalize(xy(m_targetPos - posMe));
				m_dir = atan(dir.y, dir.x);
				
				body.SetLinearVelocity(0, 0);
				m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
				
				//body.SetStatic(true);
				return;
			}

			//body.SetStatic(false);
		
			vec2 dir = m_pathFollower.FollowPath(xy(posMe), xy(m_targetPos)) * speed * CalcDirSpeed();
			
			dir = ModifyDir(dir, speed, dt);

			if (dir.x != 0 || dir.y != 0)
			{
				body.SetLinearVelocity(dir);
				m_dir = atan(dir.y, dir.x);
			}
			else
			{
				body.SetLinearVelocity(0, 0);
				m_newIdlePosTimer = 1000 + randi(1000);
				m_targetPos = m_target.GetUnit().GetPosition() + xyz(randdir()) * randi(m_idleRadius);
			}
			
			SetWalkingAnimation();
			
			if (m_footsteps !is null)
			{
				m_footsteps.m_facingDirection = m_dir;
				m_footsteps.Update(dt);
			}
		}
	}
}
