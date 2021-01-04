class CompositeJammableActorBehavior : CompositeActorBehavior, IJammable
{
	int m_jamCount;

	AnimString@ m_animJammed;

	UnitScene@ m_sceneBeforeJam;
	int m_tmBeforeJam;

	SoundEvent@ m_soundJam;
	SoundEvent@ m_soundUnjam;

	CompositeJammableActorBehavior(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_animJammed = AnimString(GetParamString(unit, params, "anim-jammed"));

		@m_soundJam = Resources::GetSoundEvent(GetParamString(unit, params, "jam-sound"));
		@m_soundUnjam = Resources::GetSoundEvent(GetParamString(unit, params, "unjam-sound"));
	}

	void Update(int dt) override
	{
		if (m_jamCount == 0)
			CompositeActorBehavior::Update(dt);
		else
		{
			if (m_dmgColor > 0)
				m_dmgColor -= dt / 100.0;
	
			m_buffs.Update(dt);
			m_unit.SetUnitSceneTime(m_tmBeforeJam);
		}
	}

	int GetJamCount()
	{
		return m_jamCount;
	}

	void Jam()
	{
		m_jamCount++;
		if (m_jamCount == 1)
		{
			@m_sceneBeforeJam = m_unit.GetCurrentUnitScene();
			m_tmBeforeJam = m_unit.GetUnitSceneTime();
			m_unit.SetUnitScene(m_animJammed.GetSceneName(m_movement.m_dir), false);
			PlaySound3D(m_soundJam, m_unit.GetPosition());

			SValueBuilder sv;
			sv.PushString("Jam");
			m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		}
	}

	void Unjam()
	{
		m_jamCount--;
		if (m_jamCount == 0 && m_sceneBeforeJam !is null)
		{
			m_unit.SetUnitScene(m_sceneBeforeJam, false);
			PlaySound3D(m_soundUnjam, m_unit.GetPosition());

			SValueBuilder sv;
			sv.PushString("Unjam");
			m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		}
	}
}
