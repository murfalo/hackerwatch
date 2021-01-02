class ShootRandomEnemy : IEffect
{
	int m_range;
	UnitProducer@ m_prodProj;
	bool m_ignoreTarget;

	uint m_weaponInfo;

	ShootRandomEnemy(UnitPtr unit, SValue& params)
	{
		m_range = GetParamInt(unit, params, "range");
		m_ignoreTarget = GetParamBool(unit, params, "ignore-target", false, false);
		@m_prodProj = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		// Get all enemies near
		array<UnitPtr>@ enemies = g_scene.FetchActorsWithOtherTeam(owner.Team, pos, m_range);

		// Remove untargetable enemies
		for (int i = 0; i < int(enemies.length()); i++)
		{
			UnitPtr unit = enemies[i];
			
			if (m_ignoreTarget && unit == target)
			{
				enemies.removeAt(i--);
				continue;
			}
			
			auto actor = cast<Actor>(unit.GetScriptBehavior());
			if (actor is null || !actor.IsTargetable() || actor.IsDead())
			{
				enemies.removeAt(i--);
				continue;
			}

			bool canHit = true;

			vec2 enemyPos = xy(actor.m_unit.GetPosition());
			auto rayResults = g_scene.Raycast(pos, enemyPos, ~0, RaycastType::Shot);
			for (uint j = 0; j < rayResults.length(); j++)
			{
				RaycastResult res = rayResults[j];
				UnitPtr res_unit = res.FetchUnit(g_scene);

				if (res_unit.GetScriptBehavior() is null)
				{
					canHit = false;
					break;
				}

				if (res_unit == actor.m_unit)
					break;
			}

			if (!canHit)
			{
				enemies.removeAt(i--);
				continue;
			}
		}

		// Pick random enemy
		if (enemies.length() == 0)
			return false;

		UnitPtr enemy = enemies[randi(enemies.length())];

		// Create a projectile and shoot it at them
		auto proj = m_prodProj.Produce(g_scene, xyz(pos));
		if (!proj.IsValid())
			return false;

		IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
		if (p is null)
			return false;
			
		if (m_ignoreTarget)
		{
			auto igProj = cast<IgnoringRayProjectile>(p);
			if (igProj !is null)
				igProj.m_ignoreUnit = target;
		}

		vec2 shootDir = normalize(xy(enemy.GetPosition()) - pos);
		p.Initialize(owner, shootDir, intensity, husk, cast<Actor>(enemy.GetScriptBehavior()), m_weaponInfo);

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		if (m_prodProj is null)
			return false;

		if (!target.IsValid())
			return false;

		return true;
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}
}
