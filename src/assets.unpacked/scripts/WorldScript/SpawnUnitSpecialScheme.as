enum SpecialSchemeUnitType
{
	MeleeRandom = 1,
	RangedRandom,
	CasterRandom,
	Melee,
	Ranged,
	Caster,
	MeleeElite,
	RangedElite,
	CasterElite,
	MeleeMiniboss,
	RangedMiniboss,
	CasterMiniboss
}

namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;256;0;32;32"]
	class SpawnUnitSpecialScheme
	{
		vec3 Position;
	
		[Editable default="tweak/dungeons/mt_enemy_scheme.sval"]
		SValue@ UnitScheme;
		
		[Editable type=enum default=1]
		SpecialSchemeUnitType Type;
		
		[Editable]
		UnitScene@ SpawnEffect;

		[Editable]
		int EffectLayer;

		[Editable]
		SoundEvent@ SpawnSound;
		
		[Editable]
		float JitterX;
		[Editable]
		float JitterY;
		
		[Editable default=false]
		bool AggroEnemy;
		[Editable default=false]
		bool NoLootEnemy;
		[Editable default=false]
		bool NoExperienceEnemy;

		
		UnitSource LastSpawned;
		UnitSource AllSpawned;
		

		void ProduceUnitEffects(vec3 pos)
		{
			if (SpawnEffect !is null)
			{
				UnitPtr effectUnit = PlayEffect(SpawnEffect, xy(pos));
				if (effectUnit.IsValid())
				{
					if (EffectLayer != 0)
						effectUnit.SetLayer(EffectLayer);
				}
			}
			if (SpawnSound !is null)
				PlaySound3D(SpawnSound, pos);
		}

		vec2 CalcJitter()
		{
			return vec2((randf() * 2.0 - 1.0) * JitterX, (randf() * 2.0 - 1.0) * JitterY);
		}
		
		void CalcRandom(bool &out elite, bool &out miniboss)
		{
			bool canHaveMiniboss = Fountain::HasEffect("minibosses_everywhere");
			if (!canHaveMiniboss)
			{
				auto gm = cast<Campaign>(g_gameMode);
				if (gm !is null)
				{
					ivec3 level = CalcLevel(gm.m_levelCount);
					canHaveMiniboss = level.y >= 1;
				}
			}
			
			if (canHaveMiniboss)
				miniboss = randf() < 0.05;
			else
				miniboss = false;
		
			if (Fountain::HasEffect("more_elites"))
				elite = randf() < 0.25;
			else
				elite = randf() < 0.125;
		}

		EnemyList@ GetUnitList(SValue@ data, bool &out nonRare)
		{
			string type = "";
			bool elite = false;
			bool miniboss = false;
			nonRare = false;
		
			switch (Type)
			{
			case SpecialSchemeUnitType::Melee:
				type = "melee";
				break;
			case SpecialSchemeUnitType::Ranged:
				type = "ranged";
				break;
			case SpecialSchemeUnitType::Caster:
				type = "caster";
				break;

			case SpecialSchemeUnitType::MeleeElite:
				type = "melee";
				elite = true;
				break;
			case SpecialSchemeUnitType::RangedElite:
				type = "ranged";
				elite = true;
				break;
			case SpecialSchemeUnitType::CasterElite:
				type = "caster";
				elite = true;
				break;

			case SpecialSchemeUnitType::MeleeMiniboss:
				type = "melee";
				miniboss = true;
				break;
			case SpecialSchemeUnitType::RangedMiniboss:
				type = "ranged";
				miniboss = true;
				break;
			case SpecialSchemeUnitType::CasterMiniboss:
				type = "caster";
				miniboss = true;
				break;

			case SpecialSchemeUnitType::MeleeRandom:
				type = "melee";
				CalcRandom(elite, miniboss);
				break;
			case SpecialSchemeUnitType::RangedRandom:
				type = "ranged";
				CalcRandom(elite, miniboss);
				break;
			case SpecialSchemeUnitType::CasterRandom:
				type = "caster";
				CalcRandom(elite, miniboss);
				break;
			}
			
			auto unitCampType = GetParamString(UnitPtr(), data, type, false);
			
			EnemySetting@ setting = null;
			g_enemyGroupTypes.get(unitCampType, @setting);
			
			if (setting is null)
				return null;
	
			if (miniboss)
			{
				if (!setting.m_minibosses.IsEmpty())
					return setting.m_minibosses;
				else
					elite = true;
			}
	
			if (elite)
			{
				if (!setting.m_elites.IsEmpty())
					return setting.m_elites;
			}
			
			nonRare = true;
			return setting.m_enemies;
		}
		
		UnitPtr ProduceUnit(int id, UnitPtr &out extraUnit)
		{
			array<SValue@>@ scheme = UnitScheme.GetArray();
			auto units = scheme[min(GetAct(), scheme.length())];
			
			bool nonRare;
			auto list = GetUnitList(units, nonRare);
			if (list is null || list.IsEmpty())
				return UnitPtr();
			
			UnitProducer@ unitType = list.GetUnit();
			if (!IsNetsyncedExistance(unitType.GetNetSyncMode()))
				return UnitPtr();
			
			
			vec3 pos = Position + xyz(CalcJitter());
			auto u = unitType.Produce(g_scene, pos, id);
			UnitPtr extraU;
			
			if (nonRare && Fountain::HasEffect("more_enemies") && randf() < 0.33f)
				extraU = unitType.Produce(g_scene, pos, id);
			
			if (AggroEnemy || NoLootEnemy || NoExperienceEnemy)
			{
				auto enemyBehavior = cast<CompositeActorBehavior>(u.GetScriptBehavior());
				if (enemyBehavior !is null)
					enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);
					
				if (extraU.IsValid())
				{
					@enemyBehavior = cast<CompositeActorBehavior>(extraU.GetScriptBehavior());
					if (enemyBehavior !is null)
						enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);				
				}
			}

			extraUnit = extraU;
			ProduceUnitEffects(pos);
			return u;
		}		
		
		SValue@ ServerExecute()
		{
			UnitPtr extraU;
			auto u = ProduceUnit(0, extraU);
			if (!u.IsValid())
				return null;

			LastSpawned.Replace(u);
			AllSpawned.Add(u);
			
			SValueBuilder sval;
			
			if (extraU.IsValid())
			{
				sval.PushArray();
				sval.PushInteger(u.GetId());
				sval.PushInteger(extraU.GetId());
			
				AllSpawned.Add(extraU);
			}
			else
				sval.PushInteger(u.GetId());
				
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			if (val is null)
				return;
			
			UnitPtr u;
			UnitPtr extraU;
			
			if (val.GetType() == SValueType::Array)
			{
				auto arr = val.GetArray();

				u = g_scene.GetUnit(arr[0].GetInteger());
				extraU = g_scene.GetUnit(arr[1].GetInteger());
			}
			else
				u = g_scene.GetUnit(val.GetInteger());
			
			if (AggroEnemy || NoLootEnemy || NoExperienceEnemy)
			{
				auto enemyBehavior = cast<CompositeActorBehavior>(u.GetScriptBehavior());
				if (enemyBehavior !is null)
					enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);
					
				if (extraU.IsValid())
				{
					@enemyBehavior = cast<CompositeActorBehavior>(extraU.GetScriptBehavior());
					if (enemyBehavior !is null)
						enemyBehavior.Configure(AggroEnemy, NoLootEnemy, NoExperienceEnemy);				
				}
			}

			ProduceUnitEffects(u.GetPosition());
		}
	}
}
