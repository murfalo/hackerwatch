namespace WorldScript
{
	[WorldScript color="0 196 150" icon="system/icons.png;256;0;32;32"]
	class SurvivalEnemyDropSpawn : IOnDropped
	{
		[Editable]
		UnitProducer@ UnitType;

		[Editable]
		string DropSceneName;

		[Editable default=100.0]
		float Height;

		[Editable default=0.05]
		float InitialFallSpeed;

		[Editable default=0.4]
		float MaxFallSpeed;

		[Editable default=1.1]
		float FallSpeedMultiplier;

		[Editable validation=IsExecutable]
		UnitFeed DropTrigger;

		[Editable default=1]
		uint NumberToSpawnMin;

		[Editable default=1]
		uint NumberToSpawnMax;

		[Editable default=0]
		uint NumberPerPlayer;

		[Editable default=0]
		uint NumberPerPlayerMax;

		[Editable default=100000]
		uint MaxToSpawn;

		[Editable]
		string SpawnPointFilter;

		UnitSource AllSpawned;

		bool m_needNetSync;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		void Initialize()
		{
			m_needNetSync = UnitType !is null && !IsNetsyncedExistance(UnitType.GetNetSyncMode());
		}

		UnitPtr ProduceUnit(vec3 pos, int id)
		{
			auto prod = Resources::GetUnitProducer("system/drop_spawn.unit");
			if (prod is null)
				return UnitPtr();

			if (UnitType is null)
			{
				auto script = WorldScript::GetWorldScript(g_scene, this);
				PrintError("Undefined UnitType in worldscript SpawnDropUnit with unit ID " + script.GetUnit().GetId());
				return UnitPtr();
			}

			//TODO: Use UnitType's default scene if none is given?
			auto scene = UnitType.GetUnitScene(DropSceneName);
			if (scene is null)
			{
				PrintError("Scene '" + DropSceneName + "' is not found!");
				return UnitPtr();
			}

			UnitPtr u = prod.Produce(g_scene, pos, id);
			u.SetUnitScene(scene, true);
			auto dropper = cast<DropSpawnBehavior>(u.GetScriptBehavior());
			dropper.Initialize(this, UnitType, InitialFallSpeed, MaxFallSpeed, FallSpeedMultiplier, Height);

			return u;
		}

		void SpawnEffects(SurvivalEnemySpawnPoint@ spawn)
		{
			if (spawn.SpawnEffect !is null)
				PlayEffect(spawn.SpawnEffect, xy(spawn.Position));
			if (spawn.SpawnSound !is null)
				PlaySound3D(spawn.SpawnSound, spawn.Position);
		}

		SValue@ ServerExecute()
		{
			auto survivalMode = cast<Survival>(g_gameMode);
			if (survivalMode is null)
				return null;

			SValueBuilder sval;
			if (m_needNetSync)
				sval.PushArray();

			uint num = NumberToSpawnMin + randi(NumberToSpawnMax - NumberToSpawnMin + 1);
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255)
					continue;

				int perPlayer = NumberPerPlayer;
				if (NumberPerPlayerMax > NumberPerPlayer)
					perPlayer += randi(NumberPerPlayerMax - NumberPerPlayer + 1);

				num += perPlayer;
			}

			num = min(num, MaxToSpawn);

			array<WorldScript::SurvivalEnemySpawnPoint@> spawns;
			for (uint i = 0; i < survivalMode.m_enemySpawns.length(); i++)
			{
				auto spawn = survivalMode.m_enemySpawns[i];
				if (spawn.Filter == SpawnPointFilter && spawn.Enabled)
					spawns.insertLast(spawn);
			}

			for (uint i = 0; i < num; i++)
			{
				auto spawn = spawns[randi(spawns.length())];
				auto spawnScript = WorldScript::GetWorldScript(g_scene, spawn);

				vec3 pos = spawn.Position;
				pos.z = Height;

				UnitPtr u = ProduceUnit(pos, 0);

				auto enemyCfg = SpawnUnitBaseHandler::PackEnemyCfg(spawn.AggroEnemy, spawn.NoLootEnemy, spawn.NoExperienceEnemy);

				auto dropSpawn = cast<DropSpawnBehavior>(u.GetScriptBehavior());
				if (dropSpawn !is null)
					dropSpawn.m_userData = enemyCfg;

				SpawnEffects(spawn);

				if (!u.IsValid())
					continue;

				//AllSpawned.Add(u);
				if (m_needNetSync)
				{
					sval.PushInteger(u.GetId());
					sval.PushVector3(u.GetPosition());
					sval.PushInteger(spawnScript.GetUnit().GetId());
					sval.PushInteger(enemyCfg);
				}
			}

			if (m_needNetSync)
				return sval.Build();

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			if (val is null)
				return;

			array<SValue@>@ arr = val.GetArray();
			for (uint i = 0; i < arr.length(); i += 4)
			{
				int id = arr[i].GetInteger();
				vec3 pos = arr[i + 1].GetVector3();
				auto spawn = cast<SurvivalEnemySpawnPoint>(g_scene.GetUnit(arr[i + 2].GetInteger()).GetScriptBehavior());
				auto enemyCfg = arr[i + 3].GetInteger();

				UnitPtr u = ProduceUnit(pos, id);

				auto dropSpawn = cast<DropSpawnBehavior>(u.GetScriptBehavior());
				if (dropSpawn !is null)
					dropSpawn.m_userData = enemyCfg;

				SpawnEffects(spawn);
			}
		}

		void OnDropped(DropSpawnBehavior@ dropSpawn, UnitPtr unit)
		{
			auto enemyBehavior = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
			if (enemyBehavior !is null)
				SpawnUnitBaseHandler::ConfigureEnemy(enemyBehavior, dropSpawn.m_userData);

			if (!Network::IsServer())
				return;

			if (unit.IsValid())
				AllSpawned.Add(unit);

			auto arr = DropTrigger.FetchAll();
			for (uint i = 0; i < arr.length(); i++)
			{
				auto script = WorldScript::GetWorldScript(arr[i]);
				if (script !is null)
					script.Execute();
			}
		}
	}
}
