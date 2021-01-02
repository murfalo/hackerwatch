class BossVampire : CompositeActorBehavior
{
	array<UnitPtr> m_insideWalls;

	int m_roaming;
	int m_roamingC = -1;

	float m_roamChance;
	string m_roamFlag;

	UnitProducer@ m_prodRoam;
	SoundEvent@ m_sndRoam;
	int m_roamSpawnTime;
	int m_roamSpawnTimeC;

	BossVampire(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_roaming = GetParamInt(unit, params, "roaming", false, 3);
		m_roamChance = GetParamFloat(unit, params, "roam-chance", false, 0.25f);
		m_roamFlag = GetParamString(unit, params, "roam-flag", false, "vampire_roaming");

		@m_prodRoam = Resources::GetUnitProducer(GetParamString(unit, params, "roam-unit", false, "doodads/generic/trap_barrel_bomb.unit"));
		@m_sndRoam = Resources::GetSoundEvent(GetParamString(unit, params, "roam-unit-snd", false));
		m_roamSpawnTime = GetParamInt(unit, params, "roam-unit-interval", false, 150);

		m_frozen = true;
	}

	SValue@ Save() override
	{
		SValueBuilder builder;
		builder.PushDictionary();

		builder.PushInteger("roaming", m_roamingC);
		builder.PushInteger("roaming-spawn-time", m_roamSpawnTimeC);

		builder.PushSimple("composite", CompositeActorBehavior::Save());

		builder.PopDictionary();
		return builder.Build();
	}

	void Load(SValue@ data) override
	{
		SValue@ svComposite = data.GetDictionaryEntry("composite");
		if (svComposite !is null)
		{
			m_roamingC = GetParamInt(UnitPtr(), data, "roaming", false, m_roamingC);
			m_roamSpawnTimeC = GetParamInt(UnitPtr(), data, "roaming-spawn-time", false, m_roamSpawnTimeC);

			CompositeActorBehavior::Load(svComposite);
		}
		else
			CompositeActorBehavior::Load(data);
	}

	void PostLoad(SValue@ data) override
	{
		SValue@ svComposite = data.GetDictionaryEntry("composite");
		if (svComposite !is null)
			CompositeActorBehavior::PostLoad(svComposite);
		else
			CompositeActorBehavior::PostLoad(data);
	}

	void Update(int dt) override
	{
		if (m_target is null)
			m_targetSearchCd = 0;

		if (m_roamingC > 0)
		{
			m_roamSpawnTimeC -= dt;
			if (m_roamSpawnTimeC <= 0)
			{
				m_roamSpawnTimeC = m_roamSpawnTime;
				vec3 pos = m_unit.GetPosition();
				m_prodRoam.Produce(g_scene, pos);
				PlaySound3D(m_sndRoam, pos);
			}
		}

		CompositeActorBehavior::Update(dt);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther) override
	{
		if (unit.GetScriptBehavior() is null && !fxOther.IsSensor())
			m_insideWalls.insertLast(unit);

		CompositeActorBehavior::Collide(unit, pos, normal, fxSelf, fxOther);
	}

	void EndCollision(UnitPtr unit)
	{
		int wallIndex = m_insideWalls.find(unit);
		if (wallIndex != -1)
			m_insideWalls.removeAt(wallIndex);
	}

	void NetOnNodeArrived()
	{
		if (m_roamingC >= 0)
			m_roamingC--;
	}

	void OnNodeArrived()
	{
		auto movement = cast<BossVampireMovement>(m_movement);
		if (g_flags.IsSet(m_roamFlag) && movement.m_nodeTarget !is g_vampireCenterNode)
		{
			if (m_roamingC == -1 && randf() <= m_roamChance)
			{
				m_roamingC = m_roaming;
				(Network::Message("VampireBossRoaming") << m_unit).SendToAll();
			}
		}
	}

	vec2 GetCastDirection() override
	{
		array<UnitPtr>@ results = g_scene.FetchActorsWithOtherTeam(Team, xy(m_unit.GetPosition()), 300);
		if (results.length() == 0)
			return GetDirection();

		UnitPtr closestUnit = results[0];
		float closestDistance = distsq(results[0].GetPosition(), m_unit.GetPosition());

		for (uint i = 1; i < results.length(); i++)
		{
			float distance = distsq(results[i].GetPosition(), m_unit.GetPosition());
			if (distance < closestDistance)
			{
				closestDistance = distance;
				closestUnit = results[i];
			}
		}

		return normalize(xy(closestUnit.GetPosition() - m_unit.GetPosition()));
	}

	bool IsTargetable() override
	{
		auto body = m_unit.GetPhysicsBody();
		if (body !is null && !body.IsStatic())
			return false;

		return CompositeActorBehavior::IsTargetable();
	}

	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override
	{
		return !IsTargetable();
	}
}
