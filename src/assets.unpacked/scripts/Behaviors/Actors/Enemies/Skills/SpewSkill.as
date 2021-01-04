class SpewSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;

	AnimString@ m_anim;

	int m_cooldown;
	int m_cooldownC;
	int m_castpoint;
	int m_duration;
	int m_durationC;

	float m_spread;

	int m_spawnRate;
	int m_spawnRateC;
	
	SoundEvent@ m_sound;
	SoundInstance@ m_soundI;
	SoundEvent@ m_startSound;
	SoundEvent@ m_stopSound;
	SoundEvent@ m_fireSound;
	SoundEvent@ m_firstFireSound;

	UnitProducer@ m_projProd;
	string m_offset;
	
	CompositeActorSkillRestrictions m_restrictions;
	
	bool m_holdDir;
	vec2 m_dir;
	bool m_ignoreIsCasting;
	bool m_playedFirstFireSound;
	float m_interceptSpeed;

	array<IAction@>@ m_actions;
	array<IAction@>@ m_startActions;

	SpewSkill(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));

		m_cooldown = GetParamInt(unit, params, "cooldown", false);
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));

		m_castpoint = GetParamInt(unit, params, "castpoint", false);
		m_duration = GetParamInt(unit, params, "duration");

		@m_projProd = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
		m_offset = GetParamString(unit, params, "offset", false);
		
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
		@m_startSound = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));
		@m_stopSound = Resources::GetSoundEvent(GetParamString(unit, params, "stop-snd", false));
		@m_fireSound = Resources::GetSoundEvent(GetParamString(unit, params, "fire-snd", false));
		@m_firstFireSound = Resources::GetSoundEvent(GetParamString(unit, params, "first-fire-snd", false));

		m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;
		m_spawnRateC = m_spawnRate = GetParamInt(unit, params, "rate", false, 33);
		
		m_holdDir = GetParamBool(unit, params, "hold-dir", false, false);
		m_ignoreIsCasting = GetParamBool(unit, params, "ignore-is-casting", false, false);
		m_interceptSpeed = GetParamFloat(unit, params, "aim-interception", false, -1);

		@m_actions = LoadActions(unit, params);
		@m_startActions = LoadActions(unit, params, "start-");
		
		m_restrictions.Load(unit, params);
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
		m_id = id;
		
		m_restrictions.Initialize(unit, behavior);
	}

	void Save(SValueBuilder& builder)
	{
		m_restrictions.Save(builder);
	}

	void Load(SValue@ sval)
	{
		m_restrictions.Load(sval);
	}
	
	void Destroyed()
	{
		if (m_soundI !is null)
		{
			m_soundI.Stop();
			@m_soundI = null;
		}
	}
	
	void StartLoopingSound()
	{
		if (m_sound !is null)
		{
			if (m_soundI !is null)
				m_soundI.Stop();
				
			@m_soundI = m_sound.PlayTracked(m_unit.GetPosition());
		}
	}
	
	void StopLoopingSound()
	{
		if (m_soundI !is null)
		{
			m_soundI.Stop();
			@m_soundI = null;
			
			if (m_stopSound !is null)
				PlaySound3D(m_stopSound, m_unit.GetPosition());
		}
	}
	
	void CancelSkill() 
	{
		m_durationC = 0;
	}
	
	vec2 CalcDir(vec2 pos)
	{
		if (m_interceptSpeed > 0)
		{
			auto tpos = intercept(pos, xy(m_behavior.m_target.m_unit.GetPosition()), m_behavior.m_target.m_unit.GetMoveDir(), m_interceptSpeed);
			return normalize(tpos - pos);
		}
		else
			return normalize(xy(m_behavior.m_target.m_unit.GetPosition()) - pos);
	}

	void NetUseSkill(int stage, SValue@ param)
	{
		if (stage == 0)
		{
			m_cooldownC = 0;
			m_durationC = m_duration + m_castpoint;
			m_spawnRateC = m_castpoint;
			m_dir = CalcDir(xy(m_unit.GetPosition()));
			m_restrictions.UseCharge();
			m_playedFirstFireSound = false;

			if (m_startSound !is null)
				PlaySound3D(m_startSound, m_unit.GetPosition());

			if (!Network::IsServer())
			{
				vec2 pos = FetchOffsetPos(m_unit, m_offset);
				vec2 dir = CalcDir(pos);
				NetDoActions(m_startActions, param, m_behavior, pos, dir);
			}

			m_behavior.SetUnitScene(m_anim.GetSceneName(atan(m_dir.y, m_dir.x)), true);
		}
		else if (stage == 1)
		{
			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			vec2 dir = CalcDir(pos);
			NetDoActions(m_actions, param, m_behavior, pos, dir);
		}
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_behavior.m_target is null)
			return;

		if (Network::IsServer())
		{
			if (m_cooldownC > 0)
			{
				m_cooldownC -= dt;
				return;
			}

			if (m_durationC <= 0 && !isCasting)
			{
				if (m_restrictions.IsAvailable() && m_restrictions.CanSee(m_behavior.m_target.m_unit))
				{
					vec2 pos = FetchOffsetPos(m_unit, m_offset);
					vec2 dir = CalcDir(pos);
					SValue@ param = DoActions(m_startActions, m_behavior, m_behavior.m_target, pos, dir);

					NetUseSkill(0, param);
					UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0, param);
					return;
				}
			}
		}

		if (m_durationC <= 0)
			return;
		
		if (!m_holdDir)
			m_dir = CalcDir(xy(m_unit.GetPosition()));
		
		m_behavior.m_movement.m_dir = atan(m_dir.y, m_dir.x);
		m_behavior.SetUnitScene(m_anim.GetSceneName(atan(m_dir.y, m_dir.x)), false);

		auto body = m_unit.GetPhysicsBody();
		if (body !is null)
			body.SetLinearVelocity(0, 0);

		m_spawnRateC -= dt;
		while (m_spawnRateC <= 0)
		{
			if (m_soundI is null)
				StartLoopingSound();

			if (m_firstFireSound !is null || m_playedFirstFireSound)
				PlaySound3D(m_fireSound, m_unit.GetPosition());

			if (!m_playedFirstFireSound)
			{
				PlaySound3D(m_firstFireSound, m_unit.GetPosition());
				m_playedFirstFireSound = true;

				if (Network::IsServer())
				{
					vec2 pos = FetchOffsetPos(m_unit, m_offset);
					vec2 dir = CalcDir(pos);
					
					if (m_actions.length() > 0)
					{
						SValue@ param = DoActions(m_actions, m_behavior, m_behavior.m_target, pos, dir);
						UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 1, param);
					}
				}
			}

			vec2 shootDir = addrot(m_dir, randfn() * m_spread);

			vec3 pos = xyz(FetchOffsetPos(m_unit, m_offset));
			pos += xyz(shootDir * 3.0);
			
			UnitPtr unitProj = m_projProd.Produce(g_scene, pos);
			if (unitProj.IsValid())
			{
				IProjectile@ p = cast<IProjectile>(unitProj.GetScriptBehavior());
				if (p !is null)
					p.Initialize(m_behavior, shootDir, 1.0, false, m_behavior.m_target, 0);
			}

			m_spawnRateC += m_spawnRate;
		}

		m_durationC -= dt;
		if (m_durationC <= 0)
		{
			m_cooldownC = m_cooldown;
			StopLoopingSound();
		}

		for (uint i = 0; i < m_actions.length(); i++)
			m_actions[i].Update(dt, m_cooldownC);
	}

	bool IsCasting()
	{
		//TODO: Movement should think while this skill is cast (as in Hammerwatch [which is actually a bug?]), but other skills may not be cast.
		return !m_ignoreIsCasting && m_durationC > 0;
	}
	
	void OnDamaged() { }
	void OnDeath() { }
	void OnCollide(UnitPtr unit, vec2 normal) { }
}
