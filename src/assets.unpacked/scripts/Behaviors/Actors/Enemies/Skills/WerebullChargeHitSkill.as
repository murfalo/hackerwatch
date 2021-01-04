class WerebullChargeHitSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;
	
	array<IEffect@>@ m_effects;
	array<ISkillConditional@>@ m_conditionals;
	
	
	WerebullChargeHitSkill(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
		@m_conditionals = LoadSkillConditionals(unit, params);
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
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
		return CheckConditionals(m_conditionals, m_behavior);
	}

	void OnCollide(UnitPtr unit, vec2 normal) 
	{
		if (!IsAvailable())
			return;

		if (!unit.IsValid())
			return;

		vec2 dir = m_unit.GetMoveDir();
		if (lengthsq(m_unit.GetMoveDir()) <= 0.01)
			return;

		if (dot(dir, normal) <= 0.0)
			return;
			
		auto b = cast<Actor>(unit.GetScriptBehavior());
		if (b !is null)
		{
			if (!b.IsTargetable())
				return;

			if (FilterAction(b, m_behavior, 0.0, 0.0, 1.0, 1.0) <= 0.0)
				return;
		}
		
		vec2 pos = xy(m_unit.GetPosition());
		ApplyEffects(m_effects, m_behavior, unit, pos, normal, m_behavior.m_buffs.DamageMul(), !Network::IsServer());
	}

	bool IsCasting()
	{
		return false;
	}
	
	void Update(int dt, bool isCasting) {}
	void OnDamaged() {}
	void OnDeath() {}
	void Destroyed() {}
	void NetUseSkill(int stage, SValue@ param) {}
	void CancelSkill() {}
}
