class NovaSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;

	AnimString@ m_anim;

	int m_cooldown;
	int m_cooldownC;

	int m_castpoint;
	int m_castpointC;
	
	int m_animationC;

	UnitProducer@ m_projProd;

	SoundEvent@ m_fireSnd;
	SoundEvent@ m_startSnd;

	float m_projDist;
	int m_projCount;
	
	CompositeActorSkillRestrictions m_restrictions;
	

	NovaSkill(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));

		m_cooldown = GetParamInt(unit, params, "cooldown", false);
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));

		m_restrictions.Load(unit, params);

		m_castpoint = GetParamInt(unit, params, "castpoint", false, unit.GetUnitScene(m_anim.GetSceneName(0)).Length());
		@m_projProd = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
		@m_fireSnd = Resources::GetSoundEvent(GetParamString(unit, params, "fire-snd", false));
		@m_startSnd = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));

		m_projDist = GetParamFloat(unit, params, "proj-dist", false);
		m_projCount = GetParamInt(unit, params, "proj-count", false, 8);
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
		m_animationC = 0;
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

		if (!isCasting)
		{
			if (!m_restrictions.IsAvailable())
				return;
				
			if (!m_restrictions.CanSee(m_behavior.m_target.m_unit))
				return;

			if (Network::IsServer())
			{
				NetUseSkill(0, null);
				UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0);
			}
		}

		if (Network::IsServer() && m_castpointC > 0)
		{
			m_castpointC -= dt;
			if (m_castpointC <= 0)
			{
				NetUseSkill(1, null);
				UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 1);
			}
		}
	}
	
	void FireProjectiles()
	{
		for (int i = 0; i < m_projCount; i++)
		{
			float angle = (2 * PI / m_projCount) * i;
			vec2 shootDir = vec2(cos(angle), sin(angle));
			vec3 projPos = xyz(xy(m_unit.GetPosition()) + shootDir * m_projDist);
			UnitPtr proj = m_projProd.Produce(g_scene, projPos);
			if (proj.IsValid())
			{
				IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
				if (p !is null)
					p.Initialize(m_behavior, shootDir, 1.0, false, m_behavior.m_target, 0);
			}
			m_cooldownC = m_cooldown;
		}
		PlaySound3D(m_fireSnd, m_unit.GetPosition());
		
		m_restrictions.UseCharge();
	}

	bool IsCasting()
	{
		return m_castpointC > 0 || m_animationC > 0;
	}

	void Destroyed() { }
	void OnDamaged() { }
	void OnDeath() { }
	void OnCollide(UnitPtr unit, vec2 normal) { }

	void NetUseSkill(int stage, SValue@ param)
	{
		if (stage == 0)
		{
			if (m_castpoint > 0)
				m_castpointC = m_castpoint;
			else
				FireProjectiles();

			m_animationC = m_behavior.SetUnitScene(m_anim.GetSceneName(m_behavior.m_movement.m_dir), true);
			PlaySound3D(m_startSnd, m_unit.GetPosition());
		}
		else if (stage == 1)
			FireProjectiles();
	}
}
