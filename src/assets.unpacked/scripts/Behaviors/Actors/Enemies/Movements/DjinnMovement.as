class DjinnMovement : MeleeMovement
{
	AnimString@ m_emptyAnim;
	UnitScene@ m_blinkEffect;
	vec2 m_targetPos;
	int m_targetPosVerifyCd;
	int m_stuckC;
	int m_rayLength;
	int m_minBlinkDis;
	int m_blinkCountdown;
	int m_blinkDelay;
	int m_blinkCooldown;
	int m_blinkCooldownC;
	bool m_shouldBeTargetable;
	bool m_strafing;

	DjinnMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_strafing = GetParamBool(unit, params, "strafing", false, true);
		m_rayLength = GetParamInt(unit, params, "max-blink-dis", false, 100);
		m_minBlinkDis = GetParamInt(unit, params, "min-blink-dis", false, 25);
		m_blinkDelay = GetParamInt(unit, params, "blink-delay", false, 0);
		@m_blinkEffect = Resources::GetEffect(GetParamString(UnitPtr(), params, "blink-fx", false, ""));
		@m_emptyAnim = AnimString(GetParamString(unit, params, "anim-blink", false, ""));
		m_blinkCooldown = GetParamInt(unit, params, "blink-cooldown", false, 0);
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		MeleeMovement::Initialize(unit, behavior);
		unit.SetShouldCollideWithSame(false);
		m_shouldBeTargetable = m_behavior.m_targetable;
		m_blinkCooldownC = m_blinkCooldown;
	}

	bool IsCasting() override
	{
		return (m_blinkCountdown > 0);
	}

	void NetBlink(vec2 pos)
	{
		PlayEffect(m_blinkEffect, xy(m_unit.GetPosition()));
		
		if (m_blinkDelay > 0)
		{
			m_blinkCountdown = m_blinkDelay;
			m_unit.SetUnitScene(m_emptyAnim.GetSceneName(m_dir), true);
			m_behavior.m_targetable = false;
		}
		else
			PlayEffect(m_blinkEffect, pos);
	}

	void BlinkToTarget(vec2 targetPos, bool safePos)
	{
		if (!Network::IsServer())
			return;

		if (m_blinkCooldownC > 0)
			return;
		
		if (!safePos)
		{
			vec2 dir = randdir();
			uint nrOfRays = 5;

			for (uint i = 0; i < nrOfRays; i++)
			{
				auto results = g_scene.Raycast(targetPos, targetPos + dir * m_rayLength, ~0, RaycastType::Any);
				bool success = false;

				for (uint j = 0; j < results.length(); j++)
				{
					auto teleRes = results[j];
					UnitPtr unit = teleRes.FetchUnit(g_scene);
					auto act = cast<Actor>(unit.GetScriptBehavior());

					if (!unit.IsValid() || unit == m_unit)
						continue;

					if (act !is null && !act.Impenetrable() && act.Team == m_behavior.Team)
						continue;

					success = true;

					if ((m_rayLength * teleRes.fraction) < m_minBlinkDis) // If ray intersects too close, we discard the results.
						break;

					targetPos = teleRes.point - dir * 10;
					i = nrOfRays;
					break;
				}

				if (!success)
				{
					int randOffset = randi(m_rayLength - m_minBlinkDis) + m_minBlinkDis;
					targetPos = targetPos + dir * randOffset;
					i = nrOfRays;
					break;
				}

				dir = addrot(dir, 360 / (nrOfRays + 1) * PI / 180);
			}
		}

		(Network::Message("DjinnBlink") << m_unit << targetPos).SendToAll();

		PlayEffect(m_blinkEffect, xy(m_unit.GetPosition()));
		m_unit.SetPosition(xyz(targetPos));
		m_blinkCooldownC = m_blinkCooldown;
		if (m_blinkDelay > 0)
		{
			m_blinkCountdown = m_blinkDelay;
			m_unit.SetUnitScene(m_emptyAnim.GetSceneName(m_dir), true);
			m_behavior.m_targetable = false;
		}
		else
			PlayEffect(m_blinkEffect, xy(m_unit.GetPosition()));

		m_pathFollower.QueuedPathfind(null);		
	}

	void QueuedPathfind(array<vec2>@ path) override
	{
		bool doBlink = false;
		if (m_behavior.m_target !is null)
		{
			if (path.length() > 1)
			{
				int len = min(500, int(dist(path[0], path[path.length() - 1]) * 1.33f));

				for (int i = 0; i < int(path.length()) - 1; i++)
				{
					len -= int(dist(path[i], path[i + 1]));

					if (len <= 0)
					{
						doBlink = true;
						break;
					}
				}
			}
			else
				doBlink = true;
		}

		if (doBlink)
		{
			vec2 pos;
			bool safeStatus;

			if (m_behavior.m_target is null)
			{
				pos = path[path.length() - 1];
				safeStatus = true;
			}
			else
			{
				pos = xy(m_behavior.m_target.m_unit.GetPosition());
				safeStatus = false;
			}

			BlinkToTarget(pos, safeStatus);
		}
		else
			m_pathFollower.QueuedPathfind(path);
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

		RaycastResult res = g_scene.RaycastClosest(xy(m_unit.GetPosition()), xy(m_behavior.m_target.m_unit.GetPosition()), ~0, RaycastType::Aim);
		UnitPtr res_unit = res.FetchUnit(g_scene);

		if (res_unit.IsValid() && res_unit != m_behavior.m_target.m_unit)
			return false;

		return true;
	}
	
	bool UpdateBlinking(int dt)
	{
		if (m_blinkCountdown > 0)
		{
			m_unit.SetUnitScene(m_emptyAnim.GetSceneName(m_dir), false);
			m_blinkCountdown -= dt;
			if (m_blinkCountdown <= 0)
			{
				m_behavior.m_targetable = m_shouldBeTargetable;
				m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
				PlayEffect(m_blinkEffect, xy(m_unit.GetPosition()));
			}
		}
		
		return (m_blinkCountdown > 0);
	}
	
	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled || (isCasting && !IsCasting()))
			return;

		if (UpdateBlinking(dt))
			return;
		
		if (m_blinkCooldownC > 0)
			m_blinkCooldownC -= dt;
		
		ActorMovement::Update(dt, isCasting);

		if (!Network::IsServer())
		{
			if (SeesTarget() && m_strafing)
				ClientUpdate(dt, isCasting, xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			else
				ClientUpdate(dt, isCasting, m_unit.GetMoveDir());

			return;
		}

		float speed = m_speed * m_behavior.m_buffs.MoveSpeedMul();// + pow(g_ngp + 1.0f, 0.1f) - 1.0f;

		if (m_stagger > 0)
		{
			m_stagger -= dt;
			speed *= 0.5;
		}

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		if (IdleUpdate(dt, speed))
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
		bool seesTarget = SeesTarget();

		if (distsq(xy(m_unit.GetPosition()), m_targetPos) <= 5 * 5)
		{
			if (seesTarget)
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

			vec2 dir = m_pathFollower.FollowPath(xy(m_unit.GetPosition()), m_targetPos) * speed;

			dir = ModifyDir(dir, speed, dt);

			if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
				m_dir = atan(dir.y, dir.x);
			else if (seesTarget && m_strafing)
			{
				auto dr = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
				m_dir = atan(dr.y, dr.x);
			}
			else
			{
				m_dir = m_pathFollower.m_visualDir;
			}

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
