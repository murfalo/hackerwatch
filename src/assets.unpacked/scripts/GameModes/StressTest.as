namespace GameMode
{
	[GameMode]
	class StressTest : Campaign
	{
		array<UnitProducer@> m_possibleUnits;
		array<Prefab@> m_possiblePrefabs;

		int m_testUnitSpawningInterval;
		int m_testUnitSpawningIntervalC;

		int m_testPrefabSpawningInterval;
		int m_testPrefabSpawningIntervalC;

		int m_testSoundPlayInterval;
		int m_testSoundPlayIntervalC;

		int m_testQueryInterval;
		int m_testQueryIntervalC;

		int m_testRaycastInterval;
		int m_testRaycastIntervalC;

		int m_testChangeLevelInterval;
		int m_testChangeLevelIntervalC;

		uint m_currentPrefabIndex;

		StressTest(Scene@ scene)
		{
			super(scene);

			m_testUnitSpawningInterval = 25;
			m_testPrefabSpawningInterval = 15;
			m_testSoundPlayInterval = 50;
			m_testQueryInterval = 5;
			m_testRaycastInterval = 5;
			m_testChangeLevelIntervalC = m_testChangeLevelInterval = 4000;

			for (int i = 0; i < int(StressTest::possibleUnits.length()); i++)
				m_possibleUnits.insertLast(Resources::GetUnitProducer(StressTest::possibleUnits[i]));

			for (int i = 0; i < int(StressTest::possiblePrefabs.length()); i++)
				m_possiblePrefabs.insertLast(Resources::GetPrefab(StressTest::possiblePrefabs[i]));
		}

		void Start(uint8 peer, SValue@ save, StartMode sMode) override
		{
			Campaign::Start(peer, save, sMode);
			SetLevelFlags(m_levelCount);
			Campaign::PostStart();
		}

		UnitProducer@ RandomUnitProducer()
		{
			int randomIndex = randi(m_possibleUnits.length());
			return m_possibleUnits[randomIndex];
		}

		Prefab@ RandomPrefab()
		{
			int randomIndex = randi(m_possiblePrefabs.length());
			if (m_currentPrefabIndex >= m_possiblePrefabs.length())
				m_currentPrefabIndex = 0;


			print("Spawning " + m_possiblePrefabs[m_currentPrefabIndex].GetDebugName() + " at index " + m_currentPrefabIndex);
			return m_possiblePrefabs[m_currentPrefabIndex++];
		}

		SoundEvent@ RandomSoundEvent()
		{
			int randomIndex = randi(StressTest::possibleSounds.length());
			return Resources::GetSoundEvent(StressTest::possibleSounds[randomIndex]);
		}

		vec2 RandomPosition(vec2 min = vec2(-250, -250), vec2 max = vec2(250, 250))
		{
			vec2 ret;
			ret.x = min.x + randf() * (max.x - min.x);
			ret.y = min.y + randf() * (max.y - min.y);
			return ret;
		}

		void UpdateFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
		{
			//UpdateChangeLevel(ms);

			Campaign::UpdateFrame(ms, gameInput, menuInput);

			//UpdateUnitSpawning(ms);
			UpdatePrefabSpawning(ms);
			// UpdateSoundEvent(ms);
			UpdateQuery(ms);
			// UpdateRaycast(ms);
		}

		void UpdateUnitSpawning(int ms)
		{
			m_testUnitSpawningIntervalC -= ms;
			while (m_testUnitSpawningIntervalC <= 0)
			{
				m_testUnitSpawningIntervalC += m_testUnitSpawningInterval;

				int range = randi(200) + 50;

				vec2 posMin = vec2(-range, -range);
				vec2 posMax = vec2(range, range);

				auto prod = RandomUnitProducer();
				if (prod is null)
					continue;

				vec2 pos = vec2();//RandomPosition(posMin, posMax);

				UnitPtr unit = prod.Produce(g_scene, xyz(pos));
				if (!unit.IsValid())
					continue;
			}
		}

		void UpdatePrefabSpawning(int ms)
		{
			m_testPrefabSpawningIntervalC -= ms;
			while (m_testPrefabSpawningIntervalC <= 0)
			{
				m_testPrefabSpawningIntervalC += m_testPrefabSpawningInterval;
				int range = randi(200) + 50;

				vec2 posMin = vec2(-range, -range);
				vec2 posMax = vec2(range, range);

				auto prefab = RandomPrefab();
				if (prefab is null)
					continue;

				vec2 pos = RandomPosition(posMin, posMax);
				prefab.Fabricate(g_scene, xyz(pos));
			}
		}

		void UpdateSoundEvent(int ms)
		{
			m_testSoundPlayIntervalC -= ms;
			while (m_testSoundPlayIntervalC <= 0)
			{
				m_testSoundPlayIntervalC += m_testSoundPlayInterval;
				auto sound = RandomSoundEvent();
				PlaySound2D(sound);
			}
		}

		void UpdateQuery(int ms)
		{
			m_testQueryIntervalC -= ms;
			while (m_testQueryIntervalC <= 0)
			{
				m_testQueryIntervalC += m_testQueryInterval;

				int range = randi(150);

				vec2 posMin = vec2(-range, -range);
				vec2 posMax = vec2(range, range);
				vec2 pos = RandomPosition(posMin, posMax);

				auto results = g_scene.QueryCircle(vec2(), 5000, ~0, RaycastType::Any, true);
				for (uint i = 0; i < results.length(); i++)
				{
					auto player = cast<Player>(results[i].GetScriptBehavior());
					if (player !is null)
						continue;

					results[i].Destroy();
				}
			}
		}

		void UpdateRaycast(int ms)
		{
			m_testRaycastIntervalC -= ms;
			while (m_testRaycastIntervalC <= 0)
			{
				m_testRaycastIntervalC += m_testRaycastInterval;

				int range = randi(150);

				vec2 posMin = vec2(-range, -range);
				vec2 posMax = vec2(range, range);
				vec2 pos = RandomPosition(posMin, posMax);
				vec2 dir = randdir();

				auto results = g_scene.Raycast(pos, pos + dir * 200, ~0, RaycastType::Any);
				for (uint i = 0; i < results.length(); i++)
				{
					UnitPtr unit = results[i].FetchUnit(g_scene);

					auto player = cast<Player>(unit.GetScriptBehavior());
					if (player !is null)
						continue;

					if (!unit.IsValid())
						continue;

					auto actor = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
					if (actor is null)
						continue;

					DamageInfo di(null, 5000, 5000, false, true, 0);
					actor.Damage(di, vec2(), vec2());
				}
			}
		}

		void UpdateChangeLevel(int ms)
		{
			m_testChangeLevelIntervalC -= ms;
			while (m_testChangeLevelIntervalC <= 0)
			{
				m_testChangeLevelIntervalC += m_testChangeLevelInterval;
				ChangeLevel(GetCurrentLevelFilename());
			}
		}
	}
}
