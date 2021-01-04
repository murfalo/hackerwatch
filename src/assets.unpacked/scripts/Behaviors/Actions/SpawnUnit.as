class SpawnUnitEntry
{
	int m_chance;
	UnitProducer@ m_prod;
}

class SpawnUnit : IAction, IEffect, SpawnUnitBase
{
	array<SpawnUnitEntry@> m_unitEntries;

	int m_spawnDist;
	bool m_safeSpawning;
	bool m_safeIgnoreOwner;
	bool m_safeIgnoreTarget;

	bool m_playersInSight;
	vec2 m_offset;
	bool m_rotateOffset;

	UnitPtr m_target;
	
	SpawnUnit(UnitPtr unit, SValue& params)
	{
		m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false);
		m_safeIgnoreOwner = GetParamBool(unit, params, "safe-ignore-owner", false);
		m_safeIgnoreTarget = GetParamBool(unit, params, "safe-ignore-target", false);

		m_playersInSight = GetParamBool(unit, params, "players-in-sight", false);
		m_spawnDist = GetParamInt(unit, params, "spawn-dist", false);
		m_offset = GetParamVec2(unit, params, "offset", false);
		if (m_offset.x != 0 || m_offset.y != 0)
			m_rotateOffset = GetParamBool(unit, params, "rotate-offset", false);
		
		array<SValue@>@ arr = GetParamArray(unit, params, "units", false);
		if (arr !is null)
		{
			for (uint i = 0; i < arr.length(); i += 2)
			{
				auto entry = SpawnUnitEntry();
				entry.m_chance = arr[i].GetInteger();
				@entry.m_prod = Resources::GetUnitProducer(arr[i+1].GetString());
				m_unitEntries.insertLast(entry);
			}
		}
		
		Initialize(unit, params);
	}
	
	bool NeedNetParams() { return false; }

	void SetWeaponInformation(uint weapon)
	{
		WeaponInfo = weapon;
	}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		DoSpawnUnits(owner, pos, dir, intensity);
		return true;
	}
	
	UnitPtr DoSpawnUnits(Actor@ owner, vec2 pos, vec2 dir, float intensity)
	{
		auto origPos = pos;
		pos += CalcJitter();
		dir *= m_spawnDist;
		
		if (m_rotateOffset)
			pos += addrot(m_offset, atan(dir.y, dir.x)) * length(m_offset);
		else
			pos += m_offset;

		if (m_playersInSight)
		{
			bool canSeePlayer = false;
			for (uint i = 0; i < g_players.length(); i++)
			{
				auto player = g_players[i];
				if (player.peer == 255 || player.IsDead())
					continue;

				vec2 playerPos = xy(player.actor.m_unit.GetPosition());
				auto res = g_scene.Raycast(pos, playerPos, ~0, RaycastType::Any);
				for (uint j = 0; j < res.length(); j++)
				{
					UnitPtr unit = res[j].FetchUnit(g_scene);

					if (unit == player.actor.m_unit)
					{
						canSeePlayer = true;
						break;
					}

					if (owner !is null && unit == owner.m_unit)
						continue;

					if (unit.GetScriptBehavior() is null)
						break;
				}

				if (canSeePlayer)
					break;
			}

			if (!canSeePlayer)
				return UnitPtr();
		}
		
		if (!m_safeSpawning)
			return DoSpawnUnit(pos + dir, dir, owner, intensity);
		else
		{
			UnitPtr ignoreUnit;

			if (m_safeIgnoreOwner && owner !is null)
				ignoreUnit = owner.m_unit;

			if (m_spawnDist == 0 && lengthsq(m_offset) <= 1)
			{
				bool canSpawn = true;
				
				if (distsq(origPos, pos) > 1.0f && g_scene.RaycastQuickWithoutUnit(origPos, pos, ~0, RaycastType::Any, ignoreUnit))
					canSpawn = false;
				
				if (canSpawn)
				{
					auto res = g_scene.QueryRect(pos, 1, 1, ~0, RaycastType::Any);
					for (uint i = 0; i < res.length(); i++)
					{
						UnitPtr r = res[i];
						if (r != owner.m_unit && (!m_safeIgnoreTarget || (m_target.IsValid() && r != m_target)))
						{
							canSpawn = false;
							break;
						}
					}
				}
				
				if (canSpawn)
					return DoSpawnUnit(pos, dir, owner, intensity);
			}
			else
			{
				if (!g_scene.RaycastQuick(origPos, pos + dir, ~0, RaycastType::Any))
					return DoSpawnUnit(pos + dir, dir, owner, intensity);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x, pos.y - m_spawnDist), ~0, RaycastType::Any))
					return DoSpawnUnit(vec2(pos.x, pos.y - m_spawnDist), dir, owner, intensity);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x, pos.y + m_spawnDist), ~0, RaycastType::Any))
					return DoSpawnUnit(vec2(pos.x, pos.y + m_spawnDist), dir, owner, intensity);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x - m_spawnDist, pos.y), ~0, RaycastType::Any))
					return DoSpawnUnit(vec2(pos.x - m_spawnDist, pos.y), dir, owner, intensity);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x + m_spawnDist, pos.y), ~0, RaycastType::Any))
					return DoSpawnUnit(vec2(pos.x + m_spawnDist, pos.y), dir, owner, intensity);
			}
		}
		
		return UnitPtr();
	}

	UnitPtr DoSpawnUnit(vec2 pos, vec2 dir, Actor@ owner, float intensity)
	{
		auto prevUnitType = UnitType;
		int n = randi(1000);
		for (uint i = 0; i < m_unitEntries.length(); i++)
		{
			auto entry = m_unitEntries[i];
			n -= entry.m_chance;
			if (n < 0)
			{
				@UnitType = entry.m_prod;
				break;
			}
		}
		
		UnitPtr unit = SpawnUnit(pos, owner, intensity);
		@UnitType = prevUnitType;
		
		return unit;
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		return true;
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		m_target = target;
		if (!husk)
			DoSpawnUnits(owner, pos, dir, intensity);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
	
	void Update(int dt, int cooldown)
	{
	}
}