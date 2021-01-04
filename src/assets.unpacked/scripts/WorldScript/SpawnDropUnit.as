namespace WorldScript
{
	[WorldScript color="170 232 238" icon="system/icons.png;256;0;32;32"]
	class SpawnDropUnit : IOnDropped
	{
		vec3 Position;

		[Editable]
		UnitProducer@ UnitType;

		[Editable]
		string SceneName;

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
		
		[Editable default=false]
		bool AggroEnemy;
		[Editable default=false]
		bool NoLootEnemy;
		[Editable default=false]
		bool NoExperienceEnemy;
		
		
		
		UnitSource LastSpawned;
		UnitSource AllSpawned;
		

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		UnitPtr ProduceUnit(int id, vec3 pos)
		{
			auto prod = Resources::GetUnitProducer("system/drop_spawn.unit");
			if (prod is null)
				return UnitPtr();

			auto prodUnit = UnitMap::Replace(UnitType);

			if (prodUnit is null)
			{
				auto script = WorldScript::GetWorldScript(g_scene, this);
				PrintError("Undefined UnitType in worldscript SpawnDropUnit with unit ID " + script.GetUnit().GetId());
				return UnitPtr();
			}

			//TODO: Use prodUnit's default scene if none is given?
			auto scene = prodUnit.GetUnitScene(SceneName);
			if (scene is null)
			{
				PrintError("Scene '" + SceneName + "' is not found!");
				return UnitPtr();
			}

			UnitPtr u = prod.Produce(g_scene, pos, id);
			u.SetUnitScene(scene, true);
			auto dropper = cast<DropSpawnBehavior>(u.GetScriptBehavior());
			dropper.Initialize(this, prodUnit, InitialFallSpeed, MaxFallSpeed, FallSpeedMultiplier, Height);
			
			return u;
		}

		SValue@ ServerExecute()
		{
			vec3 pos = Position;
			pos.z = Height;
		
			UnitPtr u = ProduceUnit(0, pos);

			SValueBuilder sval;
			sval.PushArray();
			sval.PushInteger(u.GetId());
			sval.PushVector3(u.GetPosition());
			sval.PopArray();
			return sval.Build();
		}

		void ClientExecute(SValue@ val)
		{
			auto arr = val.GetArray();
			ProduceUnit(arr[0].GetInteger(), arr[1].GetVector3());
		}
		
		void OnDropped(DropSpawnBehavior@ dropSpawn, UnitPtr unit)
		{
			if (AggroEnemy || NoLootEnemy || NoExperienceEnemy)
			{
				auto enemyBehavior = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
				if (enemyBehavior !is null)
					enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);
			}
			
			if (!Network::IsServer())
				return;
		
			if (unit.IsValid())
			{
				LastSpawned.Replace(unit);
				AllSpawned.Add(unit);
			}
		
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
