class HwSpawnUnitEntry
{
	int m_chance;
	UnitProducer@ m_prod;
}

class HwSpawnUnit : IAction
{
	array<HwSpawnUnitEntry@> m_entries;
	int m_spawnDist;
	bool m_safeSpawning;
	bool m_aggro;

	HwSpawnUnit(UnitPtr unit, SValue& params)
	{
		array<SValue@>@ arr = GetParamArray(unit, params, "units", false);
		if (arr !is null)
		{
			for (uint i = 0; i < arr.length(); i += 2)
			{
				auto entry = HwSpawnUnitEntry();
				entry.m_chance = arr[i].GetInteger();
				@entry.m_prod = Resources::GetUnitProducer(arr[i+1].GetString());
				m_entries.insertLast(entry);
			}
		}

		m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false);
		m_spawnDist = GetParamInt(unit, params, "spawn-dist", false);
		m_aggro = GetParamBool(unit, params, "aggro", false, false);
	}

	bool NeedNetParams() { return true; }
	void SetWeaponInformation(uint weapon) {}

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		dir *= m_spawnDist;

		if (!m_safeSpawning)
			DoSpawnUnit(builder, pos + dir);
		else
		{
			if (m_spawnDist == 0)
			{
				bool canSpawn = true;
				auto res = g_scene.QueryRect(pos, 1, 1, ~0, RaycastType::Any);
				for (uint i = 0; i < res.length(); i++)
				{
					if (owner.m_unit != res[i])
					{
						canSpawn = false;
						break;
					}
				}

				if (canSpawn)
					DoSpawnUnit(builder, pos);
				else
					builder.PushNull();
			}
			else
			{
				if (!g_scene.RaycastQuick(pos, pos + dir, ~0, RaycastType::Any))
					DoSpawnUnit(builder, pos + dir);
				else if (!g_scene.RaycastQuick(pos, vec2(pos.x, pos.y - m_spawnDist), ~0, RaycastType::Any))
					DoSpawnUnit(builder, vec2(pos.x, pos.y - m_spawnDist));
				else if (!g_scene.RaycastQuick(pos, vec2(pos.x, pos.y + m_spawnDist), ~0, RaycastType::Any))
					DoSpawnUnit(builder, vec2(pos.x, pos.y + m_spawnDist));
				else if (!g_scene.RaycastQuick(pos, vec2(pos.x - m_spawnDist, pos.y), ~0, RaycastType::Any))
					DoSpawnUnit(builder, vec2(pos.x - m_spawnDist, pos.y));
				else if (!g_scene.RaycastQuick(pos, vec2(pos.x + m_spawnDist, pos.y), ~0, RaycastType::Any))
					DoSpawnUnit(builder, vec2(pos.x + m_spawnDist, pos.y));
				else
					builder.PushNull();
			}
		}

		return true;
	}

	int GetProducer()
	{
		int n = randi(1000);
		for (uint i = 0; i < m_entries.length(); i++)
		{
			auto entry = m_entries[i];
			n -= entry.m_chance;
			if (n < 0)
				return i;
		}
		return -1;
	}

	void DoSpawnUnit(SValueBuilder@ builder, vec2 pos)
	{
		int iProd = GetProducer();
		if (iProd < 0)
			return; // ???

		auto prod = m_entries[iProd].m_prod;
		UnitPtr unit = prod.Produce(g_scene, xyz(pos));

		bool needNetSync = !IsNetsyncedExistance(prod.GetNetSyncMode());

		if (m_aggro)
		{
			auto enemyBehavior = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
			if (enemyBehavior !is null)
				enemyBehavior.Configure(true, false, false);
		}

		if (needNetSync)
		{
			builder.PushArray();
			builder.PushInteger(iProd);
			builder.PushVector2(pos);
			builder.PushInteger(unit.GetId());
			builder.PopArray();
		}
		else
			builder.PushNull();
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		if (param.GetType() == SValueType::Array)
		{
			array<SValue@>@ p = param.GetArray();

			if (p is null)
				return false; // This means GetProducer() returned < 0 on the server

			int iProd = p[0].GetInteger();
			if (iProd < 0 || iProd >= int(m_entries.length()))
				return false;

			m_entries[iProd].m_prod.Produce(g_scene, xyz(p[1].GetVector2()), p[2].GetInteger());
		}

		return true;
	}


	void Update(int dt, int cooldown)
	{
	}
}