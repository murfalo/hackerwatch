class ProximityTrap : DangerAreaBehavior
{
	array<Actor@> m_actorsNear;

	UnitScene@ m_sceneOff;
	UnitScene@ m_sceneOn;
	UnitScene@ m_sceneActivate;
	UnitScene@ m_sceneDeactivate;

	ProximityTrap(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_sceneOff = m_unit.GetUnitScene("off");
		@m_sceneOn = m_unit.GetUnitScene("on");
		@m_sceneActivate = m_unit.GetUnitScene("activate");
		@m_sceneDeactivate = m_unit.GetUnitScene("deactivate");
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal) override {}
	void EndCollision(UnitPtr unit) override {}

	void OnEnter(Actor@ actor)
	{
		m_actorsNear.insertLast(actor);
	}

	bool OnExit(Actor@ actor)
	{
		int index = m_actorsNear.findByRef(actor);
		if (index != -1)
		{
			m_actorsNear.removeAt(index);
			return true;
		}
		return false;
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		if (fxSelf.GetIndex() == 0)
		{
			DangerAreaBehavior::Collide(unit, pos, normal);
			return;
		}

		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		OnEnter(actor);

		if (cast<Player>(actor) !is null)
			(Network::Message("ProximityTrapEnter") << m_unit).SendToAll();
	}

	void EndCollision(UnitPtr unit, Fixture@ fxSelf, Fixture@ fxOther)
	{
		if (fxSelf.GetIndex() == 0)
		{
			DangerAreaBehavior::EndCollision(unit);
			return;
		}

		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		if (OnExit(actor))
		{
			if (cast<Player>(actor) !is null)
				(Network::Message("ProximityTrapExit") << m_unit).SendToAll();
		}
	}

	void Update(int dt) override
	{
		UnitScene@ currScene = m_unit.GetCurrentUnitScene();

		if (m_actorsNear.length() > 0 && currScene is m_sceneOff)
			m_unit.SetUnitScene(m_sceneActivate, true);
		else if (m_actorsNear.length() == 0 && currScene is m_sceneOn)
			m_unit.SetUnitScene(m_sceneDeactivate, true);
		else if (m_unit.GetUnitSceneTime() >= currScene.Length())
		{
			if (currScene is m_sceneActivate)
				m_unit.SetUnitScene(m_sceneOn, true);
			else if (currScene is m_sceneDeactivate)
				m_unit.SetUnitScene(m_sceneOff, true);
		}

		DangerAreaBehavior::Update(dt);
	}
}
