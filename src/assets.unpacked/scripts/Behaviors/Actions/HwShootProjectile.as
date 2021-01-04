class HwShootProjectile : ShootProjectile
{
	bool m_makeSeeking;
	float m_seekTurnSpeed;

	HwShootProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_makeSeeking = GetParamBool(unit, params, "seeking", false, false);
		if (m_makeSeeking)
			m_seekTurnSpeed = GetParamFloat(unit, params, "seek-turnspeed", false, 0.07);
	}

	UnitPtr ProduceProjectile(vec2 shootPos, int id = 0) override
	{
		auto proj = m_projectile.Produce(g_scene, xyz(shootPos), id);
		if (m_makeSeeking)
		{
			auto p = cast<ProjectileBase>(proj.GetScriptBehavior());
			if (p !is null)
			{
				p.m_seeking = true;
				p.m_seekTurnSpeed = m_seekTurnSpeed;
			}
		}
		
		return proj;
	}
}
