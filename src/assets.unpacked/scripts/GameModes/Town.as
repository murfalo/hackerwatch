bool g_isTown = false;

[GameMode]
class Town : Campaign
{
	string m_upgradedBuildingName;

	array<StatueBehavior@> m_statueUnits;

	UserWindow@ m_introWindow;
	GravestoneInterface@ m_gravestoneInterface;

	Town(Scene@ scene)
	{
		super(scene);

		@m_hudSpeedrun = null;

		m_userWindows.insertLast(@m_introWindow = UserWindow(m_guiBuilder, "gui/intro.gui"));
		m_userWindows.insertLast(@m_gravestoneInterface = GravestoneInterface(m_guiBuilder));
	}
	
	// TODO: Delete this (USE_MULTIPLAYER)
	void Generate(SValue@ save) {}

	string GetLevelName(bool short = false) override
	{
		return Resources::GetString(".world.town");
	}

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		g_isTown = true;

		Campaign::Start(peer, save, sMode);
		Campaign::PostStart();

		m_timePlayedDungeonPrev = m_timePlayedDungeon;
		m_timePlayedDungeon = 0;
		
		m_levelCount = GetVarInt("g_start_level");

		SpawnBuildings();
		SpawnStatues();

		if (save !is null)
		{
			auto arrPlayerPos = GetParamArray(UnitPtr(), save, "town-player-pos", false);
			if (arrPlayerPos !is null)
			{
				for (uint i = 0; i < arrPlayerPos.length(); i += 2)
				{
					int posPeer = arrPlayerPos[i].GetInteger();
					vec3 pos = arrPlayerPos[i + 1].GetVector3();

					auto record = GetPlayerRecordByPeer(posPeer);
					if (record !is null && record.actor !is null)
						record.actor.m_unit.SetPosition(pos);
				}
			}

			// Restore saved effects from Survival
			if (sMode != StartMode::StartGame)
			{
				m_town.m_savedFountainEffects = Fountain::CurrentEffects;
				m_townLocal.m_savedFountainEffects = Fountain::CurrentEffects;
			}
		}

		auto localRecord = GetLocalPlayerRecord();
		if (!g_flags.IsSet("unlock_apothecary"))
			localRecord.potionChargesUsed = 1;
		if (localRecord.GladiatorRank() > 0 && g_owns_dlc_pop)
			g_flags.Set("unlock_gladiator", FlagState::Town);

		// If there are no drinks yet, we'll add a few random ones
		bool hasNoDrinks = true;
		for (uint i = 0; i < g_tavernDrinks.length(); i++)
		{
			if (g_tavernDrinks[i].localCount != -1)
			{
				hasNoDrinks = false;
				break;
			}
		}

		if (hasNoDrinks)
		{
			array<TavernDrink@> possibleDrinks;
			for (uint i = 0; i < g_tavernDrinks.length(); i++)
			{
				if (g_tavernDrinks[i].quality == ActorItemQuality::Common)
					possibleDrinks.insertLast(g_tavernDrinks[i]);
			}

			for (int i = 0; i < 2; i++)
			{
				if (possibleDrinks.length() == 0)
					break;

				int index = randi(possibleDrinks.length());
				possibleDrinks[index].localCount = 10;
				possibleDrinks.removeAt(index);
			}
		}

		// If there are no blueprints yet, we'll add a few random ones
		if (m_townLocal.m_forgeBlueprints.length() == 0)
		{
			array<ActorItem@> possibleItems;
			for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
			{
				auto item = g_items.m_allItemsList[i];

				if (!item.hasBlueprints || item.quality != ActorItemQuality::Common)
					continue;

				possibleItems.insertLast(item);
			}

			for (int i = 0; i < 2; i++)
			{
				if (possibleItems.length() == 0)
					break;

				int index = randi(possibleItems.length());
				m_townLocal.m_forgeBlueprints.insertLast(possibleItems[index].idHash);
				possibleItems.removeAt(index);
			}
		}

		if (GetVarBool("ui_show_intro"))
		{
			SetVar("ui_show_intro", false);
			Config::SaveVar("ui_show_intro", "0");
			m_introWindow.Show();
		}

		Lobby::SetJoinable(true);

		CheckForAchievements();
		CheckForNgpNotifications();
		CheckForUnlockedClasses();

		DiscordPresence::Clear();
		DiscordPresence::SetState("In town");
		DiscordPresence::SetLargeImageKey("act_town");

		ServicePresence::Clear();
		ServicePresence::Set("#Status_InTown");
	}

	void LoadDungeonFallback() override
	{
		@m_dungeon = DungeonProperties::Get("base");
	}

	bool ShouldRevivePlayerOnSpawn(PlayerRecord@ record) override
	{
		return true;
	}

	bool m_spawnedGravestones = false;

	void UpdateFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
		if (!m_spawnedGravestones)
		{
			SpawnGravestones();
			m_spawnedGravestones = true;
		}

		if (g_ngp > 0)
			DiscordPresence::SetDetails("NG+" + g_ngp);

		Campaign::UpdateFrame(ms, gameInput, menuInput);
	}

	void CheckForAchievements()
	{
		if (m_townLocal.GetBuilding("tavern").m_level >= 1)
			Platform::Service.UnlockAchievement("class_thief");
		if (m_townLocal.GetBuilding("chapel").m_level >= 1)
			Platform::Service.UnlockAchievement("class_priest");
		if (m_townLocal.GetBuilding("magicshop").m_level >= 1)
			Platform::Service.UnlockAchievement("class_wizard");
		if (g_flags.Get("unlock_gladiator") == FlagState::Town)
			Platform::Service.UnlockAchievement("class_gladiator");

		if (m_townLocal.m_bossesKilled[0] != 0)
			Platform::Service.UnlockAchievement("beat_stone_guardian");
		if (m_townLocal.m_bossesKilled[1] != 0)
			Platform::Service.UnlockAchievement("beat_warden");
		if (m_townLocal.m_bossesKilled[2] != 0)
			Platform::Service.UnlockAchievement("beat_three_councilors");
		if (m_townLocal.m_bossesKilled[3] != 0)
			Platform::Service.UnlockAchievement("beat_watcher");
		if (m_townLocal.m_bossesKilled[4] != 0)
		{
			Platform::Service.UnlockAchievement("beat_thundersnow");
			Platform::Service.UnlockAchievement("beat_forsaken_tower");
		}
		if (m_townLocal.m_bossesKilled[5] != 0)
			Platform::Service.UnlockAchievement("beat_vampire");

		if (m_townLocal.m_bossesKilled[6] != 0)
			Platform::Service.UnlockAchievement("beat_crustworm");
		if (m_townLocal.m_bossesKilled[7] != 0)
			Platform::Service.UnlockAchievement("beat_iris");
		if (m_townLocal.m_bossesKilled[8] != 0)
		{
			Platform::Service.UnlockAchievement("beat_nerys");
			Platform::Service.UnlockAchievement("beat_pop");
		}

		if (m_townLocal.m_bossesKilled[9] != 0)
			Platform::Service.UnlockAchievement("beat_elder_wisp");
		if (m_townLocal.m_bossesKilled[10] != 0)
			Platform::Service.UnlockAchievement("beat_wolf");
		if (m_townLocal.m_bossesKilled[11] != 0)
		{
			Platform::Service.UnlockAchievement("beat_agents");
			Platform::Service.UnlockAchievement("beat_moon_temple");
		}
		
		if (g_flags.Get("unlock_combo") == FlagState::Town)
			Platform::Service.UnlockAchievement("combo");
		if (g_flags.Get("unlock_anvil") == FlagState::Town)
			Platform::Service.UnlockAchievement("magic_anvil");
		if (g_flags.Get("unlock_bestiary") == FlagState::Town)
			Platform::Service.UnlockAchievement("bestiary");
		
		auto arrCharacters = HwrSaves::GetCharacters();
		for (uint i = 0; i < arrCharacters.length(); i++)
		{
			auto svChar = arrCharacters[i];

			int level = GetParamInt(UnitPtr(), svChar, "level");
			string charClass = GetParamString(UnitPtr(), svChar, "class");
			bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
			int titleIndex = GetParamInt(UnitPtr(), svChar, "title", false);

			if (level >= 20)
				Platform::Service.UnlockAchievement("level20_" + charClass);
			if (level >= 40)
				Platform::Service.UnlockAchievement("level40_" + charClass);
			if (level >= 60)
				Platform::Service.UnlockAchievement("level60_" + charClass);

			DungeonNgpList ngps;
			ngps.Load(svChar, "ngps");

			int ngp = ngps["base"];
			if (ngp > 0 && mercenary)
				Platform::Service.UnlockAchievement("merc_beat_forsaken_tower");
			if (ngp > 1)
				Platform::Service.UnlockAchievement("beat_forsaken_tower_ng");
			if (ngp > 2)
				Platform::Service.UnlockAchievement("beat_forsaken_tower_ng2");
			if (ngp > 3)
				Platform::Service.UnlockAchievement("beat_forsaken_tower_ng3");
			if (ngp > 4)
				Platform::Service.UnlockAchievement("beat_forsaken_tower_ng4");
			if (ngp > 5)
				Platform::Service.UnlockAchievement("beat_forsaken_tower_ng5");

			int ngpPop = ngps["pop"];
			if (ngpPop > 0 && mercenary)
				Platform::Service.UnlockAchievement("merc_beat_pop");
			if (ngpPop > 1)
				Platform::Service.UnlockAchievement("beat_pop_ng");
			if (ngpPop > 2)
				Platform::Service.UnlockAchievement("beat_pop_ng2");
			if (ngpPop > 3)
				Platform::Service.UnlockAchievement("beat_pop_ng3");
			if (ngpPop > 4)
				Platform::Service.UnlockAchievement("beat_pop_ng4");
			if (ngpPop > 5)
				Platform::Service.UnlockAchievement("beat_pop_ng5");

			int ngpMt = ngps["mt"];
			if (ngpMt > 0 && mercenary)
				Platform::Service.UnlockAchievement("merc_beat_moon_temple");
			if (ngpMt > 1)
				Platform::Service.UnlockAchievement("beat_moon_temple_ng");
			if (ngpMt > 2)
				Platform::Service.UnlockAchievement("beat_moon_temple_ng2");
			if (ngpMt > 3)
				Platform::Service.UnlockAchievement("beat_moon_temple_ng3");
			if (ngpMt > 4)
				Platform::Service.UnlockAchievement("beat_moon_temple_ng4");
			if (ngpMt > 5)
				Platform::Service.UnlockAchievement("beat_moon_temple_ng5");

			if (mercenary)
			{
				if (titleIndex >= 1)
					Platform::Service.UnlockAchievement("merc_corporal");
				if (titleIndex >= 2)
					Platform::Service.UnlockAchievement("merc_sergeant");
				if (titleIndex >= 3)
					Platform::Service.UnlockAchievement("merc_lieutenant");
				if (titleIndex >= 4)
					Platform::Service.UnlockAchievement("merc_captain");
				if (titleIndex >= 5)
					Platform::Service.UnlockAchievement("merc_major");
				if (titleIndex >= 6)
					Platform::Service.UnlockAchievement("merc_colonel");
				if (titleIndex >= 7)
					Platform::Service.UnlockAchievement("merc_general");
			}
		}

		for (uint i = 0; i < m_townLocal.m_statues.length(); i++)
		{
			auto statue = m_townLocal.m_statues[i];
			if (statue.m_level == 0)
				continue;

			auto statueDef = statue.GetDef();
			if (statueDef is null || statueDef.m_achievement == "")
				continue;

			Platform::Service.UnlockAchievement(statueDef.m_achievement);
		}

		if (m_townLocal.GetBuilding("townhall").m_level >= 6 &&
			m_townLocal.GetBuilding("treasury").m_level >= 5 &&
			m_townLocal.GetBuilding("guildhall").m_level >= 5 &&
			m_townLocal.GetBuilding("generalstore").m_level >= 6 &&
			m_townLocal.GetBuilding("blacksmith").m_level >= 6 &&
			m_townLocal.GetBuilding("oretrader").m_level >= 4 &&
			m_townLocal.GetBuilding("apothecary").m_level >= 5 &&
			m_townLocal.GetBuilding("fountain").m_level >= 2 &&
			m_townLocal.GetBuilding("chapel").m_level >= 4 &&
			m_townLocal.GetBuilding("tavern").m_level >= 3 &&
			m_townLocal.GetBuilding("magicshop").m_level >= 4)
			Platform::Service.UnlockAchievement("town_restored");
	}

	void CheckForNgpNotifications()
	{
		auto record = GetLocalPlayerRecord();

		// Character NGPs
		for (uint i = 0; i < record.ngps.m_ngps.length(); i++)
		{
			auto ngp = record.ngps.m_ngps[i];

			auto dungeon = DungeonProperties::Get(ngp.m_id);
			if (dungeon is null)
				continue;

			if (ngp.m_ngp > ngp.m_presented)
			{
				string strId = dungeon.m_strNotifyCharNgp;
				if (ngp.m_ngp == 1)
					strId += ".first";

				m_notifications.Add(Resources::GetString(strId, {
					{ "ngp", int(ngp.m_ngp - 1) }
				}));
			}
		}

		{ // Town's highest NGPs
			int highestNgp = m_townLocal.m_highestNgps.GetHighest();
			int highestNgpPresented = m_townLocal.m_highestNgps.GetHighestPresented();
			if (highestNgp > highestNgpPresented)
			{
				m_notifications.Add(Resources::GetString(".hud.newngp.unlocked", {
					{ "ngp", highestNgp }
				}));
				m_townLocal.m_highestNgps.SetPresented();
			}
		}

		{ // Character's highest NGPs
			int highestNgp = record.ngps.GetHighest();
			int highestNgpPresented = record.ngps.GetHighestPresented();
			if (highestNgp > highestNgpPresented)
			{
				m_notifications.Add(Resources::GetString(".hud.newngp.char.unlocked", {
					{ "ngp", highestNgp },
					{ "level", record.GetLevelCap() }
				}));
			}
			record.ngps.SetPresented();
		}
	}

	void CheckForUnlockedClasses()
	{
		if (g_flags.IsSet("unlock_gladiator") && !g_flags.IsSet("unlock_gladiator_reported") && Platform::HasDLC("pop"))
		{
			m_notifications.Add(Resources::GetString(".class.gladiator.unlocked"));
			g_flags.Set("unlock_gladiator_reported", FlagState::Town);
		}
	}

	void Save(SValueBuilder& builder) override
	{
		builder.PushArray("town-player-pos");
		for (uint i = 0; i < g_players.length(); i++)
		{
			auto player = g_players[i];
			if (player.actor is null || player.peer == 255)
				continue;

			builder.PushInteger(player.peer);
			builder.PushVector3(player.actor.m_unit.GetPosition());
		}
		builder.PopArray();

		string strGladiatorRating = GlobalCache::Get("start_rating");
		if (strGladiatorRating != "")
		{
			int gladiatorRating = parseInt(strGladiatorRating);
			builder.PushInteger("gladiator-rating", gladiatorRating);
		}
		
		Campaign::Save(builder);
	}

	void OnExitGame() override
	{
		SaveLocalTown(false);
	}
	
	void SpawnBuildings()
	{
		if (!Network::IsServer())
			return;

		auto res = g_scene.FetchAllWorldScripts("SpawnTownBuilding");
		for (uint i = 0; i < res.length(); i++)
		{
			auto spawn = cast<WorldScript::SpawnTownBuilding>(res[i].GetUnit().GetScriptBehavior());
			auto building = m_town.GetBuilding(spawn.TypeName);

			auto prefab = building.GetPrefab(spawn.Variation);
			if (prefab is null)
			{
				PrintError("Couldn't find prefab for '" + building.m_typeName + "' for level " + building.m_level);
				continue;
			}

			prefab.Fabricate(g_scene, spawn.Position);
		}
	}

	void SpawnGravestones()
	{
		if (!Network::IsServer())
			return;

		auto res = g_scene.FetchAllWorldScripts("SpawnTownGravestone");

		auto arrTopChars = TopMercenaries::Get();

		for (int i = 0; i < min(arrTopChars.length(), res.length()); i++)
		{
			auto scriptUnit = res[i].GetUnit();

			auto prod = Resources::GetUnitProducer("doodads/generic/grave_mercenary.unit");
			UnitPtr unit = prod.Produce(g_scene, scriptUnit.GetPosition());

			auto gravestone = cast<PlayerGravestoneBehavior>(unit.GetScriptBehavior());
			gravestone.Initialize(arrTopChars[i].m_charData);
		}
	}

	void SpawnStatues()
	{
		auto res = g_scene.FetchAllWorldScripts("SpawnTownStatue");
		for (uint i = 0; i < res.length(); i++)
		{
			auto scriptUnit = res[i].GetUnit();
			auto prod = Resources::GetUnitProducer("doodads/statue.unit");

			UnitPtr unit = prod.Produce(g_scene, scriptUnit.GetPosition());

			auto statueBehavior = cast<StatueBehavior>(unit.GetScriptBehavior());
			statueBehavior.Initialize(cast<WorldScript::SpawnTownStatue>(scriptUnit.GetScriptBehavior()));

			m_statueUnits.insertLast(statueBehavior);
		}

		SetStatues();
	}

	void SetStatues()
	{
		auto town = m_town;
		if (Network::IsServer())
			@town = m_townLocal;

		for (uint i = 0; i < m_statueUnits.length(); i++)
		{
			TownStatue@ statue = null;
			if (i < town.m_statuePlacements.length())
				@statue = town.GetStatue(town.m_statuePlacements[i]);
			m_statueUnits[i].SetStatue(statue);
		}
	}
	
	void SavePlayer(SValueBuilder& builder, PlayerRecord& player) override
	{
		Campaign::SavePlayer(builder, player);
		builder.PushBoolean("in-town", true);
	}

	void LoadPlayer(SValue& data, PlayerRecord& player) override
	{
		Campaign::LoadPlayer(data, player);

		player.statisticsSession.Clear();
		
		if (player.local && !GetParamBool(UnitPtr(), data, "in-town", false, false))
			OnRunEnd(true);

		player.hp = 1;
		player.mana = 1;
		player.potionChargesUsed = 0;
		player.runGold = 0;
		player.runOre = 0;
		player.curses = 0;
		player.soulLinkedBy = -1;
	}

	string GetPlayerDisplayName(PlayerRecord@ record, bool multiline = true) override
	{
		auto title = record.GetTitle();
		if (title !is null)
		{
			string ret = Resources::GetString(title.m_name);
			if (multiline)
				ret += "\n";
			else
				ret += " ";
			ret += Campaign::GetPlayerDisplayName(record);
		}

		return Campaign::GetPlayerDisplayName(record);
	}

	bool CheckDLC() override
	{
		return true;
	}
}
