class SpecificUnitSeekerProjectile : RayProjectile
{
	UnitProducer@ m_targetUnitType;
	int m_targetUnitRange;

	SpecificUnitSeekerProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		@m_targetUnitType = Resources::GetUnitProducer(GetParamString(unit, params, "target-unit-type", true));
		m_targetUnitRange = GetParamInt(unit, params, "target-unit-range", true, 100);
	}
	
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		RayProjectile::Initialize(owner, dir, intensity, husk, target, weapon);
		
		auto res = g_scene.FetchUnitsWithBehavior("Actor", xy(m_unit.GetPosition()), m_targetUnitRange, true);
		array<UnitPtr> targets;
		
		for (uint i = 0; i < res.length(); i++)
		{
			if (res[i].GetUnitProducer() is m_targetUnitType )
				targets.insertLast(res[i]);
		}
		
		if (targets.length() > 0)
			SetSeekTarget(cast<Actor>(targets[randi(targets.length())].GetScriptBehavior()));
	}
}
