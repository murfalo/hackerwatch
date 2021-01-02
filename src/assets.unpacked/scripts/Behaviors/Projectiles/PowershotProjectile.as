class PowershotProjectile : RayProjectile
{
	float m_speedMin;
	float m_speedMax;

	int m_penetrationMin;
	int m_penetrationMax;

	float m_rangeMinSq;
	float m_rangeMaxSq;
	float m_ttlRange;

	float m_effectIntensityMin;
	float m_effectIntensityMax;

	vec3 m_startPos;

	PowershotProjectile(UnitPtr unit, SValue& params)
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
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		m_startPos = m_unit.GetPosition();

		m_speed = lerp(m_speedMin, m_speedMax, intensity);
		m_penetration = lerp(m_penetrationMin, m_penetrationMax, intensity);
		m_ttlRange = lerp(m_rangeMinSq, m_rangeMaxSq, intensity);

		float effectIntensity = lerp(m_effectIntensityMin, m_effectIntensityMax, intensity);

		RayProjectile::Initialize(owner, dir, effectIntensity, husk, target, weapon);
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
}
