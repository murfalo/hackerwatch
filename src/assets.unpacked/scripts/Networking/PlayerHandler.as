namespace PlayerHandler
{
	PlayerHusk@ GetPlayer(uint8 peer)
	{
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == peer)
			{
				if (g_players[i].actor is null)
					return null;
				
				if (g_players[i].local)
				{
					print("Player " + peer + " is not a husk on " + (Network::IsServer() ? "server" : "client"));
					return null;
				}
			
				return cast<PlayerHusk>(g_players[i].actor);
			}
		}
	
		return null;
	}
	
	PlayerRecord@ GetPlayerRecord(uint8 peer)
	{
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == peer)
				return g_players[i];
		}
	
		return null;
	}
	
	int GetPlayerIndex(uint8 peer)
	{
		for (uint i = 0; i < g_players.length(); i++)
			if (g_players[i].peer == peer)
				return i;
	
		return -1;
	}

	//NOTE: If first param is uint8, it will be peer id (always the host in this case)
	//      Not including an uint8 skips the peer id
	void SpawnPlayer(int plrId, vec2 pos, int unitId, int team)
	{
		int index = GetPlayerIndex(plrId);
	
		if (index == -1)
		{
			PrintError("Couldn't find player id " + plrId);
			return;
		}

		g_gameMode.SpawnPlayer(index, pos, unitId, team);
	}

	void KillPlayer(uint8 peer)
	{
		if (peer != 0)
		{
			PrintError("Non-host tried killing local player: " + peer);
			return;
		}

		auto player = GetLocalPlayer();
		if (player !is null)
			player.Kill(null, 0);
	}
	
	void SpawnPlayerCorpse(int plrId, vec2 pos)
	{
		int index = GetPlayerIndex(plrId);
	
		if (index == -1)
		{
			PrintError("Couldn't find player id " + plrId);
			return;
		}

		g_gameMode.SpawnPlayerCorpse(index, pos);
	}
	
		
	// TODO: Move to a gamemode network handler?
	void AttemptRespawn(uint8 peerId)
	{
		g_gameMode.AttemptRespawn(peerId);
	}
	
	void ResetPlayerHealthArmor(int plrId)
	{
		auto plr = GetPlayerRecord(plrId);
		if (plr !is null)
		{
			plr.hp = 1.0;
			plr.armor = 0;
		}
	}
	
	void PlayerMove(uint8 peer, vec2 pos, vec2 dir)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;
	
		plr.MovePlayer(pos, dir);
	}

	void PlayerMoveForce(uint8 peer, vec2 pos, vec2 dir)
	{
		PlayerMove(peer, pos, dir);
	}
	
	void PlayerDash(uint8 peer, int duration, vec2 dir)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.Dash(duration, dir);
	}

	void PlayerDashAbort(uint8 peer)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.m_dashTime = 0;
	}
	
	// Damage on local player
	void PlayerDamage(uint8 peer, int dmgType, int dmg)
	{
		Player@ player = GetLocalPlayer();
		if (player is null)
			return; // ???

		DamageInfo di;
		di.DamageType = uint8(dmgType);
		di.Damage = uint16(dmg);

		int iDamager = GetPlayerIndex(peer);
		if (iDamager != -1 && g_players[iDamager].actor !is null)
			@di.Attacker = g_players[iDamager].actor;

		player.NetDamage(di, xy(player.m_unit.GetPosition()), player.m_lastDirection);
	}

	// Other player reports that they were damaged
	void PlayerDamaged(uint8 peer, int dmgType, int damager, int dmg, float hp, uint weapon)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		DamageInfo di;
		di.DamageType = uint8(dmgType);
		di.Damage = int16(dmg);
		di.Weapon = weapon;
		@di.Attacker = UnitHandler::GetActor(damager);

		plr.NetDamage(di, xy(plr.m_unit.GetPosition()), plr.m_dir);
		plr.m_record.hp = hp;
		
		auto local = GetLocalPlayerRecord();
		if (local !is null && !local.IsDead() && local.actor !is null)
		{
			for (uint i = 0; i < local.soulLinks.length(); i++)
				if (uint(local.soulLinks[i]) == peer)
					cast<Player>(local.actor).SoulLinkDamage(dmg);
		}		
	}

	void PlayerHealed(uint8 peer, int amnt, float hp)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.NetHeal(amnt);
		plr.m_record.hp = hp;
	}
	
	void HealPlayer(uint8 peer, int amnt)
	{
		auto plr = GetLocalPlayer();
		if (plr is null)
			return;
			
		plr.Heal(amnt);
	}
	
	void PlayerSyncArmor(uint8 peer, uint armorDefHash, int armor)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.m_record.armor = armor;
			
		auto armorDef = LoadArmorDef(armorDefHash);
		if (armorDef !is null)
			@plr.m_record.armorDef = armorDef;
	}
	
	void PlayerSyncStats(uint8 peer, float hp, float mana)
	{
		auto plr = GetPlayerRecord(peer);
		if (plr is null)
			return;

		plr.hp = hp;
		plr.mana = mana;
	}

	void PlayerDied(uint8 peer, int killerPeer, int damageType, int damageAmount, bool damageMelee, uint weapon)
	{
		auto plr = GetPlayer(peer);
		if (plr is null)
			return;
		
		DamageInfo di;
		
		auto killer = GetPlayerRecord(killerPeer);
		if (killer !is null)
			@di.Attacker = killer.actor;

		di.DamageType = uint8(damageType);
		di.Damage = int16(damageAmount);
		di.Melee = damageMelee;
		di.Weapon = weapon;
		
		plr.Kill(di);
		cast<BaseGameMode>(g_gameMode).PlayerDied(plr.m_record, killer, di);
		
		auto local = GetLocalPlayerRecord();
		if (local !is null && !local.IsDead() && local.actor !is null)
		{
			for (uint i = 0; i < local.soulLinks.length(); i++)
				if (uint(local.soulLinks[i]) == peer)
					cast<Player>(local.actor).SoulLinkKill(plr);
		}
	}
	
	void PlayerShareExperience(int experience)
	{
		Player@ player = GetLocalPlayer();
		if (player !is null)
			player.NetShareExperience(experience);
	}
	
	void PlayerSyncExperience(uint8 peer, int level, int64 experience)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.m_record.NetSyncExperience(level, experience);
	}

	void PlayerPickups(uint8 peer, int num, int numTotal)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.m_record.pickups = num;
		plr.m_record.pickupsTotal = num;
	}

	void PlayerLevelUp(uint8 peer)
	{
		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		plr.OnLevelUp();
	}

	Modifiers::TriggerEffect@ GetTriggerEffectFromID(array<Modifiers::Modifier@>@ modifiers, uint id)
	{
		uint triggerId = id & 0xFF;

		if (triggerId > modifiers.length())
		{
			PrintError("Trigger ID " + triggerId + " is out of bounds! (Modifier count: " + modifiers.length() + ")");
			return null;
		}

		auto triggerMod = cast<Modifiers::TriggerEffect>(modifiers[triggerId]);
		if (triggerMod !is null)
			return triggerMod;

		for (int i = 3; i > 0; i--)
		{
			uint currentId = (id >> (8 * i)) & 0xFF;

			auto modFilter = cast<Modifiers::FilterModifier>(modifiers[currentId]);
			if (modFilter !is null)
				@modifiers = modFilter.m_modsTriggerEffects;
		}

		auto finalTriggerMod = cast<Modifiers::TriggerEffect>(modifiers[triggerId]);
		if (finalTriggerMod !is null)
			return finalTriggerMod;

		PrintError("Couldn't find trigger effect with ID " + id);
		return null;
	}

	void ModifierTriggerEffect(uint8 peer, int verbEnum, uint verbId, uint modIndex, UnitPtr target)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		Modifiers::TriggerEffect@ mod = null;

		auto verb = Modifiers::SyncVerb(verbEnum);
		if (verb == Modifiers::SyncVerb::Item)
		{
			auto item = g_items.GetItem(verbId);
			if (item is null)
			{
				PrintError("Couldn't find item with ID " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(item.modifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Set)
		{
			auto set = g_items.m_sets[verbId];
			auto ownedSet = player.m_record.GetOwnedItemSet(set);
			if (ownedSet is null)
			{
				PrintError("Player record " + peer + " does not own set with index " + verbId);
				return;
			}
			auto bonus = ownedSet.GetBestBonus();
			if (bonus is null)
			{
				PrintError("Player record " + peer + " does not have a best bonus with index " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(bonus.modifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Drink)
		{
			auto drink = GetTavernDrink(verbId);
			if (drink is null)
			{
				PrintError("Couldn't find drink with ID " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(drink.modifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Passive)
		{
			for (uint i = 0; i < player.m_skills.length(); i++)
			{
				auto skill = cast<Skills::PassiveSkill>(player.m_skills[i]);
				if (skill !is null && skill.m_skillId == verbId)
				{
					@mod = GetTriggerEffectFromID(skill.m_modifiers, modIndex);
					break;
				}
			}
		}
		else if (verb == Modifiers::SyncVerb::Wish)
		{
			auto effect = Fountain::GetEffect(verbId);
			if (effect is null)
			{
				PrintError("Couldn't find wish with ID " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(effect.m_modifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Buff)
		{
			auto buffDef = LoadActorBuff(verbId);
			if (buffDef is null)
			{
				PrintError("Couldn't find buff with ID " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(buffDef.m_modifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Statue)
		{
			auto statueDef = Statues::GetStatue(verbId);
			if (statueDef is null)
			{
				PrintError("Couldn't find statue with ID " + verbId);
				return;
			}
			@mod = GetTriggerEffectFromID(statueDef.m_builtModifiers, modIndex);
		}
		else if (verb == Modifiers::SyncVerb::Upgrade)
		{
			auto ownedUpgrade = player.m_record.GetOwnedUpgrade(verbId);
			if (ownedUpgrade is null)
			{
				PrintError("Couldn't find owned upgrade with ID " + verbId);
				return;
			}
			auto step = cast<Upgrades::ModifierUpgradeStep>(ownedUpgrade.m_step);
			if (step is null)
			{
				PrintError("Owned upgrade's step of ID " + verbId + " is not a ModifierUpgradeStep");
				return;
			}
			@mod = GetTriggerEffectFromID(step.GetModifiers(), modIndex);
		}

		if (mod is null)
		{
			PrintError("Couldn't find trigger effect for peer " + peer + ", verb " + verb + ", verb ID " + verbId + ", mod index " + modIndex);
			return;
		}

		mod.NetTrigger(player, target);
	}

	void UseUnit(UnitPtr unit, UnitPtr user)
	{
		auto usable = cast<IUsable>(unit.GetScriptBehavior());
		if (usable is null)
			return;

		Player@ plrLocal = cast<Player>(user.GetScriptBehavior());
		if (plrLocal !is null)
		{
			usable.Use(plrLocal);
			return;
		}

		PlayerHusk@ plrHusk = cast<PlayerHusk>(user.GetScriptBehavior());
		if (plrHusk !is null)
			usable.NetUse(plrHusk);
	}

	void UseUnitSecure(uint8 peer, UnitPtr unit)
	{
		if (!Network::IsServer())
			return;

		PlayerHusk@ plr = GetPlayer(peer);
		if (plr is null)
			return;

		auto usable = cast<IUsable>(unit.GetScriptBehavior());
		if (usable is null)
			return;

		if (!usable.CanUse(plr))
			return;

		(Network::Message("UseUnit") << unit << plr.m_unit).SendToAll();
		usable.NetUse(plr);
	}

	void TakeFreeLife(int peer, int freeLives)
	{
		if (Network::IsServer())
			return;

		for (uint i = 0; i < g_players.length(); i++)
		{
			PlayerRecord@ plr = g_players[i];
			if (plr.peer == uint8(peer))
			{
				plr.freeLivesTaken = freeLives;
				print("Peer " + peer + " now has " + freeLives + " lives");
				return;
			}
		}

		PrintError("Peer " + peer + " was not found");
	}

	Skills::ActiveSkill@ GetPlayerSkill(uint8 peer, int id)
	{
		PlayerHusk@ player = GetPlayer(peer);
		if (player is null)
			return null;

		for (uint i = 0; i < player.m_skills.length(); i++)
		{
			auto skill = cast<Skills::ActiveSkill>(player.m_skills[i]);
			if (skill !is null && skill.m_skillId == uint(id))
				return skill;
		}

		PrintError("Couldn't active stack skill with ID " + id + " for peer " + peer);
		return null;
	}

	Skills::IStackSkill@ GetPlayerStackSkill(uint8 peer, int id)
	{
		PlayerHusk@ player = GetPlayer(peer);
		if (player is null)
			return null;

		for (uint i = 0; i < player.m_skills.length(); i++)
		{
			auto skill = cast<Skills::IStackSkill>(player.m_skills[i]);
			if (skill !is null && player.m_skills[i].m_skillId == uint(id))
				return skill;
		}

		PrintError("Couldn't find stack skill with ID " + id + " for peer " + peer);
		return null;
	}

	void PlayerActiveSkillActivate(uint8 peer, int id, vec2 target)
	{
		auto skill = GetPlayerSkill(peer, id);
		if (skill is null)
			return;

		skill.NetActivate(target);
	}

	void PlayerActiveSkillDoActivate(uint8 peer, int id, vec2 target, SValue@ param)
	{
		auto skill = GetPlayerSkill(peer, id);
		if (skill is null)
			return;

		skill.NetDoActivate(param, target);
	}

	void PlayerActiveSkillDeactivate(uint8 peer, int id)
	{
		auto skill = GetPlayerSkill(peer, id);
		if (skill is null)
			return;

		skill.NetDeactivate();
	}

	void PlayerActiveSkillRelease(uint8 peer, int id, vec2 target)
	{
		auto skill = GetPlayerSkill(peer, id);
		if (skill is null)
			return;

		skill.NetRelease(target);
	}

	void PlayerStackSkillAdd(uint8 peer, int id, int num)
	{
		auto skill = GetPlayerStackSkill(peer, id);
		if (skill is null)
			return;

		skill.NetAddStack(num);
	}

	void PlayerStackSkillTake(uint8 peer, int id, int num)
	{
		auto skill = GetPlayerStackSkill(peer, id);
		if (skill is null)
			return;

		skill.NetTakeStack(num);
	}

	void PlayerShatterActivate(uint8 peer, UnitPtr enemy, SValue@ params)
	{
		PlayerHusk@ player = GetPlayer(peer);
		if (player is null)
			return;

		auto actor = cast<Actor>(enemy.GetScriptBehavior());
		if (actor is null)
		{
			PrintError("Enemy is not of type Actor!");
			return;
		}

		for (uint i = 0; i < player.m_skills.length(); i++)
		{
			auto shatter = cast<Skills::Shatter>(player.m_skills[i]);
			if (shatter !is null)
			{
				shatter.NetDo(actor, params);
				return;
			}
		}

		PrintError("Couldn't find shatter skill!");
	}

	void PlayerChargeUnit(uint8 peer, int id, float charge, vec2 target, int unitId)
	{
		auto skill = cast<Skills::ChargeUnit>(GetPlayerSkill(peer, id));
		if (skill is null)
			return;

		skill.DoShoot(charge, target, unitId);
	}

	void PlayerFanChargeUnit(uint8 peer, int id, float charge, vec2 target, SValue@ svArr)
	{
		auto skill = cast<Skills::FanChargeUnit>(GetPlayerSkill(peer, id));
		if (skill is null)
			return;

		skill.NetShoot(charge, target, svArr.GetArray());
	}

	void PlayerGiveGold(uint8 peer, int amount)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		NetGiveGoldImpl(amount, player);
	}

	void PlayerGiveOre(uint8 peer, int amount)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		NetGiveOreImpl(amount, player);
	}

	void PlayerGiveKey(uint8 peer, int lock, int amount)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		NetGiveKeyImpl(lock, amount, player);
	}

	void PlayerGiveDrink(uint8 peer, int id)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto drink = GetTavernDrink(uint(id));
		if (drink is null)
		{
			PrintError("No such drink with ID " + uint(id));
			return;
		}

		ConsumeDrinkImpl(drink, player, true);
	}

	void PlayerTakeItem(uint8 peer, string id)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto item = g_items.GetItem(id);
		if (item is null)
		{
			PrintError("No such item with ID \"" + id + "\"");
			return;
		}

		player.TakeItem(item);
	}

	void PlayerGiveItem(uint8 peer, string id)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto item = g_items.GetItem(id);
		if (item is null)
		{
			PrintError("No such item with ID \"" + id + "\"");
			return;
		}

		GiveItemImpl(item, player, true);
	}

	void PlayerItemAttuned(uint8 peer, string id)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto item = g_items.GetItem(id);
		if (item is null)
		{
			PrintError("No such item with ID \"" + id + "\"");
			return;
		}

		player.AttuneItem(item);
	}

	void PlayerGiveUpgrade(uint8 peer, string id, int level)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto upgrade = Upgrades::GetShopUpgrade(id, player.m_record);
		if (upgrade is null)
		{
			PrintError("Couldn't find upgrade with id \"" + id + "\" to upgrade to level " + level);
			return;
		}

		auto step = upgrade.GetStep(level);
		if (step is null)
		{
			PrintError("Couldn't find upgrade step level " + level + " for upgrade with id \"" + id + "\"");
			return;
		}

		if (!step.ApplyNow(player.m_record))
		{
			PrintError("Step ApplyNow returned false for level " + level + " of upgrade with id \"" + id + "\"");
			return;
		}

		if (upgrade.ShouldRemember())
		{
			OwnedUpgrade@ ownedUpgrade = player.m_record.GetOwnedUpgrade(upgrade.m_id);
			if (ownedUpgrade !is null)
			{
				ownedUpgrade.m_level = step.m_level;
				@ownedUpgrade.m_step = step;
			}
			else
			{
				@ownedUpgrade = OwnedUpgrade();
				ownedUpgrade.m_id = upgrade.m_id;
				ownedUpgrade.m_idHash = upgrade.m_idHash;
				ownedUpgrade.m_level = step.m_level;
				@ownedUpgrade.m_step = step;
				player.m_record.upgrades.insertLast(ownedUpgrade);
			}
		}

		player.RefreshModifiers();
	}

	void PlayerRespecSkills(uint8 peer)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		player.m_record.ClearSkillUpgrades();

		player.RefreshSkills();
		player.RefreshModifiers();
	}

	void PlayerUpdateHardcoreSkill(uint8 peer, int index, int skillId)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		if (skillId == 0)
			@player.m_record.hardcoreSkills[index] = null;
		else
		{
			auto hardcoreSkill = GetHardcoreSkill(uint(skillId));
			if (hardcoreSkill is null)
			{
				PrintError("Unable to find hardcore skill of ID " + uint(skillId));
				return;
			}

			@player.m_record.hardcoreSkills[index] = hardcoreSkill;
		}

		player.RefreshSkills();
		player.RefreshModifiers();
	}

	void PlayerRespecAttunements(uint8 peer)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
		player.RefreshModifiers();
	}

	void ProximityTrapEnter(uint8 peer, UnitPtr unit)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto trap = cast<ProximityTrap>(unit.GetScriptBehavior());
		if (trap is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not a ProximityTrap");
			return;
		}

		trap.OnEnter(player);
	}

	void ProximityTrapExit(uint8 peer, UnitPtr unit)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto trap = cast<ProximityTrap>(unit.GetScriptBehavior());
		if (trap is null)
		{
			PrintError("Unit " + unit.GetId() + " (" + unit.GetDebugName() + ") is not a ProximityTrap");
			return;
		}

		trap.OnExit(player);
	}

	void ReviveCorpse(uint8 peer, int plrId)
	{
		auto player = GetPlayerRecord(plrId);
		if (player is null)
			return;
			
		player.corpse.NetRevive(GetPlayerRecord(peer));
	}

	void PlayerLoadPet(uint8 peer, int currentPet, int currentPetSkin, SValue@ currentPetFlags)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		player.m_record.currentPet = uint(currentPet);
		player.m_record.currentPetSkin = uint(currentPetSkin);

		player.m_record.currentPetFlags.removeRange(0, player.m_record.currentPetFlags.length());
		auto arrPetFlags = currentPetFlags.GetArray();
		for (uint i = 0; i < arrPetFlags.length(); i++)
			player.m_record.currentPetFlags.insertLast(uint(arrPetFlags[i].GetInteger()));

		player.LoadPet();
	}

	void PlayerTitleModifiers(uint8 peer, SValue@ params)
	{
		auto player = GetPlayerRecord(peer);
		if (player is null)
			return;

		g_classTitles.NetRefreshModifiers(player, params);
	}

	void PlayerPing(uint8 peer, vec2 pos)
	{
		if (!GetVarBool("g_show_pings"))
			return;

		auto player = GetPlayerRecord(peer);
		if (player is null)
			return;

		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		player.pingCount++;

		UnitPtr unitPing = gm.m_prodPing.Produce(g_scene, xyz(pos));
		auto pingBehavior = cast<PingBehavior>(unitPing.GetScriptBehavior());
		@pingBehavior.m_owner = player;
	}

	void PlayerCombo(uint8 peer, bool started, int time, int count)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		player.m_comboActive = started;
		player.m_comboTime = time;
		player.m_comboCount = count;
	}

	void PlayerPotionCharged(uint8 peer)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		player.OnPotionCharged();
	}

	void PlayerUpdateColors(uint8 peer, SValue@ params)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto record = player.m_record;

		record.name = GetParamString(UnitPtr(), params, "name");
		record.face = GetParamInt(UnitPtr(), params, "face");
		record.voice = GetParamString(UnitPtr(), params, "voice");

		auto arrColors = GetParamArray(UnitPtr(), params, "colors");
		record.colors.removeRange(0, record.colors.length());
		for (uint i = 0; i < arrColors.length(); i++)
		{
			auto col = arrColors[i].GetArray();

			auto category = Materials::Category(col[0].GetInteger());
			uint id = uint(col[1].GetInteger());

			auto dye = Materials::GetDye(category, id);
			if (dye is null)
			{
				PrintError("Couldn't find dye for category " + int(category) + " and id " + id);
				continue;
			}

			record.colors.insertLast(dye);
		}

		record.currentTrail = uint(GetParamInt(UnitPtr(), params, "trail"));
		record.currentFrame = uint(GetParamInt(UnitPtr(), params, "frame"));
		record.currentComboStyle = uint(GetParamInt(UnitPtr(), params, "combo-style"));
		record.currentCorpse = uint(GetParamInt(UnitPtr(), params, "corpse"));

		player.UpdateProperties();
	}

	void PlayerChangeClass(uint8 peer, string newClass)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto record = player.m_record;
		record.charClass = newClass;
		player.Initialize(record);
	}

	void PlayerPotionDjinn(uint8 peer)
	{
		if (!Network::IsServer())
		{
			PrintError("We are not the server!");
			return;
		}

		auto player = GetPlayer(peer);
		if (player is null)
			return;

		if (player.m_djinnSpawnEffect.IsValid())
		{
			player.m_djinnSpawnEffect.Destroy();
			player.m_djinnSpawnEffect = UnitPtr();
		}

		auto prodGenie = Resources::GetUnitProducer("players/summons/potion_djinn.unit");
		if (prodGenie !is null)
		{
			player.m_djinn = prodGenie.Produce(g_scene, player.m_djinnSpawnPos);
			auto newGenie = cast<PlayerOwnedActor>(player.m_djinn.GetScriptBehavior());
			newGenie.Initialize(player, 1.0f, false, 0);

			(Network::Message("SetOwnedUnit") << player.m_djinn << player.m_unit << 1.0f).SendToAll();
		}
	}

	void PlayerPotionDjinnBegin(uint8 peer)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		if (player.m_djinn.IsValid())
		{
			if (Network::IsServer())
				player.m_djinn.Destroy();
			player.m_djinn = UnitPtr();
		}

		if (player.m_djinnSpawnEffect.IsValid())
		{
			player.m_djinnSpawnEffect.Destroy();
			player.m_djinnSpawnEffect = UnitPtr();
		}

		auto effect = Resources::GetEffect("players/summons/potion_djinn_spawn.effect");
		player.m_djinnSpawnTime = effect.Length();
		player.m_djinnSpawnEffect = PlayEffect(effect, player.m_unit.GetPosition());
		player.m_djinnSpawnPos = player.m_unit.GetPosition();
	}

	void PlayerArenaClear(uint8 peer)
	{
		if (peer != 0)
		{
			PrintError("Message is not from the server, it's from " + peer);
			return;
		}

		auto record = GetLocalPlayerRecord();
		record.items.removeRange(0, record.items.length());
		record.itemsBought.removeRange(0, record.itemsBought.length());
		record.itemsRecycled.removeRange(0, record.itemsRecycled.length());
		record.tavernDrinks.removeRange(0, record.tavernDrinks.length());
		record.tavernDrinksBought.removeRange(0, record.tavernDrinksBought.length());
	}

	void BloodAltarReward(uint8 peer, int id)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto reward = BloodAltar::GetReward(uint(id));
		if (reward is null)
		{
			PrintError("Reward unknown for ID " + uint(id));
			return;
		}

		player.m_record.bloodAltarRewards.insertLast(reward.idHash);
		player.RefreshModifiers();
	}

	void SetPetTarget(uint8 peer, vec2 pos, int petState)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		if (player.m_pet is null)
			return;

		player.m_pet.NetSetTarget(pos, petState);
	}

	void PlayerTransport(uint8 peer, string id, SValue@ params)
	{
		auto player = GetPlayer(peer);
		if (player is null)
			return;

		auto tp = TransportPoint::Get(id);
		if (tp is null)
		{
			PrintError("Unable to find transport point \"" + id + "\"");
			return;
		}

		tp.TeleportNet(player, params);
	}
}
