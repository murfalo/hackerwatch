class BossScatterBurstSkill : CompositeActorBurstSkill
{
	Actor@ m_currTarget;
	
	BossScatterBurstSkill(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}
	
	Actor@ GetTarget() override
	{
		if (m_currTarget is null)
			return m_behavior.m_target;
	
		return m_currTarget;
	}
	
	
	void NetUseSkill(int stage, SValue@ param) override
	{
		if (stage == 100)
		{
			if (param !is null && param.GetType() == SValueType::Integer)
			{
				auto newTarget = g_scene.GetUnit(param.GetInteger());
				if (newTarget.IsValid())
					@m_currTarget = cast<Actor>(newTarget.GetScriptBehavior());
			}
			
			return;
		}
		
		CompositeActorBurstSkill::NetUseSkill(stage, param);
	}
	
	
	void NewBurstShot() override
	{
		if (m_behavior.m_target is null)
		{
			@m_currTarget = null;
			return;
		}
		
		if (!Network::IsServer())
			return;
		
		auto possibleTargets = g_scene.FetchActorsWithOtherTeam(m_behavior.Team, xy(m_behavior.m_unit.GetPosition()), uint(sqrt(m_restrictions.m_rangeSq)));
		
		array<Actor@> targets;
		for (uint i = 0; i < possibleTargets.length(); i++)
		{
			Actor@ a = cast<Actor>(possibleTargets[i].GetScriptBehavior());
			if (!a.IsDead() && a.IsTargetable())
				targets.insertLast(a);
		}
		
		auto ts = randi(targets.length());
		for (uint i = 0; i < targets.length(); i++)
		{
			Actor@ a = targets[(ts + i) % targets.length()];
			if (!a.IsDead() && a.IsTargetable())
			{
				@m_currTarget = a;
				SValueBuilder@ builder = SValueBuilder();
				builder.PushInteger(a.m_unit.GetId());
				UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 100, builder.Build());
				return;	
			}
		}
	}
}
