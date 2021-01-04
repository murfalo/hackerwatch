class RangedMovement : MeleeMovement
{
	vec2 m_targetPos;
	int m_targetPosVerifyCd;
	int m_stuckC;
	bool m_strafing;

	uint m_cachedRayCanSeeTime;
    bool m_cachedRayCanSee;

	
	RangedMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_strafing = GetParamBool(unit, params, "strafing", false, true);
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		MeleeMovement::Initialize(unit, behavior);
		unit.SetShouldCollideWithSame(false);
	}
	
	bool IsStandPosValid(vec2 pos, bool checkMinDist)
	{
		float dsq = distsq(pos, xy(m_behavior.m_target.m_unit.GetPosition()));
		if (dsq > m_standDist * m_standDist)
			return false;
			
		if (checkMinDist && dsq < m_minDist * m_minDist)
			return false;
	
		RaycastResult res = g_scene.RaycastClosest(pos, xy(m_behavior.m_target.m_unit.GetPosition()), ~0, RaycastType::Aim);
		UnitPtr res_unit = res.FetchUnit(g_scene);

		if (!res_unit.IsValid())
			return true;

		return (res_unit == m_behavior.m_target.m_unit);
	}
	
	bool SeesTarget()
	{
		if (m_behavior.m_target is null)
			return false;
	
		auto currTime = g_scene.GetTime();
		if (m_cachedRayCanSeeTime < currTime)
		{
			RaycastResult res = g_scene.RaycastClosest(xy(m_unit.GetPosition()), xy(m_behavior.m_target.m_unit.GetPosition()), ~0, RaycastType::Aim);
			UnitPtr res_unit = res.FetchUnit(g_scene);
			
			m_cachedRayCanSee = !(res_unit.IsValid() && res_unit != m_behavior.m_target.m_unit);
			m_cachedRayCanSeeTime = currTime + 200 + randi(100);
		}
		
		if (!m_cachedRayCanSee)
			return false;

		return true;
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled || isCasting)
			return;
			
		ActorMovement::Update(dt, isCasting);
			
		if (!Network::IsServer())
		{
			if (m_strafing && SeesTarget())
				ClientUpdate(dt, isCasting, xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			else
				ClientUpdate(dt, isCasting, m_unit.GetMoveDir());

			return;
		}
		
		float speed = m_speed * m_behavior.m_buffs.MoveSpeedMul();
		if (m_stagger > 0)
		{
			m_stagger -= dt;
			speed *= 0.5;
		}

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;
		
		if (MeleeMovement::IdleUpdate(dt, speed))
			return;
		
		m_targetPosVerifyCd -= dt;
	
		bool validStandPos = !(m_targetPos.x == 0 && m_targetPos.y == 0);
		if (validStandPos && m_targetPosVerifyCd <= 0) // raycast cooldown
		{
			if (m_pathFollower.m_path is null)
				validStandPos = false;
			else
				validStandPos = IsStandPosValid(m_targetPos, true);
				
			m_targetPosVerifyCd = 750 + randi(500);
		}

		if (m_stuckC >= 200)
		{
			m_stuckC = 0;
			validStandPos = false;
		}
		
		if (!validStandPos)
		{
			//m_targetPos = vec2();
			for (uint i = 0; i < 4; i++)
			{
				vec2 from = xy(m_behavior.m_target.m_unit.GetPosition());
				vec2 dir = normalize(from - xy(m_unit.GetPosition()));
				float ang = atan(dir.y, dir.x) + (randf() - 0.5) * PI + PI;
				vec2 to = from + vec2(cos(ang), sin(ang)) * max(m_standDist * 0.8, (m_standDist + m_minDist) / 2.0);
				
				RaycastResult res = g_scene.RaycastClosest(from, to, ~0, RaycastType::Aim);
				UnitPtr res_unit = res.FetchUnit(g_scene);
				
				if (res_unit.IsValid())
					to = res.point - normalize(to - from) * 20;
			
				if (IsStandPosValid(to, false))
				{
					m_targetPos = to;
					break;
				}
			}
		}
		
		auto body = m_unit.GetPhysicsBody();
		if (distsq(xy(m_unit.GetPosition()), m_targetPos) <= 5 * 5)
		{
			if (SeesTarget())
			{
				vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
				m_dir = atan(dir.y, dir.x);
			}
			
			body.SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
		}
		else
		{
			if (lengthsq(body.GetLinearVelocity()) < 0.1f)
				m_stuckC += dt;
			else
				m_stuckC = 0;

			vec2 dir = m_pathFollower.FollowPath(xy(m_unit.GetPosition()), m_targetPos) * speed;// * CalcDirSpeed();

			dir = ModifyDir(dir, speed, dt);

			if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
				m_dir = atan(dir.y, dir.x);
			else if (m_strafing && SeesTarget())
			{
				auto dr = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
				m_dir = atan(dr.y, dr.x);
			}
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
}
