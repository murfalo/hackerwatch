class ActorFootsteps
{
	UnitPtr m_unit;

	array<SoundEvent@> m_walkSounds;
	int m_currWalkSound;

	int m_delaySound;
	int m_delaySoundC;

	int m_delayEffect;
	int m_delayEffectC;

	bool m_tileEffects;

	bool m_paused;

	int m_feetCount;
	int m_currentFoot;
	int m_nextFootWait;
	int m_nextFootWaitC;

	int m_feetDistance;
	int m_feetDistanceFar;

	float m_facingDirection;

	ActorFootsteps(UnitPtr unit, SValue@ params)
	{
		m_unit = unit;

		int i = 0;
		while (true)
		{
			string res = GetParamString(unit, params, "walk-snd-" + i++, false, "");

			if (res != "")
				m_walkSounds.insertLast(Resources::GetSoundEvent(res));
			else
				break;
		}

		if (m_walkSounds.length() == 0)
			m_walkSounds.insertLast(Resources::GetSoundEvent(GetParamString(unit, params, "walk-snd", false)));

		m_tileEffects = GetParamBool(unit, params, "tile-effects", false, true);

		int delay = GetParamInt(unit, params, "delay", false, -1);
		if (delay == -1)
		{
			m_delaySound = GetParamInt(unit, params, "snd-delay");
			m_delayEffect = GetParamInt(unit, params, "fx-delay");
		}
		else
			m_delaySound = m_delayEffect = delay;

		m_feetCount = GetParamInt(unit, params, "feet-count", false, 2);
		m_nextFootWaitC = m_nextFootWait = GetParamInt(unit, params, "feet-wait", false, 0);
		m_feetDistance = GetParamInt(unit, params, "feet-distance", false, 0);
		m_feetDistanceFar = GetParamInt(unit, params, "feet-distance-far", false, 0);
	}

	vec3 GetFootPosition()
	{
		vec3 pos = m_unit.GetPosition();
		if (m_feetCount > 0 && (m_feetCount % 2 == 0))
		{
			if (m_feetDistance > 0)
			{
				float footOffset = m_feetDistance / 2.0;
				if (m_currentFoot == 0)
					footOffset *= -1;
				float dir = m_facingDirection + PI / 2.0;
				pos += vec3(cos(dir), sin(dir), 0) * footOffset;
			}
			if (m_feetDistanceFar > 0)
			{
				float dir = m_facingDirection + PI;
				pos += vec3(cos(dir), sin(dir), 0) * m_feetDistanceFar;
			}
		}
		else if (m_feetCount > 1)
			pos += xyz(m_unit.FetchLocator("foot-pos-" + m_currentFoot));
		else if (m_feetCount == 1)
			pos += xyz(m_unit.FetchLocator("foot-pos"));
		return pos;
	}

	void NextFoot()
	{
		if (m_nextFootWaitC > 0)
		{
			m_nextFootWaitC--;
			return;
		}
		m_nextFootWaitC = m_nextFootWait;
		m_currentFoot = (m_currentFoot + 1) % m_feetCount;
	}

	void StepSound()
	{
		if (m_paused)
			return;

		vec3 pos = GetFootPosition();

		if (m_walkSounds.length() > 0)
		{
			PlaySound3D(m_walkSounds[m_currWalkSound], pos);
			m_currWalkSound = (m_currWalkSound + 1) % m_walkSounds.length();
		}
	}

	void StepEffect()
	{
		if (m_paused)
			return;

		vec3 pos = GetFootPosition();
		NextFoot();

		array<Tileset@>@ tilesets = g_scene.FetchTilesets(xy(pos));
		for (int i = tilesets.length() - 1; i >= 0; i--)
		{
			auto tsd = tilesets[i].GetData();
			if (tsd is null)
				continue;

			SValue@ svBlockStepEffect = tsd.GetDictionaryEntry("block-step-effect");
			if (svBlockStepEffect !is null && svBlockStepEffect.GetType() == SValueType::Boolean)
			{
				if (svBlockStepEffect.GetBoolean())
					break;
			}

			SValue@ svStepEffect = tsd.GetDictionaryEntry("step-effect");
			if (svStepEffect is null || svStepEffect.GetType() != SValueType::String)
				continue;

			string stepFx = svStepEffect.GetString();
			PlayEffect(stepFx, xy(pos));

			SValue@ svPrioStepEffect = tsd.GetDictionaryEntry("prio-step-effect");
			if (svPrioStepEffect !is null && svPrioStepEffect.GetType() == SValueType::Boolean)
			{
				if (svPrioStepEffect.GetBoolean())
					break;
			}
		}
	}

	void Update(int dt, bool force = false)
	{
		auto bdy = m_unit.GetPhysicsBody();
		if (bdy is null)
			return;

		bool walking = force || (lengthsq(m_unit.GetMoveDir()) > 0.1);
		if (!walking)
			return;

		m_delaySoundC -= dt;
		if (m_delaySoundC <= 0)
		{
			m_delaySoundC += m_delaySound;
			StepSound();
		}

		if (m_tileEffects && CVars::UseTileEffects)
		{
			m_delayEffectC -= dt;
			if (m_delayEffectC <= 0)
			{
				m_delayEffectC += m_delayEffect;
				StepEffect();
			}
		}
	}
}
