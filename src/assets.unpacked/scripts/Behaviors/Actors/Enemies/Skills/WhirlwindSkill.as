class WhirlwindSkill : ICompositeActorSkill
{
	AnimString@ m_anim;
	
	UnitPtr m_unit;
	int m_id;
	CompositeActorBehavior@ m_behavior;
	
	int m_cooldown;
	int m_cooldownC;

	int m_castpoint;
	int m_duration;
	int m_freq;
	int m_castingC;
	int m_freqC;
	
	float m_currSpeed;
	float m_speed;
	float m_acceleration;
	bool m_accelerate;
	float m_turnSpeed;
	float m_dir;
	
	SoundEvent@ m_sound;
	SoundInstance@ m_soundI;
	
	array<IEffect@>@ m_effects;
	
	CompositeActorSkillRestrictions m_restrictions;
	
	
	WhirlwindSkill(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		
		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));
		
		m_speed = GetParamFloat(unit, params, "speed");
		m_acceleration = GetParamFloat(unit, params, "acceleration", false, m_speed);
		m_turnSpeed = GetParamFloat(unit, params, "turnspeed", false, 1.0f);
		m_duration = GetParamInt(unit, params, "duration");
		m_freq = GetParamInt(unit, params, "freq");
		m_castpoint = GetParamInt(unit, params, "castpoint");
	
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));	
		@m_effects = LoadEffects(unit, params);
		
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
	
	void OnDamaged() {}
	void Destroyed() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}
	
	void OnDeath() 
	{
		CancelSkill();
	}
	
	void CancelSkill()
	{
		m_castingC = 0;
	
		if (m_soundI !is null)
		{
			m_soundI.Stop();
			@m_soundI = null;
		}

		if (Network::IsServer())
			(Network::Message("UnitUseSSkill") << m_unit << m_id << 1 << xy(m_unit.GetPosition())).SendToAll();
	}
	
	void NetUseSkill(int stage, SValue@ param) 
	{
		if (stage == 0)
		{
			m_restrictions.UseCharge();
		
			m_currSpeed = 0;
			m_cooldownC = m_cooldown;
			m_castingC = m_duration;
			m_freqC = m_castpoint;
			m_accelerate = false;

			vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			m_dir = atan(dir.y, dir.x);

			m_behavior.SetUnitScene(m_anim.GetSceneName(m_behavior.m_movement.m_dir), true);
			if (m_sound !is null)
				@m_soundI = m_sound.PlayTracked(m_unit.GetPosition());
		}
		else if (stage == 1)
			CancelSkill();
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_soundI !is null)
			m_soundI.SetPosition(m_unit.GetPosition());
		
		if (m_castingC > 0)
		{
			if (m_accelerate)
				m_currSpeed = min(m_speed, m_currSpeed + m_acceleration * dt / 1000.0f);
		
			vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
				dir = addrot(dir, randfn() * (PI / 4));

			float angle = atan(dir.y, dir.x);

			vec2 moveDir = vec2(cos(m_dir), sin(m_dir));
			m_dir = lerprot(m_dir, angle, m_turnSpeed);

			if (Network::IsServer())
			{
				auto body = m_unit.GetPhysicsBody();
			
				if (m_currSpeed > 0)
					body.SetStatic(false);

				body.SetLinearVelocity(moveDir * m_currSpeed);
			}
			
			m_freqC -= dt;
			if (m_freqC <= 0)
			{
				m_freqC += m_freq;
				m_accelerate = true;
				
				vec2 pos = xy(m_unit.GetPosition());
				ApplyEffects(m_effects, m_behavior, m_unit, pos, moveDir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 1, 1);
			}
			
			m_castingC -= dt;
			if (m_castingC <= 0)
				CancelSkill();
		}
	
		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}

		if (Network::IsServer() && m_cooldownC <= 0 && !isCasting && !IsCasting() && m_restrictions.IsAvailable())
		{
			if (m_restrictions.CanSee(m_behavior.m_target.m_unit))
			{
				NetUseSkill(0, null);
				UnitHandler::NetSendUnitUseSkill(m_unit, m_id);
				return;
			}
			else
				m_cooldownC = m_cooldown;
		}
	}
	
	bool IsCasting()
	{
		return m_castingC > 0;
	}
}