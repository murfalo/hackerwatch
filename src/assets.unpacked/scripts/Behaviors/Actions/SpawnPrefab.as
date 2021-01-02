class SpawnPrefab : IAction, IEffect, SpawnPrefabBase
{
	int m_spawnDist;
	bool m_safeSpawning;
	vec2 m_offset;
	bool m_rotateOffset;
	
	SpawnPrefab(UnitPtr unit, SValue& params)
	{
		m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false);
		m_spawnDist = GetParamInt(unit, params, "spawn-dist", false);
		m_offset = GetParamVec2(unit, params, "offset", false);
		if (m_offset.x != 0 || m_offset.y != 0)
			m_rotateOffset = GetParamBool(unit, params, "rotate-offset", false);
		
		Initialize(unit, params);
	}
	
	bool NeedNetParams() { return false; }
	void SetWeaponInformation(uint weapon) {}
	
	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		DoSpawnPrefabs(owner, pos, dir);
		return true;
	}
	
	void DoSpawnPrefabs(Actor@ owner, vec2 pos, vec2 dir)
	{
		auto origPos = pos;
		pos += CalcJitter();
		dir *= m_spawnDist;
		
		if (!m_safeSpawning)
			DoSpawnPrefab(pos + dir, dir);
		else
		{
			if (m_spawnDist == 0)
			{
				bool canSpawn = true;
				
				if (distsq(origPos, pos) > 1.0f && g_scene.RaycastQuick(origPos, pos, ~0, RaycastType::Any))
					canSpawn = false;
				
				if (canSpawn)
				{
					auto res = g_scene.QueryRect(pos, 1, 1, ~0, RaycastType::Any);
					for (uint i = 0; i < res.length(); i++)
					{
						if (owner.m_unit != res[i])
						{
							canSpawn = false;
							break;
						}
					}
				}
				
				if (canSpawn)
					DoSpawnPrefab(pos, dir);
			}
			else
			{
				if (!g_scene.RaycastQuick(origPos, pos + dir, ~0, RaycastType::Any))
					DoSpawnPrefab(pos + dir, dir);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x, pos.y - m_spawnDist), ~0, RaycastType::Any))
					DoSpawnPrefab(vec2(pos.x, pos.y - m_spawnDist), dir);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x, pos.y + m_spawnDist), ~0, RaycastType::Any))
					DoSpawnPrefab(vec2(pos.x, pos.y + m_spawnDist), dir);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x - m_spawnDist, pos.y), ~0, RaycastType::Any))
					DoSpawnPrefab(vec2(pos.x - m_spawnDist, pos.y), dir);
				else if (!g_scene.RaycastQuick(origPos, vec2(pos.x + m_spawnDist, pos.y), ~0, RaycastType::Any))
					DoSpawnPrefab(vec2(pos.x + m_spawnDist, pos.y), dir);
			}
		}
	}

	void DoSpawnPrefab(vec2 pos, vec2 dir)
	{
		if (m_rotateOffset)
			pos += addrot(m_offset, atan(dir.y, dir.x)) * length(m_offset);
		else
			pos += m_offset;

		SpawnPrefab(pos);
	}
	
	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		return true;
	}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!husk)
			DoSpawnPrefabs(owner, pos, dir);
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