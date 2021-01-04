enum SkillTrigger
{
	None,
	OnDeath,
	OnDamaged,
	OnCollide,
	OnSpawn,
	OnMove,
	OnTime
}

class CompositeActorTriggeredSkill : ICompositeActorSkill
{
	SkillTrigger m_trigger;
	bool m_targetSelf;

	AnimString@ m_anim;

	SoundEvent@ m_sndStart;

	int m_castPoint;
	int m_castPointC;
	vec2 m_castDir;
	vec2 m_castPos;
	UnitPtr m_castTarget;
	
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	Actor@ m_owner;
	int m_id;
	
	array<IAction@>@ m_actions;
	array<IAction@>@ m_startActions;
	array<IEffect@>@ m_effects;

	array<ISkillConditional@>@ m_conditionals;
	
	bool m_spawned;
	int m_animTimeC;
	int m_cooldown;
	int m_cooldownC;
	int m_charges;
	string m_offset;
	
	int m_rangeSq;
	int m_minRangeSq;
	
	
	CompositeActorTriggeredSkill(UnitPtr unit, SValue& params)
	{
		m_trigger = SkillTrigger::None;
		string trigger = GetParamString(unit, params, "trigger");

		if (trigger == "OnDeath")
			m_trigger = SkillTrigger::OnDeath;
		else if (trigger == "OnDamaged")
			m_trigger = SkillTrigger::OnDamaged;
		else if (trigger == "OnCollide")
			m_trigger = SkillTrigger::OnCollide;
		else if (trigger == "OnSpawn")
			m_trigger = SkillTrigger::OnSpawn;

		
		@m_actions = LoadActions(unit, params);
		@m_startActions = LoadActions(unit, params, "start-");
		@m_effects = LoadEffects(unit, params);

		m_targetSelf = GetParamBool(unit, params, "targetself", false, true);
		
		@m_conditionals = LoadSkillConditionals(unit, params);

		string strAnim = GetParamString(unit, params, "anim", false);
		if (strAnim != "")
			@m_anim = AnimString(strAnim);

		@m_sndStart = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));

		m_castPoint = GetParamInt(unit, params, "castpoint", false);
		m_cooldown = GetParamInt(unit, params, "cooldown", false, 0);
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, m_cooldown);
		m_charges = GetParamInt(unit, params, "charges", false, -1);
		m_offset = GetParamString(unit, params, "offset", false, "");
		
		
		m_rangeSq = GetParamInt(unit, params, "range", false, -1);
		if (m_rangeSq > 0)
			m_rangeSq = m_rangeSq * m_rangeSq;
		
		m_minRangeSq = GetParamInt(unit, params, "min-range", false, -1);
		if (m_minRangeSq > 0)
			m_minRangeSq = m_minRangeSq * m_minRangeSq;
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_owner = @m_behavior = behavior;
		m_id = id;
	}

	void Save(SValueBuilder& builder)
	{
	}

	void Load(SValue@ sval)
	{
	}
	
	bool IsAvailable()
	{
		if (m_charges == 0)
			return false;
			
		if (m_rangeSq > 0 || m_minRangeSq > 0)
		{
			if (m_behavior.m_target is null)
				return false;
		
			int distSq = distsq(m_unit, m_behavior.m_target);
		
			if (m_rangeSq > 0 && distSq > m_rangeSq)
				return false;
				
			if (m_minRangeSq > 0 && distSq < m_minRangeSq)
				return false;
		}
	
		return CheckConditionals(m_conditionals, m_behavior);
	}
	
	void Update(int dt, bool isCasting)
	{
		if (m_cooldownC > 0)
			m_cooldownC -= dt;

		if (m_castPointC > 0)
		{
			m_castPointC -= dt;
			if (m_castPointC <= 0)
				CastTrigger();
		}

		if (m_animTimeC > 0)
			m_animTimeC -= dt;

		if (!m_spawned)
		{
			m_spawned = true; // TODO: Save flag
			OnSpawn();
		}
		
		for (uint i = 0; i < m_startActions.length(); i++)
			m_startActions[i].Update(dt, 0);
		
		for (uint i = 0; i < m_actions.length(); i++)
			m_actions[i].Update(dt, 0);
	}
	
	void OnDamaged() 
	{
		if (m_trigger != SkillTrigger::OnDamaged)
			return;
			
		if (!IsAvailable())
			return;

		UnitPtr target;
		if (m_targetSelf)
			target = m_unit;

		Trigger(target);
	}
	
	void OnDeath()
	{
		if (m_trigger != SkillTrigger::OnDeath)
			return;
			
		if (!Network::IsServer())
			return;
			
		if (!IsAvailable())
			return;

		UnitPtr target;
		if (m_targetSelf)
			target = m_unit;

		Trigger(target);
	}
	
	void OnCollide(UnitPtr unit, vec2 normal) 
	{
		if (m_trigger != SkillTrigger::OnCollide)
			return;
			
		if (!IsAvailable())
			return;

		UnitPtr target;
		if (m_targetSelf)
			target = m_unit;
		else
			target = unit;

		Trigger(target);
	}

	void OnSpawn()
	{
		if (m_trigger != SkillTrigger::OnSpawn)
			return;
			
		if (!IsAvailable())
			return;

		UnitPtr target;
		if (m_targetSelf)
			target = m_unit;

		Trigger(target);
	}
	
	bool IsCasting()
	{
		return m_animTimeC > 0;
	}
	
	void NetUseSkill(int stage, SValue@ param)
	{
		if (stage == 0)
			NetTrigger(param);
		else if (stage == 1)
		{
			vec2 dir = m_behavior.GetCastDirection();
			vec2 pos = FetchOffsetPos(m_unit, m_offset);

			NetDoActions(m_actions, param, m_owner, pos, dir);
			if (m_castTarget.IsValid())
			{
				auto b = cast<Actor>(m_castTarget.GetScriptBehavior());
				if (b !is null and !b.IsTargetable())
					return;
				
				ApplyEffects(m_effects, m_owner, m_castTarget, pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer());
			}
			
			if (m_charges > 0)
				m_charges--;
		}
	}

	void Trigger(UnitPtr target)
	{
		if (m_cooldownC > 0)
			return;
		m_cooldownC = m_cooldown;

		m_castDir = m_behavior.GetCastDirection();
		m_castPos = FetchOffsetPos(m_unit, m_offset);

		if (m_anim !is null)
		{
			m_unit.SetUnitScene(m_anim.GetSceneName(atan(m_castDir.y, m_castDir.x)), true);
			m_animTimeC = m_unit.GetCurrentUnitScene().Length();
		}

		if (m_sndStart !is null)
			PlaySound3D(m_sndStart, m_unit);

		SValue@ param = DoActions(m_startActions, m_owner, m_behavior.m_target, m_castPos, m_castDir, m_behavior.m_buffs.DamageMul());
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0, param);

		m_castPointC = m_castPoint;
		m_castTarget = target;

		if (m_castPointC <= 0)
			CastTrigger();
	}

	void NetTrigger(SValue@ param)
	{
		vec2 dir = m_behavior.GetCastDirection();
	
		if (m_anim !is null)
		{
			m_unit.SetUnitScene(m_anim.GetSceneName(atan(dir.y, dir.x)), true);
			m_animTimeC = m_unit.GetCurrentUnitScene().Length();
		}
		
		if (m_startActions.length() > 0)
		{
			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			NetDoActions(m_startActions, param, m_owner, pos, dir);
		}
	}

	void CastTrigger()
	{
		SValue@ param = DoActions(m_actions, m_owner, m_behavior.m_target, m_castPos, m_castDir, m_behavior.m_buffs.DamageMul());
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 1, param);
		
		if (m_castTarget.IsValid())
		{
			auto b = cast<Actor>(m_castTarget.GetScriptBehavior());
			if (b !is null and !b.IsTargetable())
				return;
			
			ApplyEffects(m_effects, m_owner, m_castTarget, m_castPos, m_castDir, m_behavior.m_buffs.DamageMul(), !Network::IsServer());
		}
		
		if (m_charges > 0)
			m_charges--;
	}
	
	void Destroyed() { }
	void CancelSkill() {}
}
