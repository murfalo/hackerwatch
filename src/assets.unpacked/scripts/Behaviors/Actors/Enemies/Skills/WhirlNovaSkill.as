class WhirlNovaSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;

	AnimString@ m_anim;

	int m_cooldown;
	int m_cooldownC;

	int m_castpoint;
	int m_castpointC;

	int m_duration;
	int m_durationC;

	int m_animationC;

	UnitProducer@ m_projProd;

	SoundEvent@ m_startSnd;
	SoundEvent@ m_fireSnd;
	
	string m_offset;
	CompositeActorSkillRestrictions m_restrictions;

	float m_projDist;
	int m_projDelay;
	int m_perRev;

	bool m_targeted;
	float m_angleOffset;
	

	WhirlNovaSkill(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));

		m_cooldown = GetParamInt(unit, params, "cooldown", false);
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, m_cooldown);

		m_castpoint = GetParamInt(unit, params, "castpoint");

		m_duration = GetParamInt(unit, params, "duration", false, 1000);
		@m_projProd = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));

		@m_startSnd = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));
		@m_fireSnd = Resources::GetSoundEvent(GetParamString(unit, params, "fire-snd", false));

		m_projDist = GetParamFloat(unit, params, "proj-dist", false);
		m_projDelay = GetParamInt(unit, params, "proj-delay", false, 33);
		m_perRev = GetParamInt(unit, params, "per-revolution", false, 1);

		m_targeted = GetParamBool(unit, params, "targeted", false, false);
		m_angleOffset = GetParamInt(unit, params, "angle-offset", false, 0) * PI / 180.0f;
		
		m_offset = GetParamString(unit, params, "offset", false, "");
		
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
	
	void CancelSkill() 
	{
		m_durationC = 0;
		m_castpointC = 0;
	}

	void Update(int dt, bool isCasting)
	{
		if (IsCasting())
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);

		if (m_animationC > 0)
			m_animationC -= dt;

		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}

		float startAngle = m_angleOffset;
		if (m_targeted && m_behavior.m_target !is null)
		{
			vec2 targetDir = xy(normalize(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			startAngle += atan(targetDir.y, targetDir.x);
		}

		if (!isCasting && Network::IsServer() && m_restrictions.IsAvailable() && m_restrictions.CanSee(m_behavior.m_target.m_unit))
		{
			NetUseSkill(0, null);
			UnitHandler::NetSendUnitUseSkill(m_unit, m_id);
		}

		if (m_castpointC > 0)
		{
			m_castpointC -= dt;
			if (m_castpointC <= 0)
				m_durationC = m_duration;
		}

		if (m_durationC > 0)
		{
			if (m_durationC % m_projDelay < dt)
			{
				int i = m_durationC / m_projDelay;
				float angle = startAngle + ((2 * PI / m_perRev) * i);
				vec2 shootDir = vec2(cos(angle), sin(angle));
				vec3 projPos = xyz(FetchOffsetPos(m_unit, m_offset) + shootDir * m_projDist);
				UnitPtr proj = m_projProd.Produce(g_scene, projPos);
				if (proj.IsValid())
				{
					IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
					if (p !is null)
						p.Initialize(m_behavior, shootDir, 1.0, false, null, 0);
					PlaySound3D(m_fireSnd, projPos);
				}
			}
			m_durationC -= dt;
			if (m_durationC <= 0)
				m_cooldownC = m_cooldown;
		}
	}

	bool IsCasting()
	{
		return m_durationC > 0 || m_castpointC > 0 || m_animationC > 0;
	}

	void OnDamaged() { }
	void OnDeath() { }
	void Destroyed() { }
	void OnCollide(UnitPtr unit, vec2 normal) { }

	void NetUseSkill(int stage, SValue@ param)
	{
		if (m_castpoint > 0)
			m_castpointC = m_castpoint;
		else
			m_durationC = m_duration;
		m_cooldownC = 0;

		m_animationC = m_behavior.SetUnitScene(m_anim.GetSceneName(m_behavior.m_movement.m_dir), true);
		PlaySound3D(m_startSnd, m_unit.GetPosition());
		
		m_restrictions.UseCharge();
	}
}
