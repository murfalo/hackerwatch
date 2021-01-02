class BossWormMovement : ActorMovement
{
	AnimString@ m_walkAnim;
	AnimString@ m_undergroundAnim;

	AnimString@ m_digDownAnim;
	AnimString@ m_digUpAnim;

	UnitScene@ m_fxDigDown;
	UnitScene@ m_fxDigUp;

	SoundEvent@ m_sndDigDown;
	SoundEvent@ m_sndDigUp;
	SoundEvent@ m_sndStop;

	float m_speed;
	float m_turnSpeed;

	int m_targetingC;
	vec2 m_targetPos;

	bool m_underground;
	
	ivec2 m_switchUpTime;
	ivec2 m_switchDownTime;
	
	int m_switchTimeC;
	int m_switching;
	int m_switchingC;

	float m_segmentTestDistance;
	float m_segmentTestRadius;

	SoundEvent@ m_sndMove;
	SoundInstance@ m_sndMoveI;

	BossWormMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));
		@m_undergroundAnim = AnimString(GetParamString(unit, params, "underground-anim", false, "underground"));

		@m_digDownAnim = AnimString(GetParamString(unit, params, "anim-dig-down", false, m_walkAnim.m_anim + " " + m_walkAnim.m_numDirs));
		@m_digUpAnim = AnimString(GetParamString(unit, params, "anim-dig-up", false, m_walkAnim.m_anim + " " + m_walkAnim.m_numDirs));

		@m_fxDigDown = Resources::GetEffect(GetParamString(unit, params, "fx-dig-down", false));
		@m_fxDigUp = Resources::GetEffect(GetParamString(unit, params, "fx-dig-up", false));

		@m_sndDigDown = Resources::GetSoundEvent(GetParamString(unit, params, "snd-dig-down", false));
		@m_sndDigUp = Resources::GetSoundEvent(GetParamString(unit, params, "snd-dig-up", false));
		@m_sndStop = Resources::GetSoundEvent(GetParamString(unit, params, "snd-stop", false));

		m_speed = GetParamFloat(unit, params, "speed");
		m_turnSpeed = GetParamFloat(unit, params, "turn-speed");

		m_segmentTestDistance = GetParamFloat(unit, params, "segment-test-distance", false, 32);
		m_segmentTestRadius = GetParamFloat(unit, params, "segment-test-radius", false, 16);

		@m_sndMove = Resources::GetSoundEvent(GetParamString(unit, params, "snd-move", false));
		
		vec2 time;
		
		time = GetParamVec2(unit, params, "dig-up-time");
		m_switchUpTime = ivec2(int(time.x), int(time.y));
		
		time = GetParamVec2(unit, params, "dig-down-time");
		m_switchDownTime = ivec2(int(time.x), int(time.y));
		
		m_switchTimeC = m_switchDownTime.x + randi(m_switchDownTime.y - m_switchDownTime.x);

		m_underground = GetParamBool(unit, params, "start-underground", false, false);
		m_targetingC = 0;
	}

	void SwitchMoveSound(bool casting)
	{
		if (m_sndMove is null)
			return;

		if (m_sndMoveI is null && !casting)
		{
			vec3 pos = m_unit.GetPosition();
			@m_sndMoveI = m_sndMove.PlayTracked(pos);

			UpdateMoveSound();
		}
		else if (m_sndMoveI !is null && casting)
		{
			m_sndMoveI.Stop();
			@m_sndMoveI = null;

			PlaySound3D(m_sndStop, m_unit.GetPosition());
		}
	}

	void UpdateMoveSound()
	{
		if (m_sndMoveI is null)
			return;

		float belowFactor = (m_underground ? 1.0f : 0.0f);
		if (m_switchingC > 0)
		{
			if (m_underground)
				belowFactor -= (m_switchingC / float(m_switching));
			else
				belowFactor += (m_switchingC / float(m_switching));
		}

		m_sndMoveI.SetParameter("isBelow", belowFactor);
		m_sndMoveI.SetPosition(m_unit.GetPosition());
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		ActorMovement::Initialize(unit, behavior);

		if (m_underground)
			g_flags.Set("bossworm_underground", FlagState::Level);

		SwitchMoveSound(false);
	}

	void OnDeath(DamageInfo di, vec2 dir) override
	{
		ActorMovement::OnDeath(di, dir);

		if (m_sndMoveI !is null)
		{
			m_sndMoveI.Stop();
			@m_sndMoveI = null;
		}
	}

	void UpdateSeeking(int dt)
	{
		if (m_behavior.m_target !is null)
		{
			vec2 mypos = xy(m_unit.GetPosition());
			vec2 diff = m_targetPos - mypos;
			vec2 dir = normalize(diff);

			m_dir = rottowards(m_dir, atan(dir.y, dir.x), m_turnSpeed * dt / 1000.0f);
		}
	}

	void Switch(bool underground)
	{
		if (!Network::IsServer())
			return;

		NetSwitch(underground);
		
		if (m_underground)
			m_switchTimeC = m_switchUpTime.x + randi(m_switchUpTime.y - m_switchUpTime.x);
		else
			m_switchTimeC = m_switchDownTime.x + randi(m_switchDownTime.y - m_switchDownTime.x);

		(Network::Message("UnitMovementBossWormSwitch") << m_unit << underground).SendToAll();
	}

	void NetSwitch(bool underground)
	{
		m_underground = underground;

		if (underground)
		{
			m_unit.SetUnitScene(m_digDownAnim.GetSceneName(m_dir), true);
			PlayEffect(m_fxDigDown, m_unit.GetPosition());
			PlaySound3D(m_sndDigDown, m_unit.GetPosition());

			for (uint i = 0; i < m_behavior.m_skills.length(); i++)
			{
				auto scatterSkill = cast<BossScatterBurstSkill>(m_behavior.m_skills[i]);
				if (scatterSkill is null)
					continue;

				scatterSkill.m_cooldownC = scatterSkill.m_cooldown;
				break;
			}
		}
		else
		{
			m_unit.SetUnitScene(m_digUpAnim.GetSceneName(m_dir), true);
			g_flags.Delete("bossworm_underground");
			PlayEffect(m_fxDigUp, m_unit.GetPosition());
			PlaySound3D(m_sndDigUp, m_unit.GetPosition());
		}

		m_switching = m_switchingC = m_unit.GetCurrentUnitScene().Length();
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
			return;

		//ActorMovement::Update(dt, isCasting);

		SwitchMoveSound(isCasting);

		auto body = m_unit.GetPhysicsBody();
		if (isCasting)
		{
			body.SetStatic(true);
			body.SetLinearVelocity(vec2());
			return;
		}

		if (m_behavior.m_target is null)
			return;

		UpdateMoveSound();

		auto dirVec = vec2(cos(m_dir), sin(m_dir));
		bool blocked = false;
		
		array<UnitPtr>@ results = g_scene.QueryCircle(xy(m_unit.GetPosition()) + dirVec * m_segmentTestDistance, int(m_segmentTestRadius), ~0, RaycastType::Any);
		for (uint i = 0; i < results.length(); i++)
		{
			if (cast<BossWormSegment>(results[i].GetScriptBehavior()) !is null)
			{
				blocked = true;
				break;
			}
		}
		
		if (blocked)
			g_flags.Set("bossworm_blocked", FlagState::Level);
		else
			g_flags.Delete("bossworm_blocked");
		

		if (Network::IsServer())
		{
			m_targetingC -= dt;
			if (m_targetingC <= 0)
			{
				m_targetingC = 750;
				m_targetPos = xy(m_behavior.m_target.m_unit.GetPosition()) + vec2(randi(150) - 75, randi(150) - 75);

				/*
				auto res = g_scene.FetchAllWorldScriptsWithComment("ScriptLink", "bossworm_avoid");
				for (uint i = 0; i < res.length(); i++)
				{
					auto script = res[i];
					if (!script.IsEnabled())
						continue;
			
					vec2 dir = m_targetPos - xy(script.GetUnit().GetPosition());
					float force = lengthsq(dir);
					if (force > 0) force = 1 / force;
					m_targetPos += normalize(dir) * force * 250;
				}
				*/

				(Network::Message("UnitMovementBossWormTarget") << m_unit << m_targetPos << m_dir).SendToAll();
			}
		}

		UpdateSeeking(dt);

		if (Network::IsServer())
		{
			m_switchTimeC -= dt;
			if (m_switchTimeC <= 0 && (!blocked || !m_underground))
				Switch(!m_underground);
			else if (blocked && !m_underground)
				Switch(!m_underground);
		}

		float speed = m_speed + pow(g_ngp + 1.0f, 0.1f) - 1.0f;
		speed *= m_behavior.m_buffs.MoveSpeedMul();

		float buffSetSpeed = m_behavior.m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			speed = buffSetSpeed;

		body.SetStatic(false);
		body.SetLinearVelocity(dirVec * speed);

		if (m_switchingC > 0)
		{
			if (m_underground)
				m_unit.SetUnitScene(m_digDownAnim.GetSceneName(m_dir), false);
			else
				m_unit.SetUnitScene(m_digUpAnim.GetSceneName(m_dir), false);

			m_switchingC -= dt;
			if (m_switchingC <= 0 && m_underground)
				g_flags.Set("bossworm_underground", FlagState::Level);
		}

		if (m_switchingC <= 0)
		{
			if (!m_underground)
				m_unit.SetUnitScene(m_walkAnim.GetSceneName(m_dir), false);
			else
				m_unit.SetUnitScene(m_undergroundAnim.GetSceneName(m_dir), false);
		}
	}

	SValue@ Save() override
	{
		SValueBuilder builder;
		builder.PushDictionary();
		builder.PushBoolean("underground", m_underground);
		builder.PushInteger("switch-time", m_switchTimeC);
		builder.PushInteger("switching", m_switchingC);
		builder.PopDictionary();
		return builder.Build();
	}

	void Load(SValue@ sval) override
	{
		m_underground = GetParamBool(UnitPtr(), sval, "underground");
		m_switchTimeC = GetParamInt(UnitPtr(), sval, "switch-time");
		m_switchingC = GetParamInt(UnitPtr(), sval, "switching");
	}
}
