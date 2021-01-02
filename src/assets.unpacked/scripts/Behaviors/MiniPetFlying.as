class MiniPetFlying : MiniPet
{
	float m_dir;
	float m_turnSpeed;
	float m_pickupBoost;
	float m_turnSpeedBoostValue;
	float m_currentSpeed;
	float m_acceleration;
	float m_deceleration;
	
	MiniPetFlying(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_turnSpeed = GetParamFloat(unit, params, "turn-speed", false, 1);
		m_acceleration = GetParamFloat(unit, params, "acceleration-duration", false, 250.0);
		m_deceleration = GetParamFloat(unit, params, "deceleration-duration", false, 750.0);
		m_turnSpeedBoostValue = GetParamFloat(unit, params, "turn-speed-boost", false, 100.0);
		m_dir = randf() * 2 * PI;
	}
	
	void Update(int dt)
	{
		if (m_owner is null)
			return;

		bool isHusk = IsHusk();

		if (!isHusk)
		{
			auto dis = distsq(m_owner.m_unit.GetPosition(), m_unit.GetPosition());
			if (dis > 450 * 450)
			{
				m_unit.SetPosition(m_owner.m_unit.GetPosition().x, m_owner.m_unit.GetPosition().y, 0, false);
				ClearTarget();
				m_targetingDelay = 0;
				m_pickupBoost = 0;

			}
			else if (dis > m_leashRange * m_leashRange)
			{
				ClearTarget();
				m_targetingDelay = 0;
				m_pickupBoost = 0;
				m_state = PetState::MovingToPlayer;
			}
		}

		m_targetingDelay -= dt;
		if (!isHusk && m_targetingDelay <= 0)
		{
			bool gotTarget;
			auto target = FindPickupTarget(gotTarget, m_pickupRange);
			m_targetingDelay = m_pickupDuration;

			if (!gotTarget)
			{
				auto idleTarget = xy(m_owner.m_unit.GetPosition()) + randdir() * randf() * m_idleRange;
				m_targetingDelay = m_idleDuration;
				m_pickupBoost = 0;
				SetTarget(idleTarget, PetState::Idle);
			}
			else
				SetTarget(target, PetState::MovingToPickup);
		}

		vec2 from = xy(m_unit.GetPosition());

		float d;
		if (m_state == PetState::Idle)
			m_currentSpeed = max(m_idleSpeed, m_currentSpeed - dt / m_deceleration);
		else
			m_currentSpeed = min(m_speed, m_currentSpeed + dt / m_acceleration);

		d = m_currentSpeed;

		if (m_hasTarget)
		{
			vec2 dir = normalize(m_target - from);
			float length = dist(m_target, from);

			if (d >= length)
			{
				d = length;
				ClearTarget();
				m_targetingDelay = 0;
				m_pickupBoost = 0;
			}

			m_dir = rottowards(m_dir, atan(dir.y, dir.x), (m_turnSpeed + m_pickupBoost / m_turnSpeedBoostValue) * dt / 1000.0f);
			
			if (m_state == PetState::MovingToPickup)
				m_pickupBoost += dt;
		}

		auto playerOwner = cast<Player>(m_owner);

		vec2 dir = vec2(cos(m_dir), sin(m_dir));
		vec2 newPos = from + dir * d;
		if (!isHusk)
		{
			array<RaycastResult>@ results = g_scene.RaycastWide(3, 5 + int(m_pickupBoost / 500.0) / 3, from, newPos, ~0, RaycastType::Any);

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
		m_unit.SetPosition(newPos.x, newPos.y, 0, true);
		m_unit.SetUnitScene(m_animWalk.GetSceneName(m_dir), false);

		if (playerOwner !is null)
			Stats::Add("pets-units-traveled", int(d), playerOwner.m_record);
	}
}
