namespace Skills
{
	class StaggeredSpawnUnits : ActiveSkill
	{
		UnitProducer@ m_unitProd;
		array<vec2> m_positions;
	
		int m_duration;
		int m_durationC;

		bool m_safeSpawning;
		bool m_spawningHusk;
		bool m_needNetSync;

		string m_spawnFx;

		StaggeredSpawnUnits(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			m_duration = GetParamInt(unit, params, "duration");
			@m_unitProd = Resources::GetUnitProducer(GetParamString(unit, params, "unit", false));
			m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false);
			
			array<SValue@>@ arr = GetParamArray(unit, params, "positions", false);
			for (int i = arr.length() -1; i >= 0; i--)
				m_positions.insertLast(arr[i].GetVector2());

			m_spawnFx = GetParamString(unit, params, "spawn-fx", false);

			m_needNetSync = !IsNetsyncedExistance(m_unitProd.GetNetSyncMode());
		}
		
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			StartSpawning(false);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			StartSpawning(true);
		}

		void StartSpawning(bool husk)
		{
			if (m_durationC > 0)
				return;

			m_spawningHusk = husk;
			m_durationC = m_duration;
			m_animCountdown = m_duration - m_castpoint;
			PlaySkillEffect(vec2(1,0));
		}
		
		float GetMoveSpeedMul() override { return m_durationC <= 0 ? 1.0 : m_speedMul; }

		void DoUpdate(int dt) override
		{
			if (m_durationC <= 0)
				return;
			
			int i1 = min(int(m_durationC * m_positions.length()) / m_duration, int(m_positions.length()) -1);
			m_durationC -= dt;
			int i2 = min(int(m_durationC * m_positions.length()) / m_duration, int(m_positions.length()) -1);
			
			if ((i1 != i2 || m_durationC <= 0) && (m_needNetSync || Network::IsServer()))
			{
				vec2 pos = xy(m_owner.m_unit.GetPosition());
				vec2 posHit = pos + m_positions[m_durationC <= 0 ? 0 : i1];
				
				if (m_safeSpawning)
				{
					auto ray = g_scene.Raycast(pos, posHit, ~0, RaycastType::Any);
					for (uint i = 0; i < ray.length(); i++)
					{
						UnitPtr unit = ray[i].FetchUnit(g_scene);
						if (!unit.IsValid())
							continue;

						if (cast<PlayerBase>(unit.GetScriptBehavior()) is null)
						{
							posHit = ray[i].point;
							break;
						}
					}
				}
				
				LocalSpawnUnit(posHit, m_owner, 1.0f, m_spawningHusk);
			}
		}

		UnitPtr LocalSpawnUnit(vec2 pos, Actor@ owner, float intensity, bool husk, int id = 0)
		{
			auto unit = m_unitProd.Produce(g_scene, xyz(pos), id);

			PlayEffect(m_spawnFx, pos);

			if (!m_needNetSync)
				(Network::Message("PlayEffect") << HashString(m_spawnFx) << pos).SendToAll();

			if (owner !is null)
			{
				auto ownedUnit = cast<IOwnedUnit>(unit.GetScriptBehavior());
				if (ownedUnit !is null)
				{
					ownedUnit.Initialize(owner, intensity, husk, m_skillId + 1);

					if (!m_needNetSync && Network::IsServer())
						(Network::Message("SetOwnedUnit") << unit << owner.m_unit << intensity).SendToAll();
				}
			}

			return unit;
		}
	}
}