class TowerFlowerSpike
{
	UnitPtr m_unit;
	Actor@ m_owner;

	int m_hurtDelay;
	int m_hurtDelayMax;
	int m_hurtDelayC;
	int m_radius;

	bool m_hurt;
	float m_intensity;

	string m_anim;
	int m_ttl;

	array<IEffect@>@ m_effects;

	TowerFlowerSpike(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_anim = GetParamString(unit, params, "anim");

		m_hurtDelay = GetParamInt(unit, params, "hurt-delay");
		m_hurtDelayMax = GetParamInt(unit, params, "hurt-delay-max");
		m_radius = GetParamInt(unit, params, "radius", false, 6);

		m_unit.SetUnitScene(m_anim, true);
		m_ttl = m_unit.GetCurrentUnitScene().Length();

		@m_effects = LoadEffects(unit, params);
		m_intensity = 1.0;
	}

	void Update(int dt)
	{
		m_hurtDelayC += dt;
		if (!m_hurt and m_hurtDelayC >= m_hurtDelay and m_hurtDelayC < m_hurtDelayMax)
		{
			array<UnitPtr>@ results = g_scene.QueryCircle(xy(m_unit.GetPosition()), m_radius, ~0, RaycastType::Any);
			for (uint i = 0; i < results.length(); i++)
			{
				UnitPtr unit = results[i];
				if (unit == m_unit)
					continue;

				Actor@ a = cast<Actor>(unit.GetScriptBehavior());
				if (a is null or m_owner is null or a.Team == m_owner.Team)
					continue;

				ApplyEffects(m_effects, m_owner, unit, xy(unit.GetPosition()), vec2(0, 0), m_intensity, !Network::IsServer());
				m_hurt = true;
			}
		}

		m_ttl -= dt;
		if (m_ttl <= 0)
			m_unit.Destroy();
	}
}
