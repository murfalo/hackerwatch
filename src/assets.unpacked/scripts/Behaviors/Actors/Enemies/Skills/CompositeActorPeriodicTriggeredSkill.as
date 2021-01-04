class CompositeActorPeriodicTriggeredSkill : CompositeActorTriggeredSkill
{
	int m_period;
	float m_periodC;

	int m_periodRandom;

	bool m_mustHaveTarget;
	
	vec2 m_lastPos;
	
	
	CompositeActorPeriodicTriggeredSkill(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		string trigger = GetParamString(unit, params, "trigger");
		if (trigger == "OnMove")
			m_trigger = SkillTrigger::OnMove;
		else if (trigger == "OnTime")
			m_trigger = SkillTrigger::OnTime;
			
		m_period = GetParamInt(unit, params, "period", false, 100);
		m_periodRandom = GetParamInt(unit, params, "period-rand", false);
		m_periodC = float(m_period + m_periodRandom);

		m_mustHaveTarget = GetParamBool(unit, params, "must-have-target", false);
		m_castTarget = m_unit;
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id) override
	{
		CompositeActorTriggeredSkill::Initialize(unit, behavior, id);
		m_lastPos = xy(m_unit.GetPosition());
	}
	
	void Update(int dt, bool isCasting) override
	{
		CompositeActorTriggeredSkill::Update(dt, isCasting);

		if (!Network::IsServer())
			return;
		
		if (m_castPointC > 0 || isCasting)
			return;

		if (m_mustHaveTarget && m_behavior.m_target is null)
			return;

		if (m_trigger == SkillTrigger::OnMove)
		{
			auto pos = xy(m_unit.GetPosition());
			auto movedDt = dist(pos, m_lastPos);
			m_lastPos = pos;
			
			m_periodC -= movedDt;
		}
		else if (m_trigger == SkillTrigger::OnTime)
			m_periodC -= dt;

		if (m_periodC <= 0)
		{
			m_periodC += m_period + randi(m_periodRandom);
		
			if (!IsAvailable())
				return;

			Trigger(m_unit);
		}
	}
}
