class ClearBuffs : IEffect, IAction
{
	bool m_onlyDebuffs;
	bool m_targetSelf;

	ClearBuffs(UnitPtr unit, SValue& params)
	{
		m_onlyDebuffs = GetParamBool(unit, params, "only-debuffs", false, true);
		m_targetSelf = GetParamBool(unit, params, "target-self", false, false);
	}

	void Update(int dt, int cooldown)
	{
	}

	void SetWeaponInformation(uint weapon) { }
	bool NeedNetParams() { return true; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		UnitPtr targetUnit;
		if (target !is null)
			targetUnit = target.m_unit;

		builder.PushInteger(targetUnit.GetId());

		return Apply(owner, targetUnit, pos, dir, intensity, false);
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		UnitPtr targetUnit = g_scene.GetUnit(param.GetInteger());
		return Apply(owner, targetUnit, pos, dir, 1.0f, true);
	}
	
	ActorBuffList@ GetBuffList(UnitPtr unit)
	{
		if (!unit.IsValid())
			return null;

		auto b = unit.GetScriptBehavior();

		auto cab = cast<CompositeActorBehavior>(b);
		if (cab !is null)
			return cab.m_buffs;
			
		auto pb = cast<PlayerBase>(b);
		if (pb !is null)
			return pb.m_buffs;
		
		return null;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		ActorBuffList@ buffs = null;
		if (m_targetSelf)
			@buffs = GetBuffList(owner.m_unit);
		else
			@buffs = GetBuffList(target);
			
		if (buffs is null)
			return false;
			
		if (m_onlyDebuffs)
		{
			for (uint i = 0; i < buffs.m_buffs.length(); i++)
			{
				if (buffs.m_buffs[i].m_def.m_debuff)
					buffs.m_buffs[i].Clear();
			}
		}
		else
		{
			for (uint i = 0; i < buffs.m_buffs.length(); i++)
				buffs.m_buffs[i].Clear();
		}
		
		buffs.Update(0);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (intensity <= 0)
			return false;

		ActorBuffList@ buffs = null;
		if (m_targetSelf)
			@buffs = GetBuffList(owner.m_unit);
		else
			@buffs = GetBuffList(target);

		return buffs !is null;
	}
}