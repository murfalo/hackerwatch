namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;256;0;32;32"]
	class SpawnUnitWithEffect
	{
		vec3 Position;
	
		[Editable]
		UnitProducer@ UnitType;

		[Editable]
		string SceneName;

		[Editable]
		UnitScene@ SpawnEffect;

		[Editable]
		int SpawnLayer;

		[Editable validation=IsExecutable]
		UnitFeed EffectFinishTrigger;

		[Editable]
		int EffectLayer;

		[Editable]
		SoundEvent@ SpawnSound;
		
		[Editable default=false]
		bool AggroEnemy;
		[Editable default=false]
		bool NoLootEnemy;
		[Editable default=false]
		bool NoExperienceEnemy;
		
		
		UnitSource LastSpawned;
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
			auto prod = UnitMap::Replace(UnitType);
			m_needNetSync = !IsNetsyncedExistance(prod.GetNetSyncMode());
		}

		void ProduceUnitEffects(vec3 pos)
		{
			if (SpawnEffect !is null)
			{
				UnitPtr effectUnit = PlayEffect(SpawnEffect, xy(pos));
				if (effectUnit.IsValid())
				{
					if (EffectLayer != 0)
						effectUnit.SetLayer(EffectLayer);
					if (Network::IsServer())
					{
						auto fx = cast<EffectBehavior>(effectUnit.GetScriptBehavior());
						auto triggerArr = EffectFinishTrigger.FetchAll();
						for (uint i = 0; i < triggerArr.length(); i++)
						{
							auto callbackScript = WorldScript::GetWorldScript(g_scene, triggerArr[i].GetScriptBehavior());
							fx.m_finishTriggers.insertLast(callbackScript);
						}
					}
				}
			}
			if (SpawnSound !is null)
				PlaySound3D(SpawnSound, pos);
		}
		
		UnitPtr ProduceUnit(int id)
		{
			vec3 pos = Position;
			
			auto prod = UnitMap::Replace(UnitType);
			UnitPtr u = prod.Produce(g_scene, pos, id);
			if (SceneName != "")
				u.SetUnitScene(SceneName, true);
			if (SpawnLayer != 0)
				u.SetLayer(SpawnLayer);
				
			if (AggroEnemy || NoLootEnemy || NoExperienceEnemy)
			{
				auto enemyBehavior = cast<CompositeActorBehavior>(u.GetScriptBehavior());
				if (enemyBehavior !is null)
					enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);
			}

			ProduceUnitEffects(pos);

			return u;
		}		
		
		SValue@ ServerExecute()
		{
			UnitPtr u = ProduceUnit(0);
			
			LastSpawned.Replace(u);
			AllSpawned.Add(u);
			
			if (!m_needNetSync)
				return null;
				
			SValueBuilder sval;
			sval.PushInteger(u.GetId());
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			if (val is null)
				ProduceUnitEffects(Position);
			else
				ProduceUnit(val.GetInteger());
		}
	}
}
