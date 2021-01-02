namespace UnitHandler
{
	void NetSendUnitDamaged(UnitPtr unit, int dmg, vec2 pos, vec2 dir, Actor@ attacker)
	{
		if (!unit.IsValid())
			return;
			
		auto localPlayer = cast<Player>(attacker);
		if (localPlayer is null)
			(Network::Message("UnitDamaged") << unit << dmg << pos << dir).SendToAll();
		else
			(Network::Message("UnitDamagedBySelf") << unit << dmg << pos << dir).SendToAll();
	}

	void NetSendUnitUseSkill(UnitPtr unit, int skillId, int stage = 0, SValue@ param = null)
	{
		if (stage == 0)
		{
			if (param !is null)
				(Network::Message("UnitUseSkillParam") << unit << skillId << xy(unit.GetPosition()) << param).SendToAll();
			else
				(Network::Message("UnitUseSkill") << unit << skillId << xy(unit.GetPosition())).SendToAll();
		}
		else	
		{
			if (param !is null)
				(Network::Message("UnitUseSSkillParam") << unit << skillId << stage << xy(unit.GetPosition()) << param).SendToAll();
			else
				(Network::Message("UnitUseSSkill") << unit << skillId << stage << xy(unit.GetPosition())).SendToAll();
		}	
	}
	
	Actor@ GetActor(int unitId)
	{
		if (unitId <= 0)
			return null;
	
		UnitPtr unit = g_scene.GetUnit(unitId);
		if (!unit.IsValid())
		{
			PrintError("Couldn't find unit " + unitId);
			return null;
		}
		
		if (unit.IsDestroyed())
			return null;
	
		ref@ behavior = unit.GetScriptBehavior();
		if (behavior is null)
		{
			PrintError("Unit " + unitId + " (" + unit.GetDebugName() + ") has no behavior");
			return null;
		}
		
		Actor@ actor = cast<Actor>(behavior);
		if (actor is null)
		{
			PrintError("Unit " + unitId + " (" + unit.GetDebugName() + ") is not an actor");
			return null;
		}
	
		return actor;
	}


	Actor@ GetActor(UnitPtr unit)
	{
		if (unit.IsDestroyed())
			return null;
	
		ref@ behavior = unit.GetScriptBehavior();
		if (behavior is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") has no behavior");
			return null;
		}
		
		Actor@ actor = cast<Actor>(behavior);
		if (actor is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not an actor");
			return null;
		}
	
		return actor;
	}

	IDamageTaker@ GetDamageTaker(UnitPtr unit)
	{
		if (unit.IsDestroyed())
			return null;
	
		ref@ behavior = unit.GetScriptBehavior();
		if (behavior is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") has no behavior");
			return null;
		}
		
		auto dmgTaker = cast<IDamageTaker>(behavior);
		if (dmgTaker is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not an IDamageTaker");
			return null;
		}
	
		return dmgTaker;
	}
	

	Pickup@ GetPickup(UnitPtr unit)
	{	
		ref@ behavior = unit.GetScriptBehavior();
		if (behavior is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") has no behavior");
			return null;
		}

		Pickup@ pickup = cast<Pickup>(behavior);
		if (pickup is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not a pickup");
			return null;
		}

		return pickup;
	}

	void UnitTeleported(UnitPtr unit, vec2 pos)
	{
		unit.SetPosition(xyz(pos));
	}

	void UnitDestroyed(UnitPtr unit)
	{
		unit.Destroy();
	}
	
	void UnitHealed(UnitPtr unit, int amount)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;

		actor.NetHeal(amount);
	}
	
	void UnitKilled(UnitPtr unit, UnitPtr attacker, int dmg, vec2 dir, uint weapon)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;
		
		if (attacker.IsValid())
		{
			Actor@ actorAttacker = GetActor(attacker);
			actor.NetKill(actorAttacker, dmg, dir, weapon);

			PlayerHusk@ playerAttacker = cast<PlayerHusk>(actorAttacker);
			if (playerAttacker !is null)
			{
				playerAttacker.m_record.kills++;
				playerAttacker.m_record.killsTotal++;
			}
		}
		else
			actor.NetKill(null, dmg, dir, weapon);
	}
		
	void UnitTarget(UnitPtr unit, UnitPtr target)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;
			
		if (target.IsValid())
		{
			Actor@ t = GetActor(target);
			//print("Target set to: " + t.m_unit.GetDebugName() + " (" + unit.GetId() + " -> " + target.GetId() + ")");
			actor.NetSetTarget(t);
		}
		else
		{
			actor.NetSetTarget(null);
			//print("Target set to: null (" + unit.GetId() + " -> 0)");
		}
	}
	
	void UnitUseSSkillParam(UnitPtr unit, int skillId, int stage, vec2 pos, SValue@ param)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;
			
		actor.NetUseSkill(skillId, stage, pos, param);
	}
	
	void UnitUseSSkill(UnitPtr unit, int skillId, int stage, vec2 pos)
	{
		UnitUseSSkillParam(unit, skillId, stage, pos, null);
	}
	
	void UnitUseSkillParam(UnitPtr unit, int skillId, vec2 pos, SValue@ param)
	{
		UnitUseSSkillParam(unit, skillId, 0, pos, param);
	}
	
	void UnitUseSkill(UnitPtr unit, int skillId, vec2 pos)
	{
		UnitUseSSkillParam(unit, skillId, 0, pos, null);
	}

	void SpawnUnit(int unitId, uint producerHash, vec2 pos)
	{
		UnitProducer@ prod = Resources::GetUnitProducer(producerHash);
		if (prod is null)
		{
			PrintError("Unknown unit producer '" + producerHash + "'");
			return;
		}

		prod.Produce(g_scene, xyz(pos), unitId);
	}


	void UnitDamaged(UnitPtr unit, int damage, vec2 pos, vec2 dir)
	{
		auto b = GetDamageTaker(unit);
		if (b is null)
			return;
			
		if (damage == 0)
			PrintError("Damage to unit " + unit.GetId() + " is 0 damage?");

		DamageInfo di;
		di.Damage = damage;
		b.NetDamage(di, pos, dir);
	}
	
	void UnitDecimated(UnitPtr unit, int health, int mana)
	{
		auto b = GetDamageTaker(unit);
		if (b is null)
			return;

		b.NetDecimate(health, mana);
	}
	
	void UnitDamagedBySelf(uint8 peer, UnitPtr unit, int damage, vec2 pos, vec2 dir)
	{
		auto b = GetDamageTaker(unit);
		if (b is null)
			return;
	
		if (damage == 0)
			PrintError("Damage to unit " + unit.GetId() + " is 0 damage?");

		DamageInfo di;
		@di.Attacker = PlayerHandler::GetPlayer(peer);
		di.Damage = damage;
		b.NetDamage(di, pos, dir);
	}

	void UnitDelayedBreakable(UnitPtr unit)
	{
		DelayedBreakable@ breakable = cast<DelayedBreakable>(unit.GetScriptBehavior());
		if (breakable is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type DelayedBreakable");
			return;
		}

		breakable.DamageEffects();
	}
	
	
	void UnitBuffed(UnitPtr unit, UnitPtr ownerUnit, uint buffHash, float intensity, uint weapon, int duration)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;

		Actor@ owner = null;
		if (ownerUnit.IsValid())
			@owner = GetActor(ownerUnit);
	
		auto aBuffDef = LoadActorBuff(buffHash);
		if (aBuffDef is null)
			return;
		
		auto newBuff = ActorBuff(owner, aBuffDef, intensity, true, weapon);
		newBuff.m_duration = duration;
		actor.ApplyBuff(newBuff);
	}

	void UnitPicked(UnitPtr unit, UnitPtr picker)
	{
		auto pickup = GetPickup(unit);
		if (pickup is null)
			return;

		pickup.NetPicked(picker);
	}
	
	void UnitPickSecure(UnitPtr unit, UnitPtr picker)
	{
		if (!Network::IsServer())
			return;

		auto pickup = GetPickup(unit);
		if (pickup is null)
			return;

		if (pickup.NetPicked(picker))
			(Network::Message("UnitPicked") << unit << picker).SendToAll();
	}
	
	void UnitPickCallback(UnitPtr unit, UnitPtr picker)
	{
		auto pickup = GetPickup(unit);
		if (pickup is null)
			return;

		pickup.CallbackPicked(picker);
	}

	void UnitMovementBossLichTarget(UnitPtr unit, UnitPtr targetUnit)
	{
		auto lich = cast<BossLich>(unit.GetScriptBehavior());
		if (lich is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossLich");
			return;
		}

		auto target = cast<WorldScript::BossLichNode>(targetUnit.GetScriptBehavior());
		if (target is null)
		{
			PrintError("Unit " + targetUnit.GetId() + " (" + targetUnit.GetDebugName() + ") is not of type BossLichNode");
			return;
		}

		auto movement = cast<BossLichMovement>(lich.m_movement);
		if (movement is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") does not have a movement of type BossLichMovement");
			return;
		}

		movement.SetTargetNode(target);
	}

	void UnitMovementBossVampireTarget(UnitPtr unit, UnitPtr targetUnit, int nodeWaitTime)
	{
		auto vampire = cast<BossVampire>(unit.GetScriptBehavior());
		if (vampire is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossVampire");
			return;
		}

		auto target = cast<WorldScript::BossLichNode>(targetUnit.GetScriptBehavior());
		if (target is null)
		{
			PrintError("Unit " + targetUnit.GetId() + " (" + targetUnit.GetDebugName() + ") is not of type BossLichNode");
			return;
		}

		auto movement = cast<BossVampireMovement>(vampire.m_movement);
		if (movement is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") does not have a movement of type BossVampireMovement");
			return;
		}

		movement.SetTargetNode(target, nodeWaitTime);
	}

	void UnitMovementBossWormSwitch(UnitPtr unit, bool underground)
	{
		auto boss = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type CompositeActorBehavior");
			return;
		}

		auto movement = cast<BossWormMovement>(boss.m_movement);
		if (movement is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") does not have a movement of type BossWormMovement");
			return;
		}

		movement.NetSwitch(underground);
	}

	void UnitMovementBossWormTarget(UnitPtr unit, vec2 targetPos, float dir)
	{
		auto boss = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type CompositeActorBehavior");
			return;
		}

		auto movement = cast<BossWormMovement>(boss.m_movement);
		if (movement is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") does not have a movement of type BossWormMovement");
			return;
		}

		movement.m_targetPos = targetPos;
		movement.m_dir = dir;
	}

	void UnitEyeBossWispsAdded(UnitPtr unit, SValue@ params)
	{
		auto boss = cast<BossEye>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossEye");
			return;
		}

		boss.NetAddWisps(params);
	}

	void UnitEyeBossWispsSync(UnitPtr unit, SValue@ params)
	{
		auto boss = cast<BossEye>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossEye");
			return;
		}

		boss.NetWispSync(params);
	}

	void VampireBossRoaming(UnitPtr unit)
	{
		auto boss = cast<BossVampire>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossVampire");
			return;
		}

		boss.m_roamingC = boss.m_roaming;
	}

	void VampireNodeArrived(UnitPtr unit)
	{
		auto boss = cast<BossVampire>(unit.GetScriptBehavior());
		if (boss is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BossVampire");
			return;
		}

		auto movement = cast<BossVampireMovement>(boss.m_movement);
		if (movement !is null)
			movement.NetOnNodeArrived();
	}
	
	void DjinnBlink(UnitPtr unit, vec2 pos)
	{
		Actor@ actor = GetActor(unit);
		if (actor is null)
			return;

		auto b = cast<CompositeActorBehavior>(actor);
		if (b is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type CompositeActorBehavior");
			return;
		}

		auto djinn = cast<DjinnMovement>(b.m_movement);
		if (djinn is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") does not have a movement of type DjinnMovement");
			return;
		}
		
		djinn.NetBlink(pos);
	}
	
	void UnitBombExploded(UnitPtr unit, SValue@ param)
	{
		auto bomb = cast<BombBehavior>(unit.GetScriptBehavior());
		if (bomb is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not of type BombBehavior");
			return;
		}

		bomb.NetDoExplode(param);
	}

	void SpawnLoot(SValue@ param)
	{
		LootDef::NetSpawnLoot(param);
	}

	void SetOwnedUnit(UnitPtr ownedUnit, UnitPtr ownerUnit, float intensity)
	{
		Actor@ owner = GetActor(ownerUnit);
		if (owner is null)
			return;

		auto owned = cast<IOwnedUnit>(ownedUnit.GetScriptBehavior());
		if (owned is null)
		{
			PrintError("Unit " + ownedUnit.GetId() + " (" + ownedUnit.GetDebugName() + ") is not of type IOwnedUnit");
			return;
		}

		owned.Initialize(owner, intensity, true, 0);
	}

	void PlayEffect(uint eHash, vec2 pos)
	{
		::PlayEffect(Resources::GetEffect(eHash), pos);
	}

	void AttachEffect(uint eHash, UnitPtr unit)
	{
		::PlayEffect(Resources::GetEffect(eHash), unit);
	}

	void BoltShooter(SValue@ params)
	{
		auto fx = Resources::GetEffect("effects/players/lightning_bolt.effect");
		if (fx is null)
		{
			PrintError("Lightning bolt effect does not exist!");
			return;
		}

		auto arr = params.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto arr2 = arr[i].GetArray();

			vec2 startPos = arr2[0].GetVector2();
			vec2 endPos = arr2[1].GetVector2();

			DrawLightningBolt(fx, startPos, endPos);
		}
	}

	void SurvivalEnemySpawn(int unitId, UnitPtr unitSpawn, UnitPtr unitSpawnPoint, int enemyCfg)
	{
		auto spawn = cast<WorldScript::SurvivalEnemySpawn>(unitSpawn.GetScriptBehavior());
		if (spawn is null)
			return;

		auto spawnPoint = cast<WorldScript::SurvivalEnemySpawnPoint>(unitSpawnPoint.GetScriptBehavior());
		if (spawnPoint is null)
			return;

		vec3 pos = spawnPoint.Position;

		UnitPtr u = spawn.ProduceUnit(pos, 0);

		auto enemy = cast<CompositeActorBehavior>(u.GetScriptBehavior());
		if (enemy !is null)
			SpawnUnitBaseHandler::ConfigureEnemy(enemy, enemyCfg);

		spawnPoint.SpawnEffects();

		if (!u.IsValid())
			return;

		spawn.AllSpawned.Add(u);
	}

	void SarcophagusUsed(UnitPtr unit)
	{
		auto script = cast<WorldScript::Sarcophagus>(unit.GetScriptBehavior());
		if (script is null)
		{
			PrintError("Unit \"" + unit.GetDebugName() + "\" is not a Sarcophagus!");
			return;
		}
		script.NetOnUse();
	}

	void ShowDialogResult(UnitPtr unit, string result)
	{
		auto script = cast<WorldScript::ShowDialog>(unit.GetScriptBehavior());
		if (script is null)
		{
			PrintError("Unit \"" + unit.GetDebugName() + "\" is not a ShowDialog!");
			return;
		}
		script.OnResult(result);
	}
}
