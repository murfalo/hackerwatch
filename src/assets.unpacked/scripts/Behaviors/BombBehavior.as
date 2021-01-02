class BombBehavior : Actor, IOwnedUnit
{
	Actor@ m_owner;

	int m_delayC;
	int m_delay;
	int m_delayRandom;

	bool m_exploded;
	bool m_spawned;
	SoundEvent@ m_spawnSound;
	SoundEvent@ m_explodeSound;

	GoreSpawner@ m_gore;

	array<IAction@>@ m_actions;
	EffectParams@ m_effectParams;
		

	BombBehavior(UnitPtr unit, SValue& params)
	{
		super(unit);

		Team = HashString(GetParamString(unit, params, "team", false, "enemy"));

		m_delay = GetParamInt(unit, params, "delay");
		m_delayRandom = GetParamInt(unit, params, "delay-random", false);
		m_delayC = m_delay + randi(m_delayRandom);

		@m_spawnSound = Resources::GetSoundEvent(GetParamString(unit, params, "spawn-sound", false));
		@m_explodeSound = Resources::GetSoundEvent(GetParamString(unit, params, "explode-sound", false));

		@m_gore = LoadGore(GetParamString(unit, params, "gore", false));

		@m_actions = LoadActions(unit, params);
		m_exploded = false;
		
		@m_effectParams = LoadEffectParams(unit, params);
		if (!IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode()))
			PrintError("Non-netsynced BombBehavior is not supported!");
	}
	
	bool IsTargetable() override { return false; }
	
	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		@m_owner = owner;
		PropagateWeaponInformation(m_actions, weaponInfo);
	}
	
	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushDictionary();
		
		sval.PushInteger("ttl", m_delayC);
		
		if (m_owner !is null && m_owner.m_unit.IsValid())
			sval.PushInteger("owner", m_owner.m_unit.GetId());
			
		return sval.Build();
	}
	
	void PostLoad(SValue@ data)
	{
		m_spawned = true;
	
		auto ttl = data.GetDictionaryEntry("ttl");
		if (ttl !is null && ttl.GetType() == SValueType::Integer)
			m_delayC = ttl.GetInteger();

		auto owner = data.GetDictionaryEntry("owner");
		if (owner !is null && owner.GetType() == SValueType::Integer)
		{
			auto ownerUnit = g_scene.GetUnit(owner.GetInteger());
			if (ownerUnit.IsValid())
				@m_owner = cast<Actor>(ownerUnit.GetScriptBehavior());
		}
	}
	
	
	Actor@ GetOwner()
	{
		if (m_owner !is null)
			return m_owner;

		return this;
	}

	void OnSpawn()
	{
		if (m_spawnSound !is null)
			PlaySound3D(m_spawnSound, m_unit.GetPosition());
	}

	void NetDoExplode(SValue@ param)
	{
		if (m_explodeSound !is null)
			PlaySound3D(m_explodeSound, m_unit.GetPosition());

		if (m_gore !is null)
			m_gore.OnDeath(1.0f, xy(m_unit.GetPosition()), 0.0f);

		NetDoActions(m_actions, param, GetOwner(), xy(m_unit.GetPosition()), vec2());
	}

	void DoExplode()
	{
		if (m_exploded)
			return;
	
		m_exploded = true;
	
		if (m_explodeSound !is null)
			PlaySound3D(m_explodeSound, m_unit.GetPosition());

		if (m_gore !is null)
			m_gore.OnDeath(1.0f, xy(m_unit.GetPosition()), 0.0f);

		SValue@ param = DoActions(m_actions, GetOwner(), null, xy(m_unit.GetPosition()), vec2());
		
		if (Network::IsServer())
		{
			(Network::Message("UnitBombExploded") << m_unit << param).SendToAll();
			m_unit.Destroy();
		}
	}

	void Update(int dt)
	{
		if (!m_spawned)
		{
			OnSpawn();
			m_spawned = true;
		}

		if (Network::IsServer())
		{
			m_delayC -= dt;
			if (m_delayC <= 0)
				DoExplode();
		}
	}
}
