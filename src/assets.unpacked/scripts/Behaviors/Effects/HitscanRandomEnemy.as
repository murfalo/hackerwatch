class HitscanRandomEnemy : IEffect
{
	int m_range;
	HitscanShooter@ m_shooter;
	float m_teamDmg;

	int m_penetrating;

	int m_ricochet;
	float m_ricochetMul;

	uint m_weaponInfo;

	HitscanRandomEnemy(UnitPtr unit, SValue& params)
	{
		m_range = GetParamInt(unit, params, "range");

		auto hitEffects = LoadEffects(unit, params);
		auto missEffects = LoadEffects(unit, params, "miss-");
		auto shootFx = GetParamString(unit, params, "shoot-fx", false);
		auto hitFx = GetParamString(unit, params, "hit-fx", false);
		auto playMissFx = GetParamBool(unit, params, "miss-fx", false);

		m_penetrating = GetParamInt(unit, params, "penetrating", false);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false);

		m_ricochet = GetParamInt(unit, params, "ricochet", false);
		m_ricochetMul = GetParamFloat(unit, params, "ricochet-mul", false, 1.0f);

		@m_shooter = HitscanShooter(hitEffects, missEffects, hitFx, shootFx, playMissFx);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		// Get all enemies near
		array<UnitPtr>@ enemies = g_scene.FetchActorsWithOtherTeam(owner.Team, pos, m_range);

		// Remove untargetable enemies
		for (int i = 0; i < int(enemies.length()); i++)
		{
			auto actor = cast<Actor>(enemies[i].GetScriptBehavior());
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

		// Shoot hitscan
		vec2 shootPos = xy(enemy.GetPosition());
		m_shooter.ShootHitscan(owner, pos, shootPos, m_penetrating, intensity, m_teamDmg, husk, m_ricochet, m_ricochetMul);

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		if (!target.IsValid())
			return false;

		return true;
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;

		PropagateWeaponInformation(m_shooter.m_hitEffects, weapon);
		PropagateWeaponInformation(m_shooter.m_missEffects, weapon);
	}
}
