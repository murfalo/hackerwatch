class PetPathFollower
{
	array<vec2>@ m_path;
	uint m_currNode;

	int m_maxRange;
	
	UnitPtr m_owner;
	
	vec2 m_cachedTargetPos;
	vec2 m_cachedTargetFrom;
	uint m_newPathfindTime;
	
	vec2 m_lastPos;
	
	void Initialize(UnitPtr unit, int maxRange)
	{
		m_owner = unit;
		m_maxRange = maxRange;
	}
	
	void QueuedPathfind(array<vec2>@ path)
	{
		if (path is null || path.length() <= 1)
			@m_path = null;
		else
			@m_path = path;

		m_currNode = 1;
	}
	
	vec2 FollowPath(vec2 from, vec2 to, int maxRange)
	{
		if (lengthsq(to - from) <= 2 * 2)
			return vec2();

	//	if (Network::IsServer())
		{
			auto currTime = g_scene.GetTime();
			if (m_newPathfindTime < currTime || lengthsq(to - m_cachedTargetPos) > 25 * 25)
			{
				//@m_path = null;
				g_scene.QueuePathfind(m_owner, from, to, 0, maxRange);
				
				m_cachedTargetPos = to;
				m_cachedTargetFrom = from;
				m_newPathfindTime = currTime + 500 + randi(1000);
			}
		}

		if (m_path !is null)
		{	
			if (m_path.length() > m_currNode + 1)
			{
				float dt = dot(m_path[m_currNode] - m_path[m_currNode + 1], from - m_path[m_currNode + 1]);
				if (dt > 0 && dt < lengthsq(m_path[m_currNode] - m_path[m_currNode + 1]))
					m_currNode++;
			}
			else if (m_path.length() > m_currNode && lengthsq(from - m_path[m_currNode]) < 10 * 10)
				m_currNode = m_path.length();

			vec2 dir;
			if (m_path.length() > m_currNode)
				dir = m_path[m_currNode] - from;
			else
				dir = to - from;
			
			
			float l = length(dir);
			if (l > 0)
			{
				if (distsq(m_lastPos, from) <= 0.1)
				{
					m_lastPos = from;
					
					float ang = atan(dir.y, dir.x);
					float da = PI / 4.0f;
					
					auto d1 = vec2(cos(ang + da), sin(ang + da));
					auto d2 = vec2(cos(ang - da), sin(ang - da));

					bool b1 = g_scene.RaycastQuick(from, from + d1, ~0, RaycastType::Any);
					bool b2 = g_scene.RaycastQuick(from, from + d2, ~0, RaycastType::Any);
					
					if (b1 != b2)
					{
						if (b1)
							return d2;

						return d1;
					}
				}

				m_lastPos = from;
				return dir / l;
			}
			else
			{
				m_currNode++;
				return vec2();
			}
		}
		
		return vec2();
	}
}

class MiniPetWalking : MiniPet
{
	PetPathFollower m_pathFollower;
	int m_idleDelay;
	int m_pickupDelay;
	int m_minIdleRange;
	float m_idleAngle;

	MiniPetWalking(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_idleDelay = GetParamInt(unit, params, "idle-delay", false, 2000);
		m_pickupDelay = GetParamInt(unit, params, "pickup-delay", false, 250);
		m_minIdleRange = GetParamInt(unit, params, "range-min-idle", false, 20);
	}
	
	void Initialize(Actor@ owner, const array<uint> &in flags) override
	{
		MiniPet::Initialize(owner, flags);
		m_pathFollower.Initialize(m_unit, m_pickupRange);
	}
	
	void QueuedPathfind(array<vec2>@ path)
	{
		m_pathFollower.QueuedPathfind(path);

		if (m_pathFollower.m_path is null)
		{
			if (m_state == PetState::MovingToPlayer)
			{
				auto ownerPos = m_owner.m_unit.GetPosition();
				m_unit.SetPosition(ownerPos.x, ownerPos.y, 0, false);
			}
		
			FindTarget(m_pickupRange);
		}
	}

	void Update(int dt)
	{
		if (m_owner is null)
			return;

		bool isHusk = IsHusk();
		
		if (!isHusk)
		{
			auto ownerPos = m_owner.m_unit.GetPosition();
			auto dis = distsq(ownerPos, m_unit.GetPosition());
			if (dis > 450 * 450)
			{
				ClearTarget();
				m_unit.SetPosition(ownerPos.x, ownerPos.y, 0, false);
				m_targetingDelay = 0;
			}
			else if (dis > m_leashRange * m_leashRange)
				SetTarget(xy(m_owner.m_unit.GetPosition()), PetState::MovingToPlayer);
		}

		m_targetingDelay -= dt;
		if (!isHusk && m_targetingDelay <= 0)
			FindTarget(m_pickupRange);

		if (m_hasTarget)
		{
			vec2 from = xy(m_unit.GetPosition());

			float d;
			if (m_state == PetState::Idle)
				d = m_idleSpeed * dt / 33.0;
			else
				d = m_speed * dt / 33.0;

			vec2 dir = m_pathFollower.FollowPath(from, m_target, m_state == PetState::MovingToPickup ? m_leashRange : 0);
			bool isWalking = (dir.x != 0 && dir.y != 0);

			if (isWalking)
				m_idleAngle = atan(dir.y, dir.x);

			if (m_state == PetState::MovingToPlayer)
			{
				if (dir.x == 0 && dir.y == 0)
					dir = normalize(m_target - from);
			}
			else if (m_state == PetState::MovingToPickup && dir.x == 0 && dir.y == 0)
			{
				auto dis = distsq(from, m_target);
				if (dis <= 10 * 10)
				{
					dir = normalize(m_target - from);
					m_targetingDelay = min(m_targetingDelay, 100);
				}
			}

			float length = dist(m_target, from);
			if (d >= length)
			{
				d = length;
				if (m_state == PetState::Idle)
					m_targetingDelay = m_idleDelay;
				else
					m_targetingDelay = m_pickupDelay;

				ClearTarget();
			}

			auto playerOwner = cast<Player>(m_owner);

			vec2 newPos = from + dir * d;
			if (!isHusk)
			{
				array<RaycastResult>@ results = g_scene.Raycast(from, newPos, ~0, RaycastType::Any);
				for (uint i = 0; i < results.length(); i++)
				{
					RaycastResult res = results[i];
					auto unit = res.FetchUnit(g_scene);
					auto pickup = cast<Pickup>(unit.GetScriptBehavior());

					if (pickup is null)
						continue;

					if (!IsPickupOkay(pickup))
						continue;

					int beforeGold = playerOwner.m_record.runGold;
					int beforeOre = playerOwner.m_record.runOre;

					pickup.Collide(m_owner.m_unit, res.point, res.normal);

					if (playerOwner.m_record.runGold - beforeGold > 0)
						Stats::Add("pets-gold-collected", playerOwner.m_record.runGold - beforeGold, playerOwner.m_record);

					if (playerOwner.m_record.runOre - beforeOre > 0)
						Stats::Add("pets-ore-collected", playerOwner.m_record.runOre - beforeOre, playerOwner.m_record);
				}
			}

			m_unit.SetPosition(newPos.x, newPos.y, 0, m_hasTarget);

			if (isWalking)
				m_unit.SetUnitScene(m_animWalk.GetSceneName(atan(dir.y, dir.x)), !m_hasTarget);
			else
				m_unit.SetUnitScene(m_animIdle.GetSceneName(m_idleAngle), !m_hasTarget);

			if (playerOwner !is null)
				Stats::Add("pets-units-traveled", int(d), playerOwner.m_record);
		}
		else
		{
			auto pos = m_unit.GetPosition();
			m_unit.SetPosition(pos.x, pos.y, 0, false);
			m_unit.SetUnitScene(m_animIdle.GetSceneName(m_idleAngle), false);
		}
	}

	void FindTarget(int range)
	{
		if (IsHusk())
			return;

		ClearTarget();

		bool gotTarget;
		auto pickupTarget = FindPickupTarget(gotTarget, range);

		if (gotTarget)
		{
			m_targetingDelay = m_pickupDuration;
			SetTarget(pickupTarget, PetState::MovingToPickup);
		}

		if (!m_hasTarget)
		{
			auto ownerPos = xy(m_owner.m_unit.GetPosition());
			auto dis = distsq(ownerPos, xy(m_unit.GetPosition()));

			if (dis > m_idleRange * m_idleRange || randi(100) > 95)
			{
				auto target = ownerPos + randdir() * (randi(m_idleRange - m_minIdleRange) + m_minIdleRange);
				auto results = g_scene.RaycastClosest(ownerPos, target, ~0, RaycastType::Any);

				if (results.FetchUnit(g_scene).IsValid())
					target = results.point - normalize(target - ownerPos) * 10;

				SetTarget(target, PetState::Idle);
				m_targetingDelay = m_idleDuration;
			}
			else
				m_targetingDelay = m_idleDelay;
		}
	}
}
