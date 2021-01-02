namespace Skills
{
	class SpawnUnit : ActiveSkill
	{
		UnitProducer@ m_unit;
		
		int m_spawnDist;
		bool m_safeSpawning;
		vec2 m_offset;
		bool m_needNetSync;
		

		SpawnUnit(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			
			@m_unit = Resources::GetUnitProducer(GetParamString(unit, params, "unit"));
			m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false);
			m_spawnDist = GetParamInt(unit, params, "spawn-dist", false);
			m_offset = GetParamVec2(unit, params, "offset", false);

			m_needNetSync = !IsNetsyncedExistance(m_unit.GetNetSyncMode());
		}
		
		
		bool NeedNetParams() override { return true; }
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			if (!m_needNetSync && !Network::IsServer())
			{
				builder.PushFloat(1.0);
				return;
			}
		
			DoSpawnUnits(builder, m_owner, xy(m_owner.m_unit.GetPosition()), target, 1.0, false);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			if (m_needNetSync)
			{
				array<SValue@>@ p = param.GetArray();
				LocalSpawnUnit(p[0].GetVector2(), m_owner, p[2].GetFloat(), true, p[1].GetInteger());
			}
			else if (Network::IsServer())
			{
				float intensity = param.GetFloat();
				DoSpawnUnits(null, m_owner, xy(m_owner.m_unit.GetPosition()), target, intensity, false);
			}
		}
		
		UnitPtr DoSpawnUnits(SValueBuilder@ builder, Actor@ owner, vec2 pos, vec2 dir, float intensity, bool husk)
		{
			dir *= m_spawnDist;
			
			if (!m_safeSpawning)
				return DoSpawnUnit(builder, pos + dir, owner, intensity, husk);
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
						return DoSpawnUnit(builder, pos, owner, intensity, husk);
					else
						builder.PushNull();
				}
				else
				{
					if (!g_scene.RaycastQuick(pos, pos + dir, ~0, RaycastType::Any))
						return DoSpawnUnit(builder, pos + dir, owner, intensity, husk);
					else if (!g_scene.RaycastQuick(pos, vec2(pos.x, pos.y - m_spawnDist), ~0, RaycastType::Any))
						return DoSpawnUnit(builder, vec2(pos.x, pos.y - m_spawnDist), owner, intensity, husk);
					else if (!g_scene.RaycastQuick(pos, vec2(pos.x, pos.y + m_spawnDist), ~0, RaycastType::Any))
						return DoSpawnUnit(builder, vec2(pos.x, pos.y + m_spawnDist), owner, intensity, husk);
					else if (!g_scene.RaycastQuick(pos, vec2(pos.x - m_spawnDist, pos.y), ~0, RaycastType::Any))
						return DoSpawnUnit(builder, vec2(pos.x - m_spawnDist, pos.y), owner, intensity, husk);
					else if (!g_scene.RaycastQuick(pos, vec2(pos.x + m_spawnDist, pos.y), ~0, RaycastType::Any))
						return DoSpawnUnit(builder, vec2(pos.x + m_spawnDist, pos.y), owner, intensity, husk);
					else
						builder.PushNull();
				}
			}
			
			return UnitPtr();
		}

		UnitPtr LocalSpawnUnit(vec2 pos, Actor@ owner, float intensity, bool husk, int id = 0)
		{
			auto unit = m_unit.Produce(g_scene, xyz(pos), id);
			
			if (owner !is null)
			{
				auto ownedUnit = cast<IOwnedUnit>(unit.GetScriptBehavior());
				if (ownedUnit !is null)
				{
					ownedUnit.Initialize(owner, intensity, husk);

					if (!m_needNetSync && Network::IsServer())
						(Network::Message("SetOwnedUnit") << unit << owner.m_unit << intensity).SendToAll();
				
					// TODO: Remove
					auto bomb = cast<BombBehavior>(ownedUnit);
					PropagateWeaponInformation(bomb.m_actions, m_skillId + 1);
				}
			}

			return unit;
		}
		
		UnitPtr DoSpawnUnit(SValueBuilder@ builder, vec2 pos, Actor@ owner, float intensity, bool husk)
		{
			pos += m_offset;
			UnitPtr unit = LocalSpawnUnit(pos, owner, intensity, husk);
			
			if (builder !is null)
			{
				if (m_needNetSync)
				{
					builder.PushArray();
					builder.PushVector2(pos);
					builder.PushInteger(unit.GetId());
					builder.PushFloat(intensity);
					builder.PopArray();
				}
				else 
					builder.PushNull();
			}
			
			return unit;
		}
	}
}