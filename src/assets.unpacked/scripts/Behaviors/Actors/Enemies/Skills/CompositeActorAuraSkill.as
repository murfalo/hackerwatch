class CompositeActorAuraSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;

	ActorBuffDef@ m_buff;
	int m_freq;
	int m_range;
	bool m_friendly;
	
	int m_timer;
	array<ISkillConditional@>@ m_conditionals;
	
	
	CompositeActorAuraSkill(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	
		@m_buff = LoadActorBuff(GetParamString(unit, params, "buff", true));
		m_freq = GetParamInt(unit, params, "freq", true, 1000);
		m_range = GetParamInt(unit, params, "range", true, 150);
		m_friendly = GetParamBool(unit, params, "friendly", false, true);
		m_timer = randi(m_freq);
		
		@m_conditionals = LoadSkillConditionals(unit, params);
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		@m_behavior = behavior;
	}

	void Save(SValueBuilder& builder)
	{
	}

	void Load(SValue@ sval)
	{
	}
	
	void Update(int dt, bool isCasting)
	{
		m_timer -= dt;
		if (m_timer <= 0)
		{
			m_timer += m_freq;
			
			if (!CheckConditionals(m_conditionals, m_behavior))
				return;
			
			array<UnitPtr>@ targets;
			
			if (m_friendly)
				@targets = g_scene.FetchActorsWithTeam(m_behavior.Team, xy(m_unit.GetPosition()), m_range);
			else
				@targets = g_scene.FetchActorsWithOtherTeam(m_behavior.Team, xy(m_unit.GetPosition()), m_range);
			
			for (uint i = 0; i < targets.length(); i++)
				if (targets[i] != m_unit)
					cast<Actor>(targets[i].GetScriptBehavior()).ApplyBuff(ActorBuff(m_behavior, m_buff, 1.0f, false));
		}
	}
	
	void OnDamaged() {}
	void OnDeath() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}
	void OnSpawn() {}
	void Destroyed() {}
	void NetUseSkill(int stage, SValue@ param) {}
	bool IsCasting() { return false; }
	void CancelSkill() {}
}
