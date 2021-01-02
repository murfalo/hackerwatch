class TripMine : CompositeActorBehavior
{
	AnimString@ m_visibleAnim;
	AnimString@ m_invisibleAnim;

	AnimString@ m_appearAnim;
	AnimString@ m_disappearAnim;

	SoundEvent@ m_appearSound;
	SoundEvent@ m_disappearSound;

	int m_distVisible;
	int m_distTriggerSq;

	int m_appearingC;

	bool m_triggered;
	bool m_visible;
	int m_ttl;

	TripMine(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_visibleAnim = AnimString(GetParamString(unit, params, "anim-visible"));
		@m_invisibleAnim = AnimString(GetParamString(unit, params, "anim-invisible"));

		@m_appearAnim = AnimString(GetParamString(unit, params, "anim-appear", false));
		@m_disappearAnim = AnimString(GetParamString(unit, params, "anim-disappear", false));

		@m_appearSound = Resources::GetSoundEvent(GetParamString(unit, params, "appear-snd", false));
		@m_disappearSound = Resources::GetSoundEvent(GetParamString(unit, params, "disappear-snd", false));
		
		m_ttl = GetParamInt(unit, params, "ttl", false, -1);

		m_distVisible = GetParamInt(unit, params, "dist-visible");
		m_distTriggerSq = GetParamInt(unit, params, "dist-trigger");
		m_distTriggerSq = m_distTriggerSq * m_distTriggerSq;

		m_unit.SetUnitScene(m_invisibleAnim.GetSceneName(0), true);
	}

	void Update(int dt) override
	{
		if (m_ttl > 0)
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
			{
				m_unit.Destroy();
				return;
			}
		}
	
		if (!m_triggered)
		{
			vec2 mypos = xy(m_unit.GetPosition());
			
			bool visible = false;

			array<UnitPtr>@ results = g_scene.FetchActorsWithOtherTeam(Team, mypos, m_distVisible);
			for (uint i = 0; i < results.length(); i++)
			{
				auto a = cast<Actor>(results[i].GetScriptBehavior());
				if (a is null || !a.IsTargetable())
					continue;

				visible = true;
				if (distsq(mypos, xy(results[i].GetPosition())) <= m_distTriggerSq)
				{
					Triggered();
					break;
				}
			}

			if (m_visible != visible)
			{
				m_visible = visible;

				if (visible)
				{
					if (m_appearAnim.m_anim != "")
					{
						m_unit.SetUnitScene(m_appearAnim.GetSceneName(0), true);
						m_appearingC = m_unit.GetCurrentUnitScene().Length();
					}
					else
						m_unit.SetUnitScene(m_visibleAnim.GetSceneName(0), true);

					PlaySound3D(m_appearSound, m_unit.GetPosition());
				}
				else
				{
					if (m_disappearAnim.m_anim != "")
					{
						m_unit.SetUnitScene(m_disappearAnim.GetSceneName(0), true);
						m_appearingC = m_unit.GetCurrentUnitScene().Length();
					}
					else
						m_unit.SetUnitScene(m_invisibleAnim.GetSceneName(0), true);

					PlaySound3D(m_disappearSound, m_unit.GetPosition());
				}
			}

			if (m_appearingC > 0)
			{
				m_appearingC -= dt;
				if (m_appearingC <= 0)
					SetIdleAnimation();
			}
		}

		CompositeActorBehavior::Update(dt);
	}

	void SetIdleAnimation()
	{
		string scene;
		if (m_visible)
			scene = m_visibleAnim.GetSceneName(0);
		else
			scene = m_invisibleAnim.GetSceneName(0);
			
		m_unit.SetUnitScene(scene, true);
	}

	void Triggered()
	{
		m_triggered = true;
		Kill(null, 0);
	}
}
