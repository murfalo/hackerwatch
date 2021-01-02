namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;256;0;32;32"]
	class DropPod : IOnDropped
	{
		vec3 Position;

		UnitProducer@ PodProd;
		string SceneName = "falling";

		int RandomDelayMin = 500;
		int RandomDelayMax = 1500;

		float Height = 1000.0;
		float InitialFallSpeed = 1.0;
		float MaxFallSpeed = 1.0;
		float FallSpeedMultiplier = 1.0;

		[Editable]
		UnitProducer@ SpawnType;

		[Editable validation=IsExecutable]
		UnitFeed TriggerOnStart;

		[Editable validation=IsExecutable]
		UnitFeed TriggerOnDropped;

		int m_droppingC;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		void Initialize()
		{
			@PodProd = Resources::GetUnitProducer("actors/spawners/spawner_pod.unit");

			if (SpawnType is null)
				@SpawnType = Resources::GetUnitProducer("actors/orc_blaster_aggro.unit");
		}

		UnitPtr ProduceUnit(vec3 pos)
		{
			auto prod = Resources::GetUnitProducer("system/drop_spawn.unit");
			if (prod is null)
				return UnitPtr();

			//TODO: Use PodProd's default scene if none is given?
			auto scene = PodProd.GetUnitScene(SceneName);
			if (scene is null)
			{
				PrintError("Scene '" + SceneName + "' is not found!");
				return UnitPtr();
			}

			UnitPtr u = prod.Produce(g_scene, pos);
			u.SetUnitScene(scene, true);
			auto dropper = cast<DropSpawnBehavior>(u.GetScriptBehavior());
			dropper.Initialize(this, PodProd, InitialFallSpeed, MaxFallSpeed, FallSpeedMultiplier, Height);
			
			return u;
		}

		SValue@ ServerExecute()
		{
			m_droppingC = RandomDelayMin + randi(RandomDelayMax - RandomDelayMin);

			SValueBuilder sval;
			sval.PushInteger(m_droppingC);
			return sval.Build();
		}

		void ClientExecute(SValue@ val)
		{
			m_droppingC = val.GetInteger();
		}

		void Update(int dt)
		{
			if (m_droppingC > 0)
			{
				m_droppingC -= dt;
				if (m_droppingC <= 0)
				{
					vec3 pos = Position;
					pos.z = Height;

					UnitPtr u = ProduceUnit(pos);

					array<UnitPtr>@ arrExec = TriggerOnStart.FetchAll();
					for (uint i = 0; i < arrExec.length(); i++)
						WorldScript::GetWorldScript(g_scene, arrExec[i].GetScriptBehavior()).Execute();
				}
			}
		}

		void OnDropped(DropSpawnBehavior@ dropSpawn, UnitPtr unit)
		{
			if (!Network::IsServer())
				return;

			SpawnType.Produce(g_scene, Position);

			array<UnitPtr>@ arrExec = TriggerOnDropped.FetchAll();
			for (uint i = 0; i < arrExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, arrExec[i].GetScriptBehavior()).Execute();
		}
	}
}
