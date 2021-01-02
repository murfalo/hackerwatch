class JumpStrike : ICompositeActorSkill
{
	AnimString@ m_anim;
	
	UnitPtr m_unit;
	int m_id;
	CompositeActorBehavior@ m_behavior;
	
	int m_cooldown;
	int m_cooldownC;
	
	int m_holdFrame;
	int m_preCast;
	int m_preCastC;
	int m_postCastC;
	int m_castingC;
		
	SoundEvent@ m_sound;
	SoundEvent@ m_soundStart;
	
	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_finishedEffects;
	
	vec2 m_dir;
	string m_currAnim;
	float m_speed;
	int m_airTime;
	int m_jumpHeight;
	bool m_glide;
	
	CompositeActorSkillRestrictions m_restrictions;

	string m_offset;
	
	
	JumpStrike(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		
		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));
		m_holdFrame = max(1, GetParamInt(unit, params, "hold-frame", false, 1));
		m_preCast = GetParamInt(unit, params, "pre-cast", false, m_holdFrame);
		
		m_restrictions.Load(unit, params);
		
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
		@m_soundStart = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));
		
		m_speed = GetParamFloat(unit, params, "speed");
		m_airTime = GetParamInt(unit, params, "air-time");
		m_jumpHeight = GetParamInt(unit, params, "jump-height");
		m_glide = GetParamBool(unit, params, "glide", false, false);
		
		@m_effects = LoadEffects(unit, params);
		@m_finishedEffects = LoadEffects(unit, params, "finish-");

		m_offset = GetParamString(unit, params, "offset", false);
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
	void OnDeath() {}
	
	void Destroyed()
	{
		m_unit.SetPositionZ(0);
	}
	
	void OnCollide(UnitPtr unit, vec2 normal)
	{
		if (m_castingC <= 0)
			return;

		if (cast<Pickup>(unit.GetScriptBehavior()) !is null)
			return;
	
		vec2 dir = m_behavior.GetDirection();
		vec2 pos = FetchOffsetPos(m_unit, m_offset);
		
		ApplyEffects(m_effects, m_behavior, unit, pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);
		
		if (unit.GetUnitProducer() !is m_unit.GetUnitProducer())
			CancelSkill();
	}
	
	void CancelSkill() override
	{
		bool wasCasting = IsCasting();
	
		m_cooldownC = m_cooldown;
		m_preCastC = 0;
		m_castingC = 0;
		m_postCastC = 0;
		m_unit.SetPositionZ(0);
		
		//m_behavior.m_movement.m_collideWithFriends = true;
		m_unit.SetShouldCollideWithSame(true);
		
		if (wasCasting)
		{
			vec2 dir = m_behavior.GetDirection();
			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			ApplyEffects(m_finishedEffects, m_behavior, UnitPtr(), pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);
		}
		
		if (Network::IsServer())
			(Network::Message("UnitUseSSkill") << m_unit << m_id << 1 << xy(m_unit.GetPosition())).SendToAll();
	}
	
	void NetUseSkill(int stage, SValue@ param) 
	{
		if (stage == 1)
			CancelSkill();
	}

	void BeginCast()
	{
		m_castingC = m_airTime;
		PlaySound3D(m_sound, m_unit);
	}

	void StopSkillPost()
	{
		CancelSkill();
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}
		
		if (m_cooldownC <= 0  && !isCasting && !IsCasting() && m_restrictions.IsAvailable())
		{
			if (m_restrictions.CanSee(m_behavior.m_target.m_unit))
			{
				m_cooldownC = 0;
				m_preCastC = m_preCast;
				
				m_dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
				if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
					m_dir = addrot(m_dir, randfn() * (PI / 4));
				float dir = atan(m_dir.y, m_dir.x);
				m_currAnim = m_anim.GetSceneName(dir);
				
				int animTime = m_behavior.SetUnitScene(m_currAnim, true);
				if (m_holdFrame == 0)
					m_postCastC = 0;
				else
					m_postCastC = animTime - m_holdFrame;

				PlaySound3D(m_soundStart, m_unit);

				//m_behavior.m_movement.m_collideWithFriends = false;
				m_unit.SetShouldCollideWithSame(false);
				m_restrictions.UseCharge();
				return;
			}
			else
				m_cooldownC = m_cooldown;
		}
		
		
		if (!IsCasting())
			return;
		
		m_behavior.SetUnitScene(m_currAnim, false);
		
		vec2 vel;
		if (m_preCastC > 0)
		{
			m_preCastC -= dt;
			if (m_preCastC <= 0)
			{
				//if (IsAvailable())
					BeginCast();
			}
		}
		else if(m_castingC > 0)
		{
			if (m_holdFrame > 0)
				m_unit.SetUnitSceneTime(m_holdFrame);
			vel = m_dir * m_speed;
			
			if (Network::IsServer() && m_jumpHeight > 0)
			{
				float h = (sin(m_castingC * PI / m_airTime)) * m_jumpHeight;
				m_unit.SetPositionZ(h, true);
			}
			
			m_castingC -= dt;
			if (m_castingC <= 0 && m_postCastC <= 0)
				StopSkillPost();
		}		
		else if (m_postCastC > 0)
		{
			if (m_glide)
				vel = m_dir * m_speed * (m_postCastC / float(m_unit.GetCurrentUnitScene().Length() - m_holdFrame));
		
			m_postCastC -= dt;
			if (m_postCastC <= 0)
				StopSkillPost();
		}
		
		if (Network::IsServer())
			//m_unit.GetPhysicsBody().ApplyForce(vel);
			//m_unit.GetPhysicsBody().ApplyForce(vel * dt / 100.0f);
			m_unit.GetPhysicsBody().SetLinearVelocity(vel);
	}
	
	bool IsCasting()
	{
		return m_preCastC > 0 || m_castingC > 0 || m_postCastC > 0;
	}
}