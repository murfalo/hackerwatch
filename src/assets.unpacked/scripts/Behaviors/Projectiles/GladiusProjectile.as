class GladiusProjectile : RayProjectile
{
	float m_speedMin;
	float m_speedMax;

	int m_penetrationMin;
	int m_penetrationMax;

	float m_rangeMinSq;
	float m_rangeMaxSq;
	float m_ttlRange;
	
	int m_ttlMin;
    int m_ttlMax;

	float m_effectIntensityMin;
	float m_effectIntensityMax;

	vec3 m_startPos;
	
	array<IEffect@>@ m_destroyEffects;
	

	GladiusProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_speedMin = GetParamFloat(unit, params, "speed-min");
		m_speedMax = GetParamFloat(unit, params, "speed-max");

		m_penetrationMin = GetParamInt(unit, params, "penetration-min");
		m_penetrationMax = GetParamInt(unit, params, "penetration-max");

		m_rangeMinSq = GetParamFloat(unit, params, "range-min");
		m_rangeMinSq *= m_rangeMinSq;
		m_rangeMaxSq = GetParamFloat(unit, params, "range-max");
		m_rangeMaxSq *= m_rangeMaxSq;

		m_effectIntensityMin = GetParamFloat(unit, params, "effect-intensity-min");
		m_effectIntensityMax = GetParamFloat(unit, params, "effect-intensity-max");
		
		m_ttlMin = GetParamInt(unit, params, "ttl-min", false, m_ttl);
		m_ttlMax = GetParamInt(unit, params, "ttl-max", false, m_ttl);
		
		@m_destroyEffects = LoadEffects(unit, params, "destroy-");
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		m_startPos = m_unit.GetPosition();

		m_speed = lerp(m_speedMin, m_speedMax, intensity);
		m_penetration = lerp(m_penetrationMin, m_penetrationMax, intensity);
		m_ttlRange = lerp(m_rangeMinSq, m_rangeMaxSq, intensity);
		m_ttl = lerp(m_ttlMin, m_ttlMax, intensity);

		float effectIntensity = lerp(m_effectIntensityMin, m_effectIntensityMax, intensity);

		RayProjectile::Initialize(owner, dir, effectIntensity, husk, target, weapon);
	}

	void Destroyed() override
	{
		RayProjectile::Destroyed();
		ApplyEffects(m_destroyEffects, m_owner, m_unit, xy(m_unit.GetPosition()), GetDirection(), m_intensity, m_husk);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal) override
	{
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		if (fxSelf.GetIndex() == 0)
			HitUnit(unit, pos, normal, m_selfDmg, true);
		else
			HitUnit(unit, pos, normal, m_selfDmg, false, false);
	}

	void Update(int dt) override
	{
		RayProjectile::Update(dt);

		if (distsq(m_startPos, m_unit.GetPosition()) >= m_ttlRange)
			m_unit.Destroy();
	}
	
	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true) override
	{
		if (!unit.IsValid())
			return true;

		auto dt = cast<IDamageTaker>(unit.GetScriptBehavior());
		if (dt !is null && dt.Impenetrable())
		{
			m_unit.Destroy();
			return false;
		}
		
		return RayProjectile::HitUnit(unit, pos, normal, selfDmg, bounce, collide);
	}
}
