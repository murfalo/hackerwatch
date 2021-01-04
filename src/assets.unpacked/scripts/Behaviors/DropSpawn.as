interface IOnDropped
{
	void OnDropped(DropSpawnBehavior@ dropSpawn, UnitPtr unit);
}

class DropSpawnBehavior
{
	UnitPtr m_unit;

	UnitProducer@ m_producer;

	float m_currSpeed = 0.05;
	float m_maxSpeed = 0.4;
	float m_speedMult = 1.1;
	int m_speedMultC;
	float m_currHeight;

	IOnDropped@ m_dropperScript;
	EffectParams@ m_effectParams;

	int m_userData;

	DropSpawnBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		m_unit.SetShouldCollide(false);
	}

	SValue@ Save()
	{
		SValueBuilder builder;
		builder.PushDictionary();
		builder.PushFloat("curr-speed", m_currSpeed);
		builder.PushFloat("curr-height", m_currHeight);
		builder.PushInteger("speed-mult", m_speedMultC);

		auto ws = WorldScript::GetWorldScript(g_scene, m_dropperScript);
		if (ws !is null)
			builder.PushInteger("dropper-script", ws.GetUnit().GetId());

		builder.PopDictionary();
		return builder.Build();
	}

	void PostLoad(SValue@ data)
	{
		m_currSpeed = GetParamFloat(UnitPtr(), data, "curr-speed", false, m_currSpeed);
		m_currHeight = GetParamFloat(UnitPtr(), data, "curr-height", false, m_currHeight);
		m_speedMultC = GetParamInt(UnitPtr(), data, "speed-mult", false, m_speedMultC);

		auto ws = g_scene.GetUnit(GetParamInt(UnitPtr(), data, "dropper-script", false, -1));
		if (ws.IsValid())
			@m_dropperScript = cast<IOnDropped>(ws.GetScriptBehavior());
	}
	
	void Initialize(IOnDropped@ trigger, UnitProducer@ producer, float initialFallSpeed, float maxFallSpeed, float fallSpeedMultiplier, float height)
	{
		@m_dropperScript = trigger;
		@m_producer = producer;
		m_currSpeed = initialFallSpeed;
		m_maxSpeed = maxFallSpeed;
		m_speedMult = fallSpeedMultiplier;
		m_currHeight = height;
		
		vec3 pos = m_unit.GetPosition();
		pos.z = height;
		m_unit.SetPosition(pos, false);
		
		if (producer !is null)
			@m_effectParams = LoadEffectParams(m_unit, producer.GetBehaviorParams());
	}

	void Update(int dt)
	{
		vec3 pos = m_unit.GetPosition();
		m_currHeight -= dt * m_currSpeed;
		pos.z = m_currHeight;

		if (m_currHeight <= 0)
		{
			pos.z = 0;
			UnitPtr u;
			if (m_producer !is null && Network::IsServer())
			{
				u = m_producer.Produce(g_scene, pos);
				if (!IsNetsyncedExistance(m_producer.GetNetSyncMode()))
					(Network::Message("SpawnUnit") << u.GetId() << m_producer.GetResourceHash() << xy(pos)).SendToAll();
			}
			if (m_dropperScript !is null)
				m_dropperScript.OnDropped(this, u.IsValid() ? u : m_unit);
			m_unit.Destroy();
			return;
		}

		m_unit.SetPosition(pos, true);

		if ((m_speedMultC -= dt) <= 0)
		{
			m_speedMultC = 30;
			m_currSpeed *= m_speedMult;
			if (m_currSpeed > m_maxSpeed)
				m_currSpeed = m_maxSpeed;
		}
	}
}
