class ConstantSoundSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	
	bool m_onlyWalking;
	bool m_needsTarget;

	int m_startTime;

	SoundEvent@ m_sound;
	SoundInstance@ m_soundI;
	
	
	ConstantSoundSkill(UnitPtr unit, SValue& params)
	{
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "sound", false));
		m_onlyWalking = GetParamBool(unit, params, "only-walking", false, false);
		m_needsTarget = GetParamBool(unit, params, "needs-target", false, true);
		m_startTime = GetParamInt(unit, params, "start-time", false);
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
	}

	void Save(SValueBuilder& builder)
	{
	}

	void Load(SValue@ sval)
	{
	}
	
	float CalcVolume()
	{
		return 1.0f - max(0.5f, (g_numConstSoundsPlaying / 10.0f));
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_soundI !is null)
		{
			m_soundI.SetPosition(m_unit.GetPosition());
			m_soundI.SetVolume(CalcVolume());
		}
	
		if (g_numConstSoundsPlaying >= 5)
			return;
	
		bool shouldPlay = false;
		
		if (m_behavior.m_target !is null || !m_needsTarget)
		{
			if (m_onlyWalking)
				shouldPlay = (lengthsq(m_unit.GetMoveDir()) > 0.1);
			else
				shouldPlay = true;
		}
	
		if (!shouldPlay)
		{
			if (m_soundI !is null)
			{
				m_soundI.Stop();
				m_soundI.SetVolume(0);
				
				g_numConstSoundsPlaying--;
				@m_soundI = null;
			}
			
			return;
		}
		else if (m_soundI is null || !m_soundI.IsPlaying())
		{
			if (m_soundI is null)
				g_numConstSoundsPlaying++;
		
			@m_soundI = m_sound.PlayTracked(m_unit.GetPosition());
			m_soundI.SetVolume(CalcVolume());
			m_soundI.SetPaused(false);
			m_soundI.SetTimelinePosition(randi(m_startTime));
		}
	}
	
	void Destroyed()
	{
		if (m_soundI !is null)
		{
			m_soundI.Stop();
			m_soundI.SetVolume(0);
			g_numConstSoundsPlaying--;
			@m_soundI = null;
		}
	}
	
	
	bool IsCasting() { return false; }
	void OnDamaged() {}
	void OnDeath() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}
	void NetUseSkill(int stage, SValue@ param) {}
	void CancelSkill() {}
}

int g_numConstSoundsPlaying = 0;