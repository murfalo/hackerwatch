class IgnoringRayProjectile : RayProjectile
{
	UnitPtr m_ignoreUnit;
	
	IgnoringRayProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}
	
	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true) override
	{
		if (m_ignoreUnit == unit)
			return true;
			
		return RayProjectile::HitUnit(unit, pos, normal, selfDmg, bounce, collide);
	}
}
