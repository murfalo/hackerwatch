class ChargeStrike : JumpStrike
{
	array<UnitPtr> m_hitUnits;

	AnimString@ m_animStop;

	int m_stoppingC;

	int m_rayNum;
	int m_rayWidth;
	float m_rayLength;

	ChargeStrike(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_rayNum = GetParamInt(unit, params, "ray-num", false, 4);
		m_rayWidth = GetParamInt(unit, params, "ray-width", false, 3);
		m_rayLength = GetParamFloat(unit, params, "ray-length", false, 3.0f);

		m_holdFrame = 0;

		string strAnimStop = GetParamString(unit, params, "anim-stop", false);
		if (strAnimStop != "")
			@m_animStop = AnimString(strAnimStop);
	}

	void BeginCast() override
	{
		JumpStrike::BeginCast();

		m_hitUnits.removeRange(0, m_hitUnits.length());
	}
	
	void CancelSkill() override
	{
		m_stoppingC = 0;
		JumpStrike::CancelSkill();
	}

	void OnCollide(UnitPtr unit, vec2 normal) override
	{
		if (m_castingC <= 0)
			return;

		if (cast<Pickup>(unit.GetScriptBehavior()) !is null)
			return;

		vec2 pos = FetchOffsetPos(m_unit, m_offset);

		ApplyEffects(m_effects, m_behavior, unit, pos, m_dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);

		if (unit.GetUnitProducer() is m_unit.GetUnitProducer())
			return;

		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor !is null && !actor.Impenetrable())
			return;

		StopSkill();
	}

	void StopSkillPost() override
	{
		StopSkill();
	}

	void StopSkill()
	{
		if (m_animStop is null)
		{
			CancelSkill();
			return;
		}

		m_cooldownC = m_cooldown;
		m_preCastC = 0;
		m_castingC = 0;
		m_postCastC = 0;
		m_unit.SetPositionZ(0);

		m_unit.SetShouldCollideWithSame(true);

		float angle = atan(m_dir.y, m_dir.x);
		m_stoppingC = m_behavior.SetUnitScene(m_animStop.GetSceneName(angle), true);

		vec2 dir = m_behavior.GetDirection();
		vec2 pos = FetchOffsetPos(m_unit, m_offset);
		ApplyEffects(m_finishedEffects, m_behavior, UnitPtr(), pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);

		if (Network::IsServer())
			UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 2);
	}

	void NetUseSkill(int stage, SValue@ param) override
	{
		if (stage == 2)
			StopSkill();
		else
			JumpStrike::NetUseSkill(stage, param);
	}

	void Update(int dt, bool isCasting) override
	{
		JumpStrike::Update(dt, isCasting);

		if (m_castingC > 0)
		{
			vec2 from = xy(m_unit.GetPosition());
			vec2 to = from + m_dir * m_speed * dt / 33.0;

			array<RaycastResult>@ results = g_scene.RaycastWide(m_rayNum, m_rayWidth, from, to + m_dir * m_rayLength, ~0, RaycastType::Any);
			for (uint i = 0; i < results.length(); i++)
			{
				RaycastResult res = results[i];
				//if (res.fixture.IsSensor())
				//	continue;

				UnitPtr unit = res.FetchUnit(g_scene);

				auto dmgTaker = cast<IDamageTaker>(unit.GetScriptBehavior());
				if (dmgTaker !is null)
				{
					if (dmgTaker.ShootThrough(m_behavior, from, m_dir))
						continue;

					if (m_hitUnits.find(unit) != -1)
						continue;
					m_hitUnits.insertLast(unit);

					ApplyEffects(m_effects, m_behavior, unit, from, m_dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);
				}
			}
		}
		else if (m_stoppingC > 0)
		{
			m_stoppingC -= dt;
			m_cooldownC = m_cooldown;

			float angle = atan(m_dir.y, m_dir.x);
			m_currAnim = m_animStop.GetSceneName(angle);

			if (Network::IsServer())
				m_unit.GetPhysicsBody().SetLinearVelocity(vec2());
		}
	}

	bool IsCasting() override
	{
		return m_stoppingC > 0 || JumpStrike::IsCasting();
	}
}
