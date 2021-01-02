interface ICompositeActorSkill
{
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id);
	void Update(int dt, bool isCasting);
	bool IsCasting();
	void OnDamaged();
	void OnDeath();
	void Destroyed();
	void OnCollide(UnitPtr unit, vec2 normal);
	void CancelSkill();
	
	void NetUseSkill(int stage, SValue@ param);

	void Save(SValueBuilder& builder);
	void Load(SValue@ sval);
}

class CompositeActorSkillRestrictions
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	
	int m_charges;
	int m_rangeSq;
	int m_minRangeSq;
	bool m_mustSee;
	
	array<ISkillConditional@>@ m_conditionals;
	
	
	void Load(UnitPtr unit, SValue& params)
	{
		m_rangeSq = GetParamInt(unit, params, "range");
		m_rangeSq = m_rangeSq * m_rangeSq;
		
		m_minRangeSq = GetParamInt(unit, params, "min-range", false, 0);
		m_minRangeSq = m_minRangeSq * m_minRangeSq;
		
		m_mustSee = GetParamBool(unit, params, "must-see", false, true);
		m_charges = GetParamInt(unit, params, "charges", false, -1);
		
		@m_conditionals = LoadSkillConditionals(unit, params);
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior)
	{
		m_unit = unit;
		@m_behavior = behavior;
	}
	
	bool IsAvailable()
	{
		if (m_charges == 0)
			return false;
	
		if (m_behavior.m_target is null)
			return false;
	
		int distSq = distsq(m_unit, m_behavior.m_target);
	
		if (distSq > m_rangeSq)
			return false;
			
		if (distSq < m_minRangeSq)
			return false;
			
		if (m_behavior.m_buffs.Disarm())
			return false;
			
		return CheckConditionals(m_conditionals, m_behavior);
	}
	
	bool CanSee(UnitPtr unit)
	{
		if (!m_mustSee)
			return true;
	
		if (!unit.IsValid())
			return false;
	
		RaycastResult res = g_scene.RaycastClosest(xy(m_unit.GetPosition()), xy(unit.GetPosition()), ~0, RaycastType::Aim);
		UnitPtr res_unit = res.FetchUnit(g_scene);
		
		if (!res_unit.IsValid())
			return true;
		
		return (res_unit == unit);
	}
	
	void UseCharge()
	{
		if (m_charges > 0)
			m_charges--;
	}
	
	void Save(SValueBuilder& builder)
	{
		if (m_charges >= 0)
			builder.PushInteger("charges", m_charges);
	}

	void Load(SValue@ sval)
	{
		m_charges = GetParamInt(UnitPtr(), sval, "charges", false, m_charges);
	}
}

class CompositeActorSkill : ICompositeActorSkill
{
	array<AnimString@> m_anims;
	int m_currAnim;
	
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;
	
	int m_cooldown;
	int m_cooldownC;
	
	int m_castPoint;
	int m_castPointC;
	int m_castC;
	
	string m_offset;
	
	SoundEvent@ m_sound;
	SoundEvent@ m_startSound;
	array<IAction@>@ m_actions;
	array<IAction@>@ m_startActions;
	
	vec2 m_skillAimDir;
	bool m_goodAim;
	float m_interceptSpeed;
	
	CompositeActorSkillRestrictions m_restrictions;
	
	
	CompositeActorSkill(UnitPtr unit, SValue& params)
	{
		array<SValue@>@ animArr = GetParamArray(unit, params, "anims", false);
		if (animArr !is null)
		{
			for (uint i = 0; i < animArr.length(); i++)
				m_anims.insertLast(AnimString(animArr[i].GetString()));
		}
		else
			m_anims.insertLast(AnimString(GetParamString(unit, params, "anim")));
			
		m_currAnim = 0;

		
		m_restrictions.Load(unit, params);
		
		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, m_cooldown); //randi(m_cooldown);
		m_castPoint = max(1, GetParamInt(unit, params, "castpoint", false, 1));
		
		m_offset = GetParamString(unit, params, "offset", false, "");

		m_goodAim = GetParamBool(unit, params, "good-aim", false, true);
		m_interceptSpeed = GetParamFloat(unit, params, "aim-interception", false, -1);
		
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
		@m_startSound = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));
		
		@m_actions = LoadActions(unit, params);
		@m_startActions = LoadActions(unit, params, "start-");
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
		m_castPointC = 0;
		m_castC = 0;
	}
	
	void OnDamaged() {}
	void OnDeath() {}
	void Destroyed() { }
	void OnCollide(UnitPtr unit, vec2 normal) {}
	
	void NetUseSkill(int stage, SValue@ param) 
	{
		if (stage == 0)
		{
			PlaySound3D(m_startSound, m_unit);

			if (m_behavior.m_target !is null)
			{
				vec2 dir = xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition());
				if (dir.x != 0 || dir.y != 0)
					m_behavior.m_movement.m_dir = atan(dir.y, dir.x);
			}
		
			m_cooldownC = 0;
			m_castPointC = m_castPoint;
			
			
			m_castC = m_behavior.SetUnitScene(m_anims[m_currAnim].GetSceneName(m_behavior.m_movement.m_dir), true);
			m_currAnim = (m_currAnim + 1) % m_anims.length();
			
			
			if (m_startActions.length() > 0)
			{
				CalcAimDir();
				vec2 pos = FetchOffsetPos(m_unit, m_offset);

				NetDoActions(m_startActions, param, m_behavior, pos, m_skillAimDir);
			}
			else if (!m_goodAim)
				CalcAimDir();
		}	
		else
		{
			PlaySound3D(m_sound, m_unit);

			if (m_goodAim)
				CalcAimDir();
			
			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			NetDoActions(m_actions, param, m_behavior, pos, m_skillAimDir);
			
			m_restrictions.UseCharge();
		}
	}
	
	void CalcAimDir()
	{
		if (m_behavior.m_target is null)
			return;
	
		vec2 pos = FetchOffsetPos(m_unit, m_offset);
		if (m_interceptSpeed > 0)
		{
			auto tpos = intercept(pos, xy(m_behavior.m_target.m_unit.GetPosition()), m_behavior.m_target.m_unit.GetMoveDir(), m_interceptSpeed);
			m_skillAimDir = normalize(tpos - pos);
		}
		else
			m_skillAimDir = normalize(xy(m_behavior.m_target.m_unit.GetPosition()) - pos);

		if (m_behavior.m_buffs.Confuse() && !m_behavior.m_buffs.AntiConfuse())
			m_skillAimDir = addrot(m_skillAimDir, randfn() * PI / 3.0f);
	}
	
	void Update(int dt, bool isCasting)
	{
		if (isCasting && IsCasting())
			isCasting = false;
	
		if (m_castC > 0)
		{
			vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			m_behavior.m_movement.m_dir = atan(dir.y, dir.x);
		
			auto body = m_unit.GetPhysicsBody();
			if (body !is null)
				body.SetLinearVelocity(0, 0);
		
			m_castC -= dt;
			if (m_castC <= 0)
				m_cooldownC = m_cooldown;
		}
		
		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}
		
		if (Network::IsServer())
		{
			if (m_cooldownC <= 0 && !isCasting && m_castC <= 0 && m_restrictions.IsAvailable())
			{
				vec2 dir = xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition());
				if (dir.x != 0 || dir.y != 0)
					m_behavior.m_movement.m_dir = atan(dir.y, dir.x);
			
				if (m_restrictions.CanSee(m_behavior.m_target.m_unit))
				{
					m_cooldownC = 0;
					m_castPointC = m_castPoint;

					PlaySound3D(m_startSound, m_unit);
					
					m_castC = m_behavior.SetUnitScene(m_anims[m_currAnim].GetSceneName(m_behavior.m_movement.m_dir), true);
					m_currAnim = (m_currAnim + 1) % m_anims.length();
					
					
					if (m_startActions.length() > 0)
					{
						CalcAimDir();
						vec2 pos = FetchOffsetPos(m_unit, m_offset);
						SValue@ param = DoActions(m_startActions, m_behavior, m_behavior.m_target, pos, m_skillAimDir);
						UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0, param);
					}
					else 
					{
						UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0);
						
						if (!m_goodAim)
							CalcAimDir();
					}
				}
				else
					m_cooldownC = m_cooldown;
			}

			if (m_castPointC > 0)
				HandleCastpoint(dt);
		}

		for (uint i = 0; i < m_actions.length(); i++)
			m_actions[i].Update(dt, m_cooldownC);
	}

	void HandleCastpoint(int dt)
	{
		m_castPointC -= dt;
		if (m_castPointC > 0)
			return;

		//if (!IsAvailable())
		//	return;

		PlaySound3D(m_sound, m_unit);

		if (m_goodAim)
			CalcAimDir();

		vec2 pos = FetchOffsetPos(m_unit, m_offset);
		SValue@ param = DoActions(m_actions, m_behavior, m_behavior.m_target, pos, m_skillAimDir);
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 1, param);

		m_restrictions.UseCharge();
	}
	
	bool IsCasting()
	{
		return m_castC > 0;
	}
}
