class MagicTile
{
	UnitPtr m_unit;

	bool m_activating;
	int m_activatingC;

	int m_activatingDelayC;

	UnitScene@ m_sceneActivate;
	SoundEvent@ m_sndActivate;

	UnitProducer@ m_projectile;

	Actor@ m_owner;
	uint m_weaponInfo;
	

	MagicTile(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		@m_sceneActivate = unit.GetUnitScene(GetParamString(unit, params, "activate-scene"));
		@m_sndActivate = Resources::GetSoundEvent(GetParamString(unit, params, "activate-snd", false));

		@m_projectile = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
		
		m_unit.SetUpdateDistanceLimit(1);
	}

	void Activate(Actor@ owner, Actor@ target, int delay, uint weapon)
	{
		m_weaponInfo = weapon;
		m_unit.SetUpdateDistanceLimit(0);
	
		if (m_activating)
			return;

		m_activatingDelayC = delay;

		m_activating = true;

		if (m_activatingDelayC == 0)
			ActivateNow();

		@m_owner = owner;
	}

	void ActivateNow()
	{
		m_unit.SetUnitScene(m_sceneActivate, true);
		m_activatingC = m_sceneActivate.Length();
		PlaySound3D(m_sndActivate, m_unit.GetPosition());
	}

	Actor@ ClosestPlayer()
	{
		vec3 myPos = m_unit.GetPosition();
		Actor@ closest = null;
		float closestDistance = 0;

		for (uint i = 0; i < g_players.length(); i++)
		{
			Actor@ a = g_players[i].actor;
			if (a is null)
				continue;

			float distance = distsq(a.m_unit.GetPosition(), myPos);
			if (closest is null || distance < closestDistance)
			{
				closestDistance = distance;
				@closest = a;
			}
		}

		return closest;
	}

	void Update(int dt)
	{
		if (m_activatingDelayC > 0)
		{
			m_activatingDelayC -= dt;
			if (m_activatingDelayC <= 0)
				ActivateNow();
			return;
		}

		if (m_activatingC > 0)
		{
			m_activatingC -= dt;
			if (m_activatingC <= 0)
			{
				if (m_projectile is null)
					return;

				Actor@ target = ClosestPlayer();

				vec2 shootDir;
				if (target !is null)
					shootDir = normalize(xy(target.m_unit.GetPosition() - m_unit.GetPosition()));
				else
					shootDir = randdir();

				UnitPtr proj = m_projectile.Produce(g_scene, m_unit.GetPosition());
				if (!proj.IsValid())
					return;

				IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
				if (p is null)
					return;

				p.Initialize(m_owner, shootDir, 1.0, false, target, m_weaponInfo);

				if (target !is null)
				{
					auto pp = cast<ProjectileBase>(proj.GetScriptBehavior());
					if (pp !is null && pp.m_seeking)
						pp.m_seekTarget = target.m_unit;
				}

				m_unit.Destroy();
			}
		}
	}
}
