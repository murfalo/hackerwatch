class EnemyMeleeStrike : ICompositeActorSkill
{
	AnimString@ m_anim;
	
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;
	
	int m_cooldown;
	int m_cooldownC;
	
	int m_castPoint;
	int m_castPointC;
	int m_castC;
	
	int m_dmgRangeSq;
	float m_arc;
	string m_offset;
	
	SoundEvent@ m_sound;	
	array<IEffect@>@ m_effects;
	
	CompositeActorSkillRestrictions m_restrictions;
	
	
	EnemyMeleeStrike(UnitPtr unit, SValue& params)
	{
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		
		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));
		m_castPoint = max(1, GetParamInt(unit, params, "castpoint", false, 1));
		
		m_offset = GetParamString(unit, params, "offset", false, "");
		
		m_restrictions.Load(unit, params);
		
		m_dmgRangeSq = GetParamInt(unit, params, "dmg-range", false, 0);
		m_dmgRangeSq = m_dmgRangeSq * m_dmgRangeSq;
		
		if (m_dmgRangeSq <= 0)
			m_dmgRangeSq = m_restrictions.m_rangeSq;
		
		
		m_arc = GetParamInt(unit, params, "arc", false, 90) * PI / 180;
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
		@m_effects = LoadEffects(unit, params);
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
	void Destroyed() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}
	
	void CancelSkill() 
	{
		m_castPointC = 0;
		m_castC = 0;
	}
	
	void NetUseSkill(int stage, SValue@ param)
	{
		m_cooldownC = 0;
		m_castPointC = m_castPoint;
		
		m_castC = m_behavior.SetUnitScene(m_anim.GetSceneName(m_behavior.m_movement.m_dir), true);
		
		if (m_behavior.m_target !is null)
		{
			vec2 dir = xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition());
			if (dir.x != 0 || dir.y != 0)
				m_behavior.m_movement.m_dir = atan(dir.y, dir.x);
		}
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_castC > 0)
		{
			if (m_castPointC <= 0)
			{
				vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
				m_behavior.m_movement.m_dir = atan(dir.y, dir.x);
			}
		
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);
		
			m_castC -= dt;
			if (m_castC <= 0)
				m_cooldownC = m_cooldown;
		}
		
		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}
		
		if (Network::IsServer() && m_cooldownC <= 0 && !isCasting && !IsCasting() && m_restrictions.IsAvailable() && m_restrictions.CanSee(m_behavior.m_target.m_unit))
		{
			NetUseSkill(0, null);
			UnitHandler::NetSendUnitUseSkill(m_unit, m_id);
		}
		
		if (m_castPointC <= 0)
			return;
			
		m_castPointC -= dt;
		
		if (m_castPointC <= 0)
		{
			PlaySound3D(m_sound, m_unit.GetPosition());
		
			//if (!Network::IsServer())
			//	return;
			
			if (m_behavior.m_target is null || m_behavior.m_buffs.Disarm())
				return;
			
			int distSq = distsq(m_unit, m_behavior.m_target);
			if (distSq > m_dmgRangeSq)
				return;

			vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));
			float angle = m_behavior.m_movement.m_dir - atan(dir.y, dir.x);
			angle += (angle > PI) ? -TwoPI : (angle < -PI) ? TwoPI : 0;

			if (abs(angle) <= m_arc / 2)
			{
				vec2 pos = FetchOffsetPos(m_unit, m_offset);
				auto results = g_scene.Raycast(pos, xy(m_behavior.m_target.m_unit.GetPosition()), ~0, RaycastType::Shot);
				for (uint i = 0; i < results.length(); i++)
				{
					UnitPtr res_unit = results[i].FetchUnit(g_scene);
					if (!res_unit.IsValid())
						continue;
						
					auto b = res_unit.GetScriptBehavior();
					if (b is m_behavior.m_target)
					{
						ApplyEffects(m_effects, m_behavior, m_behavior.m_target.m_unit, results[i].point, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer(), 0, 0);
						break;
					}
					
					auto d = cast<IDamageTaker>(b);
					if (d is null or d.Impenetrable())
						break;
				}
			}
			
			m_restrictions.UseCharge();
		}
	}
	
	bool IsCasting()
	{
		return m_castC > 0;
	}
}
