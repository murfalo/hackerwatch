%if TOOLKIT
namespace Toolkits
{
	class SpawnedStressUnit
	{
		UnitPtr m_unit;
		int m_ttl;
	}

	[Toolkit]
	class StressTest : TestSceneTool
	{
		array<UnitProducer@> m_possibleUnits;
		array<Prefab@> m_possiblePrefabs;

		bool m_useUnitLimit = true;
		int m_unitLimit = 3000;

		bool m_printMutations = false;

		bool m_testUnitSpawning = false;
		int m_testUnitSpawningCount = 1;
		int m_testUnitSpawningInterval = 200;
		int m_testUnitSpawningIntervalC = 200;
		bool m_unitLifetime = true;
		int m_unitLifetimeMin = 1000;
		int m_unitLifetimeMax = 3000;

		bool m_testPrefabSpawning = false;
		int m_testPrefabSpawningInterval = 200;
		int m_testPrefabSpawningIntervalC = 200;

		array<SpawnedStressUnit@> m_spawned;

		StressTest(ToolkitScript@ script)
		{
			super(script);

			m_possibleUnits = Resources::GetUnitProducers(""".*\.unit""");
			for (int i = int(m_possibleUnits.length()) - 1; i >= 0; i--)
			{
				auto prod = m_possibleUnits[i];
				if (prod.GetUnitScenes().length() == 0)
					m_possibleUnits.removeAt(i);
			}

			m_possiblePrefabs = Resources::GetPrefabs(""".*\.pfb""");
		}

		void Save(SValueBuilder@ builder) override
		{
			TestSceneTool::Save(builder);

			builder.PushBoolean("rendering", m_rendering);
			builder.PushBoolean("print-mutations", m_printMutations);

			builder.PushDictionary("unit-spawning");
			builder.PushInteger("count", m_testUnitSpawningCount);
			builder.PushInteger("interval", m_testUnitSpawningInterval);
			builder.PushBoolean("lifetime", m_unitLifetime);
			builder.PushInteger("lifetime-min", m_unitLifetimeMin);
			builder.PushInteger("lifetime-max", m_unitLifetimeMax);
			builder.PopDictionary();
		}

		void Load(SValue@ data) override
		{
			TestSceneTool::Load(data);

			m_rendering = GetParamBool(UnitPtr(), data, "rendering", false, m_rendering);
			m_printMutations = GetParamBool(UnitPtr(), data, "print-mutations", false, m_printMutations);

			auto svUnitSpawning = data.GetDictionaryEntry("unit-spawning");
			if (svUnitSpawning !is null)
			{
				m_testUnitSpawningCount = GetParamInt(UnitPtr(), svUnitSpawning, "count", false, m_testUnitSpawningCount);
				m_testUnitSpawningInterval = GetParamInt(UnitPtr(), svUnitSpawning, "interval", false, m_testUnitSpawningInterval);
				m_unitLifetime = GetParamBool(UnitPtr(), svUnitSpawning, "lifetime", false, m_unitLifetime);
				m_unitLifetimeMin = GetParamInt(UnitPtr(), svUnitSpawning, "lifetime-min", false, m_unitLifetimeMin);
				m_unitLifetimeMax = GetParamInt(UnitPtr(), svUnitSpawning, "lifetime-max", false, m_unitLifetimeMax);
			}
		}

		UnitProducer@ RandomUnitProducer()
		{
			int randomIndex = randi(m_possibleUnits.length());
			return m_possibleUnits[randomIndex];
		}

		Prefab@ RandomPrefab()
		{
			int randomIndex = randi(m_possiblePrefabs.length());
			return m_possiblePrefabs[randomIndex];
		}

		vec2 RandomPosition(vec2 min = vec2(-250, -250), vec2 max = vec2(250, 250))
		{
			vec2 ret;
			ret.x = min.x + randf() * (max.x - min.x);
			ret.y = min.y + randf() * (max.y - min.y);
			return ret;
		}

		void Update(int dt) override
		{
			TestSceneTool::Update(dt);

			for (int i = int(m_spawned.length() - 1); i >= 0; i--)
			{
				auto spawnedUnit = m_spawned[i];
				if (spawnedUnit.m_ttl > 0)
				{
					spawnedUnit.m_ttl -= dt;
					if (spawnedUnit.m_ttl <= 0)
					{
						if (m_printMutations)
							print("Destroying unit: \"" + spawnedUnit.m_unit.GetDebugName() + "\"");
						spawnedUnit.m_unit.Destroy();
						m_spawned.removeAt(i);
					}
				}
			}

			if (m_testUnitSpawning)
				UpdateUnitSpawning(dt);

			if (m_testPrefabSpawning)
				UpdatePrefabSpawning(dt);
		}

		void UpdateUnitSpawning(int dt)
		{
			m_testUnitSpawningIntervalC -= dt;
			while (m_testUnitSpawningIntervalC <= 0)
			{
				m_testUnitSpawningIntervalC += m_testUnitSpawningInterval;

				for (int i = 0; i < m_testUnitSpawningCount; i++)
				{
					int range = max(250, int(m_spawned.length() * 2));

					vec2 posMin = vec2(-range, -range);
					vec2 posMax = vec2(range, range);

					auto prod = RandomUnitProducer();
					vec2 pos = RandomPosition(posMin, posMax);

					if (m_printMutations)
						print("Spawning unit: \"" + prod.GetDebugName() + "\"");

					if (m_useUnitLimit && m_spawned.length() + 1 > uint(m_unitLimit))
					{
						m_spawned[0].m_unit.Destroy();
						m_spawned.removeAt(0);
					}

					UnitPtr unit = prod.Produce(m_scene, xyz(pos));
					if (!unit.IsValid())
						continue;

					int lifetime = 0;
					if (m_unitLifetime)
						lifetime = m_unitLifetimeMin + randi(m_unitLifetimeMax - m_unitLifetimeMin);

					auto newSpawnedUnit = SpawnedStressUnit();
					newSpawnedUnit.m_unit = unit;
					newSpawnedUnit.m_ttl = lifetime;
					m_spawned.insertLast(newSpawnedUnit);
				}
			}
		}

		void UpdatePrefabSpawning(int dt)
		{
			m_testPrefabSpawningIntervalC -= dt;
			while (m_testPrefabSpawningIntervalC <= 0)
			{
				m_testPrefabSpawningIntervalC += m_testPrefabSpawningInterval;

				auto prefab = RandomPrefab();
				vec2 pos = RandomPosition();

				prefab.Fabricate(m_scene, xyz(pos));
			}
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			TestSceneTool::Render(sb, idt);

			if (UI::Begin("Stress Test"))
			{
				UI::LabelText("Spawned units", "" + m_spawned.length());

				m_useUnitLimit = UI::Checkbox("Use unit limit", m_useUnitLimit);
				m_unitLimit = UI::InputInt("Unit limit", m_unitLimit);
				if (m_unitLimit <= 0)
					m_unitLimit = 1;

				UI::Separator();

				m_rendering = UI::Checkbox("Render scene", m_rendering);
				m_printMutations = UI::Checkbox("Print mutations", m_printMutations);

				UI::Separator();

				m_testUnitSpawning = UI::Checkbox("Unit spawning", m_testUnitSpawning);

				UI::PushID("UnitSpawning");

				m_testUnitSpawningCount = UI::InputInt("Count", m_testUnitSpawningCount);
				if (m_testUnitSpawningCount <= 0)
					m_testUnitSpawningCount = 1;
				m_testUnitSpawningInterval = UI::SliderInt("Interval", m_testUnitSpawningInterval, 1, 2000, "%d ms");

				m_unitLifetime = UI::Checkbox("Use lifetime", m_unitLifetime);
				m_unitLifetimeMin = UI::SliderInt("Lifetime min", m_unitLifetimeMin, 10, 10000);
				m_unitLifetimeMax = UI::SliderInt("Lifetime max", m_unitLifetimeMax, 10, 10000);

				if (m_unitLifetimeMin > m_unitLifetimeMax)
					m_unitLifetimeMin = m_unitLifetimeMax;
				if (m_unitLifetimeMax < m_unitLifetimeMin)
					m_unitLifetimeMax = m_unitLifetimeMin;

				UI::PopID();

				UI::Separator();

				m_testPrefabSpawning = UI::Checkbox("Prefab spawning", m_testPrefabSpawning);

				UI::PushID("PrefabSpawning");

				m_testPrefabSpawningInterval = UI::SliderInt("Interval", m_testPrefabSpawningInterval, 1, 2000, "%d ms");

				UI::PopID();
			}
			UI::End();
		}
	}
}
%endif
