/*
Here's how this works:

1. Raycast towards X sides with a certain length (test-distance) - up, down, left, right.
2. Find the distances of each point towards the player.
3. Eliminate the directions that makes us the closest to the player. (dot-scale)
4. If there's a spot available that is hidden from player's line of sight, prefer that.
5. Otherwise, prefer the direction that makes us the furthest away from the player.
6. Move towards the direction, making sure not to get stuck by automatically recalculating after standing still for 200ms.
7. Stop moving when reaching certain distance near target point, and find new point. (stop-distance)
*/

uint GetFleeRaycastSlots()
{
	uint ret = 0;
	ret |= Resources::GetSlot("doodad");
	ret |= 1; // Colliders, they are unnamed in engine
	return ret;
}

class FleeTestResult
{
	vec2 m_pos;
	float m_distToPlayerSq;
}

class FleeMovement : MeleeMovement
{
	float m_testDistance;
	float m_testDistanceRandom;
	float m_stopDistance;
	float m_dotScale;
	float m_scatterAngle;
	int m_testCount;

	int m_reactionC;
	int m_reaction;
	int m_reactionRandom;

	vec2 m_targetPoint;
	bool m_hasTargetPoint;
	int m_hasTargetTime;

	FleeMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_testDistance = GetParamFloat(unit, params, "test-distance", false, 100);
		m_testDistanceRandom = GetParamFloat(unit, params, "test-distance-rand", false, 0);
		m_stopDistance = GetParamFloat(unit, params, "stop-distance", false, 10);
		m_dotScale = GetParamFloat(unit, params, "dot-scale", false, -0.5);
		m_scatterAngle = GetParamFloat(unit, params, "scatter-angle", false, 0.2f);
		m_testCount = GetParamInt(unit, params, "test-count", false, 12);
		m_reaction = GetParamInt(unit, params, "reaction", false);
		m_reactionRandom = GetParamInt(unit, params, "reaction-rand", false);
	}

	FleeTestResult@ TestDirection(float rad)
	{
		vec2 posMe = xy(m_unit.GetPosition());
		vec2 posPlayer = xy(m_behavior.m_target.m_unit.GetPosition());

		vec2 dir = vec2(cos(rad), sin(rad));
		vec2 posTo = posMe + dir * (m_testDistance + randf() * m_testDistanceRandom);

		RaycastResult res = rayClosestFromUnit(m_unit, posTo, GetFleeRaycastSlots(), RaycastType::Any);

		FleeTestResult@ ret = FleeTestResult();
		if (res.FetchUnit(g_scene).IsValid())
			ret.m_pos = res.point;
		else
			ret.m_pos = posTo;
		ret.m_distToPlayerSq = distsq(posPlayer, ret.m_pos);
		return ret;
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
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

		if (isCasting)
			return;

		if (speed == 0 || m_behavior.m_target is null)
		{
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
			return;
		}

		vec2 posMe = xy(m_unit.GetPosition());
		vec2 posPlayer = xy(m_behavior.m_target.m_unit.GetPosition());
		vec2 dir = normalize(posMe - posPlayer);

		uint raySlotsMask = GetFleeRaycastSlots();

		if (!m_hasTargetPoint)
		{
			//TODO: This keeps casting rays every frame if we're stuck in a corner with nowhere to go
			m_hasTargetTime = 0;

			vec2 hiddenPos = vec2();
			bool hidden = false;

			vec2 furthestPos = vec2();
			float furthest = 0;

			float radStep = 2.0 / float(m_testCount);
			for (int i = 0; i < m_testCount; i++)
			{
				float scatter = randf() * m_scatterAngle;
				float rad = scatter + PI * (i * radStep);
				vec2 testDir = vec2(cos(rad), sin(rad));
				if (dot(dir, testDir) < m_dotScale)
					continue;

				FleeTestResult@ res = TestDirection(rad);
				if (res.m_distToPlayerSq > furthest)
				{
					furthest = res.m_distToPlayerSq;
					furthestPos = res.m_pos;
				}

				if (!hidden && !rayCanSeeWithoutUnit(res.m_pos, m_behavior.m_target.m_unit, m_unit, raySlotsMask))
				{
					hidden = true;
					hiddenPos = res.m_pos;
				}
			}

			if (hidden)
			{
				m_targetPoint = hiddenPos;
				m_hasTargetPoint = true;
			}
			else
			{
				m_targetPoint = furthestPos;
				m_hasTargetPoint = true;
			}

			m_reactionC = m_reaction + randi(m_reactionRandom);
		}

		if (m_hasTargetPoint)
		{
			auto body = m_unit.GetPhysicsBody();

			if (m_reactionC > 0)
			{
				m_reactionC -= dt;
				if (m_reactionC > 0)
				{
					body.SetLinearVelocity(vec2());
					return;
				}
			}

			m_hasTargetTime += dt;
			//TODO: Limit time that can be spent running away?

			// If after a while we're stuck
			if (m_hasTargetTime > 200 && length(body.GetLinearVelocity()) < 1)
			{
				// We need a new target position
				m_hasTargetPoint = false;
			}
			else
			{
				// Navigate to target position
				vec2 pathDir = normalize(m_targetPoint - posMe) * speed;
				if (pathDir.x != 0 || pathDir.y != 0)
				{
					body.SetLinearVelocity(pathDir);
					m_dir = atan(pathDir.y, pathDir.x);
				}

				SetWalkingAnimation();

				if (m_footsteps !is null)
				{
					m_footsteps.m_facingDirection = m_dir;
					m_footsteps.Update(dt);
				}

				float distance = distsq(posMe, m_targetPoint);

				if (distance <= m_stopDistance * m_stopDistance)
				{
					m_hasTargetPoint = false;
					if (!rayCanSee(m_unit, m_behavior.m_target.m_unit, RaycastType::Any))
						m_behavior.SetTarget(null);
				}
			}
		}
	}
}
