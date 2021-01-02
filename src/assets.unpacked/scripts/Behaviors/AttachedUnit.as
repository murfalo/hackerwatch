class AttachedUnit : IPreRenderable
{
	UnitPtr m_unit;

	UnitPtr m_attachedTo;
	vec2 m_offset;
	bool m_destroyOnDestroy;
	int m_duration;
	
	UnitProducer@ m_sceneSource;
	string m_sceneName;
	

	AttachedUnit(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}
	
	void Initialize(UnitProducer@ unitType, string sceneName, int layer, UnitPtr attachTo, vec2 offset, bool destroyOnDestroy, int duration)
	{
		@m_sceneSource = unitType;
		m_sceneName = sceneName;
	
		auto scene = unitType.GetUnitScene(sceneName);
		if (scene is null)
			PrintError("WARNING: Scene with name '" + sceneName + "' not found in UnitProducer!");
		else
			m_unit.SetUnitScene(scene, true);
			
		if (layer != -1)
			m_unit.SetLayer(layer);
		
		m_attachedTo = attachTo;
		m_offset = offset;
		m_destroyOnDestroy = destroyOnDestroy;
		m_duration = duration;
		
		m_preRenderables.insertLast(this);
	}

	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushDictionary();
		
		sval.PushInteger("ttl", m_duration);
		sval.PushInteger("attached", m_attachedTo.GetId());
		sval.PushBoolean("destroy", m_destroyOnDestroy);
		sval.PushVector2("offset", m_offset);
		
		if (m_sceneSource !is null)
			sval.PushInteger("scene-source", m_sceneSource.GetResourceHash());
			
		sval.PushString("scene-name", m_sceneName);
		
		return sval.Build();
	}
	
	void Load(SValue@ data)
	{
		auto ttl = data.GetDictionaryEntry("ttl");
		if (ttl !is null && ttl.GetType() == SValueType::Integer)
			m_duration = ttl.GetInteger();
			
		auto destroy = data.GetDictionaryEntry("destroy");
		if (destroy !is null && destroy.GetType() == SValueType::Boolean)
			m_destroyOnDestroy = destroy.GetBoolean();
			
		auto offset = data.GetDictionaryEntry("offset");
		if (offset !is null && offset.GetType() == SValueType::Vector2)
			m_offset = offset.GetVector2();	
			

		auto sceneSrc = data.GetDictionaryEntry("scene-source");
		if (sceneSrc !is null && sceneSrc.GetType() == SValueType::Integer)
			@m_sceneSource = Resources::GetUnitProducer(sceneSrc.GetInteger());
			
		auto sceneName = data.GetDictionaryEntry("scene-name");
		if (sceneName !is null && sceneName.GetType() == SValueType::String)
			m_sceneName = sceneName.GetString();
		
		if (m_sceneSource !is null)
		{
			auto scene = m_sceneSource.GetUnitScene(m_sceneName);
			if (scene !is null)
				m_unit.SetUnitScene(scene, true);
		}
	}

	void PostLoad(SValue@ data)
	{
		auto attached = data.GetDictionaryEntry("attached");
		if (attached !is null && attached.GetType() == SValueType::Integer)
			m_attachedTo = g_scene.GetUnit(attached.GetInteger());
			
		m_preRenderables.insertLast(this);
	}
	
	
	vec2 GetOffset()
	{
		return m_offset;
	}

	void Destroy()
	{
		m_unit.Destroy();
	}
	
	void Update(int dt)
	{
		if (m_duration > 0)
		{
			m_duration -= dt;
			if (m_duration <= 0)
				Destroy();
		}
	}
	
	bool PreRender(int idt)
	{
		if (m_unit.IsDestroyed())
			return true;

		if (!m_attachedTo.IsValid() || m_attachedTo.IsDestroyed())
		{
			if (m_destroyOnDestroy)
			{
				m_unit.Destroy();
				return true;
			}
			return false;
		}

		if (IsPaused())
			idt = 0;

		auto pos = m_attachedTo.GetInterpolatedPosition(idt);
		m_unit.SetPosition(pos + xyz(GetOffset()));
		return false;
	}
}

class AttachedActorUnit : AttachedUnit
{
	Actor@ m_actor;
	int m_sizeX;

	AttachedActorUnit(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}
	
	// TODO: Save/Load these?
	
	void Destroy() override
	{
		if (m_actor !is null)
		{
			int i = m_actor.m_attachedUnits.find(m_unit);
			if (i != -1)
				m_actor.m_attachedUnits.removeAt(i);
		}
		
		m_unit.Destroy();
	}

	vec2 GetOffset() override
	{
		if (m_actor is null)
			return m_offset;
	
		int i = m_actor.m_attachedUnits.find(m_unit);
		int ct = m_actor.m_attachedUnits.length();
		
		return m_offset + vec2(-((ct - 1) * m_sizeX / 2.0) + (i * m_sizeX), m_actor.IconHeight());
	}
	
	/*
	void Update(int dt) override
	{
		AttachedUnit::Update(dt);
	}
	*/
}
