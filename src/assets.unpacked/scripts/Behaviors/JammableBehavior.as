class JammableBehavior : StateAnimations, IJammable
{
	int m_jamCount;

	bool m_active = true;

	string m_animIdle;
	string m_animJammed;

	SoundEvent@ m_soundJam;
	SoundEvent@ m_soundUnjam;

	// Avoid players using deployed jammers through open energy doors
	bool m_sensorsBlockUsage;
	Fixture@ m_collidingFixture;

	JammableBehavior(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_animIdle = GetParamString(unit, params, "idle-scene");
		m_animJammed = GetParamString(unit, params, "jammed-scene");

		@m_soundJam = Resources::GetSoundEvent(GetParamString(unit, params, "jam-sound"));
		@m_soundUnjam = Resources::GetSoundEvent(GetParamString(unit, params, "unjam-sound"));

		m_sensorsBlockUsage = GetParamBool(unit, params, "sensors-block-usage", false, true);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		if (!m_active)
			return;

		if (!m_sensorsBlockUsage)
			return;

		if (!fxSelf.IsSensor())
			return;

		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		player.m_insideJammable = true;
		@m_collidingFixture = fxSelf;
	}

	void EndCollision(UnitPtr unit, Fixture@ fxSelf, Fixture@ fxOther)
	{
		if (!m_active)
			return;

		if (!m_sensorsBlockUsage)
			return;

		if (fxSelf !is m_collidingFixture)
			return;

		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		player.m_insideJammable = false;
		@m_collidingFixture = null;
	}

	int GetJamCount()
	{
		return m_jamCount;
	}

	void Jam()
	{
		m_jamCount++;

		if (!m_active)
			return;

		if (m_jamCount == 1)
		{
			m_unit.SetUnitScene(m_animJammed, true);
			PlaySound3D(m_soundJam, m_unit.GetPosition());

			SValueBuilder sv;
			sv.PushString("Jam");
			m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		}
	}

	void Unjam()
	{
		m_jamCount--;

		if (!m_active)
			return;

		if (m_jamCount == 0)
		{
			m_unit.SetUnitScene(m_animIdle, true);
			PlaySound3D(m_soundUnjam, m_unit.GetPosition());

			SValueBuilder sv;
			sv.PushString("Unjam");
			m_unit.TriggerCallbacks(UnitEventType::Custom, sv.Build());
		}
	}
}
