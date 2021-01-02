class Campaign : BaseGameMode
{
	float StartingHealth = 1.0;

	HUD@ m_hud;
	HUDCoop@ m_hudCoop;
	HUDSpeedrun@ m_hudSpeedrun;
	HUDFlags@ m_hudFlags;
	MinimapQuery@ m_minimap;
	BitmapString@ m_textMapLevel;

	PlayerMenu@ m_playerMenu;
	GuildHallMenu@ m_guildHallMenu;
	MercenaryLedger@ m_mercenaryLedger;
	ShopMenu@ m_shopMenu;

	NotificationManager@ m_notifications;

	bool m_allDead;
	uint m_allDeadTime;

	bool m_showMapOverlay;

	int m_prevIdt;

	bool m_shouldCountTime = true;
	int m_timePlayedC;
	int m_timePlayedDungeon;
	int m_timePlayedDungeonPrev;

	int m_darknessTimePrev;
	int m_darknessTime;

	TownRecord@ m_town;
	TownRecord@ m_townLocal;

	Titles::TitleList@ m_titlesGuild;

	UnitProducer@ m_prodPing;

	Campaign(Scene@ scene)
	{
		super(scene);

		@m_minimap = MinimapQuery();

		@Fountain::Modifiers = Modifiers::ModifierList();
		Fountain::Modifiers.m_name = Resources::GetString(".modifier.list.fountain");

		@m_titlesGuild = Titles::TitleList("tweak/titles/guild.sval");

		WidgetProducers::LoadIngame(m_guiBuilder);

		@m_hud = HUD(m_guiBuilder);
		@m_hudCoop = HUDCoop(m_guiBuilder);
		@m_hudSpeedrun = HUDSpeedrun(m_guiBuilder);
		@m_hudFlags = HUDFlags();

		m_userWindows.insertLast(@m_gameOver = HWRGameOver(m_guiBuilder));
		m_userWindows.insertLast(@m_playerMenu = PlayerMenu(m_guiBuilder));
		m_userWindows.insertLast(@m_guildHallMenu = GuildHallMenu(m_guiBuilder));
		m_userWindows.insertLast(@m_mercenaryLedger = MercenaryLedger(m_guiBuilder));
		m_userWindows.insertLast(@m_shopMenu = ShopMenu(m_guiBuilder));

		@m_notifications = NotificationManager(m_guiBuilder);

		@m_prodPing = Resources::GetUnitProducer("doodads/ping.unit");

		// This is here for development reasons (test from editor, run from command line)
		if (!VarExists("g_start_character"))
			AddVar("g_start_character", 0);

		AddVar("g_show_pings", true);
		AddVar("ui_speedrun", 0);
		AddVar("ui_flags", 0, null, 0);
		AddVar("ui_notifications", true);
		AddVar("g_gameover", true, null, 0);

		AddFunction("open_interface", { cvar_type::String, cvar_type::String }, OpenInterfaceCFunc, 0);

		AddFunction("reveal_desert_exit", RevealDesertExitCFunc, 0);

		AddFunction("set_last_gladiator_rank", { cvar_type::Int }, SetLastGladiatorRankCFunc, 0);

		Hooks::Call("GameModeConstructor", @this);

		if (HwrSaves::LoadCharacter() is null)
			HwrSaves::PickCharacter(GetVarInt("g_start_character"));
	}

	string GetLevelName(bool short = false)
	{
		int levelCount = m_levelCount;
		auto level = m_dungeon.GetLevel(levelCount);

		if (level is null)
			return "";

		string info = "";

		if (short)
			info += m_dungeon.GetActName(level) + "\n";
		else
		{
			string areaName = m_dungeon.GetAreaName(level);
			if (areaName != "")
				info += areaName + ", ";

			info += m_dungeon.GetActName(level) + " - ";
		}

		info += m_dungeon.GetFloorName(level);

		return info;
	}

	HUD@ GetHUD() override { return m_hud; }

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		@m_town = TownRecord();
		if (Network::IsServer())
			m_town.m_statistics.m_checkRewards = true;
		m_town.Load(HwrSaves::LoadHostTown());
		m_town.RefreshModifiers();

		@m_townLocal = TownRecord(true);
		m_townLocal.m_statistics.m_checkRewards = true;
		m_townLocal.m_statistics.InitializeCounters("town");
		m_townLocal.Load(HwrSaves::LoadLocalTown());
		m_townLocal.RefreshModifiers();

		LoadDungeonProperties(save);

		RefreshTownModifiers();

		if (save !is null)
		{
			m_timePlayedDungeon = GetParamInt(UnitPtr(), save, "dungeon-time", false);
			m_timePlayedDungeonPrev = GetParamInt(UnitPtr(), save, "dungeon-time-prev", false);
			m_levelCount = GetParamInt(UnitPtr(), save, "level-count", false, GetVarInt("g_start_level"));
			g_ngp = GetParamInt(UnitPtr(), save, "ngp", false, 0);
			g_downscaling = GetParamBool(UnitPtr(), save, "downscaling", false, false);

%if !HARDCORE
			if (GetParamBool(UnitPtr(), save, "soul-linked", false, false))
				g_flags.Set("allow_graveyard", FlagState::Level);
%endif

			auto arrFountain = GetParamArray(UnitPtr(), save, "fountain", false);
			if (arrFountain !is null)
			{
				for (uint i = 0; i < arrFountain.length(); i++)
					Fountain::ApplyEffect(arrFountain[i].GetInteger());

				m_townLocal.m_savedFountainEffects.removeRange(0, m_townLocal.m_savedFountainEffects.length());
			}

			if (sMode == StartMode::LoadGame)
			{
				SValue@ minimapData = save.GetDictionaryEntry("minimap");
				if (minimapData !is null)
					m_minimap.Read(g_scene, minimapData);
			}

			if (GetVarInt("ui_speedrun") > 0 && cast<Town>(g_gameMode) is null)
			{
				SValue@ speedrunData = save.GetDictionaryEntry("speedrun");
				if (speedrunData !is null && m_hudSpeedrun !is null)
					m_hudSpeedrun.Load(speedrunData);
			}

			auto arrTopIcons = GetParamArray(UnitPtr(), save, "topnumbers", false);
			if (arrTopIcons !is null)
			{
				for (uint i = 0; i < arrTopIcons.length(); i++)
				{
					string topID = GetParamString(UnitPtr(), arrTopIcons[i], "id");
					int num = GetParamInt(UnitPtr(), arrTopIcons[i], "num");
					m_hud.SetTopNumberIcon(topID, num);
				}
			}
		}
		else
		{
			m_levelCount = GetVarInt("g_start_level");
			if (Network::IsServer())
			{
				string strStartHostNgp = GlobalCache::Get("start_host_ngp");
				if (strStartHostNgp != "")
				{
					g_ngp = parseInt(strStartHostNgp);
					m_townLocal.m_currentNgp = int(g_ngp);
					GlobalCache::Set("start_host_ngp", "");
				}
%if !HARDCORE
				else
					g_ngp = float(m_townLocal.m_currentNgp);
%endif

				g_downscaling = (GlobalCache::Get("start_host_downscaling") == "true");
			}

			if (sMode != StartMode::StartGame)
			{
				for (uint i = 0; i < m_town.m_savedFountainEffects.length(); i++)
					Fountain::ApplyEffect(m_town.m_savedFountainEffects[i]);
			}
		}

		Fountain::RefreshModifiers(g_allModifiers);

		if (Network::IsServer() && Lobby::IsInLobby())
		{
			SValueBuilder builder;
			builder.PushInteger(int(g_ngp));
			SendSystemMessage("SetNGP", builder.Build());
		}

		BaseGameMode::Start(peer, save, sMode);

		if (cast<Town>(this) is null)
		{
			ivec3 level = CalcLevel(m_levelCount);
			if (level.y == 0)
			{
				auto localRecord = GetLocalPlayerRecord();
				Stats::AddAvg("avg-items-picked-act-" + (level.x + 1), localRecord);
				Stats::AddAvg("avg-gold-found-act-" + (level.x + 1), localRecord);
				Stats::AddAvg("avg-ore-found-act-" + (level.x + 1), localRecord);
			}
		}
		
		m_townLocal.CheckForNewTitle();
		m_hud.Start();
		m_started = true;
		print("NewGame+ " +g_ngp);
		print("Downscaling: " + g_downscaling);

		Hooks::Call("GameModeStart", @this, @save);
	}

	bool CheckDLC()
	{
		if (!m_dungeon.m_dlcReq.isEmpty() && !Platform::HasDLC(m_dungeon.m_dlcReq))
			return false;

		return true;
	}

	void PostStart() override
	{
		BaseGameMode::PostStart();

		if (Network::IsServer() && !CheckDLC())
		{
			auto player = GetLocalPlayer();
			if (player !is null)
				player.Kill(null, 0);
			(Network::Message("KillPlayer")).SendToAll();
			return;
		}

		auto record = GetLocalPlayerRecord();

		if (m_levelCount == 0 && m_startMode != StartMode::LoadGame)
		{
			Stats::AddAvg("time-played-run", record);
			Stats::AddAvg("avg-exp-gained", record);
			Stats::AddAvg("avg-levels-gained", record);
			Stats::AddAvg("avg-items-picked", record);
			Stats::AddAvg("avg-gold-found", record);
			Stats::AddAvg("avg-ore-found", record);
			Stats::Add("total-runs", 1, record);

			record.hp = 1.0f;
			record.mana = 1.0f;
			record.potionChargesUsed = 0;
		}

		Hooks::Call("GameModePostStart", @this);
	}

	void RefreshTownModifiers()
	{
		auto town = m_town;
		if (Network::IsServer())
			@town = m_townLocal;

		// Titles
		m_titlesGuild.ClearModifiers(g_allModifiers);
		town.GetTitle().EnableModifiers(g_allModifiers);

		// Refresh all players (statues are part of town but refreshed by players)
		for (uint i = 0; i < g_players.length(); i++)
		{
			auto player = g_players[i];
			if (player.peer != 255)
				player.RefreshModifiers();
		}
	}

	void Save(SValueBuilder& builder) override
	{
		Hooks::Call("GameModeSave", @this, builder);

		builder.PushInteger("ngp", int(g_ngp));
		builder.PushBoolean("downscaling", g_downscaling);

		builder.PushArray("fountain");
		for (uint i = 0; i < Fountain::CurrentEffects.length(); i++)
			builder.PushInteger(Fountain::CurrentEffects[i]);
		builder.PopArray();

		builder.PushInteger("dungeon-time", m_timePlayedDungeon);
		builder.PushInteger("dungeon-time-prev", m_timePlayedDungeonPrev);

		if (cast<Town>(this) is null)
			builder.PushSimple("minimap", m_minimap.Write());

		if (GetVarInt("ui_speedrun") > 0 && m_hudSpeedrun !is null)
		{
			builder.PushDictionary("speedrun");
			m_hudSpeedrun.Save(builder);
			builder.PopDictionary();
		}

		builder.PushArray("topnumbers");
		for (uint i = 0; i < m_hud.m_topNumberIcons.length(); i++)
			m_hud.m_topNumberIcons[i].Save(builder);
		builder.PopArray();

		BaseGameMode::Save(builder);
	}
	
	void SaveLocalTown(bool saveLevel = false)
	{
		SValueBuilder twnBuilder;

		twnBuilder.PushDictionary("town");
		m_townLocal.Save(twnBuilder, Network::IsServer());
		twnBuilder.PopDictionary();

		auto record = GetLocalPlayerRecord();
		SavePlayer(record, saveLevel, twnBuilder);
	}
	
	void SavePlayer(PlayerRecord& player, bool saveLevel = false, SValueBuilder@ town = null) override
	{
		if (!player.local)
			return;

%if HARDCORE
		if (m_savedMerc == 3)
		{
			print("Mercenary save stage 2");
			return;
		}
		m_savedMerc++;
%endif

		SValueBuilder plrBuilder;
		
		plrBuilder.PushDictionary("player");
		SavePlayer(plrBuilder, player);
		plrBuilder.PopDictionary();
		
		if (player.IsDead() || player.hp <= 0)
			saveLevel = false;
		
		if (town is null)
		{
			SValueBuilder twnBuilder;
			twnBuilder.PushDictionary("town");
			m_townLocal.Save(twnBuilder, Network::IsServer());
			twnBuilder.PopDictionary();
			@town = twnBuilder;
		}

		HwrSaves::SaveTownAndCharacter(town.Build(), plrBuilder.Build(), saveLevel);
	}
	
	void OnExitGame()
	{
		SaveLocalTown(true);
	}

	void RemovePlayer(uint8 peer, bool kicked) override
	{
		BaseGameMode::RemovePlayer(peer, kicked);

		CheckGameOver();
	}

	void SpawnPlayer(int i, vec2 pos = vec2(-1, -1), int unitId = 0, uint team = 0) override
	{
		BaseGameMode::SpawnPlayer(i, pos, unitId, team);

		auto record = g_players[i];
		if (m_startMode != StartMode::LoadGame)
			record.mtBlocks = record.GetMaxMtBlocks();

		Hooks::Call("GameModeSpawnPlayer", @this, @g_players[i]);
	}

	void PlayerDied(PlayerRecord@ player, PlayerRecord@ killer, DamageInfo di) override
	{
		if (player.local)
			@m_gameOver.m_killingActor = di.Attacker;

		CheckGameOver();

		Hooks::Call("GameModePlayerDied", @this, @player, @killer, di);
	}

	void CheckGameOver()
	{
		if (!GetVarBool("g_gameover"))
			return;

		int freeLives = 0;
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == 255)
				continue;
			freeLives += g_players[i].GetFreeLives();
		}

		if (GetPlayersAlive() == 0 && freeLives == 0)
		{
			m_allDead = true;
			m_allDeadTime = g_scene.GetTime();
		}
	}

	void UpdatePausedFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
		Platform::Service.InMenus(ShouldDisplayCursor());

		BaseGameMode::UpdatePausedFrame(ms, gameInput, menuInput);
	}

%if HARDCORE
	int m_savedMerc = 0;
%endif

	void UpdateFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
%if HARDCORE
		if (m_savedMerc == 2) {
			print("Ensuring mercenary save");
			SavePlayer(GetLocalPlayerRecord(), true);
			m_savedMerc++;
		} else if (m_savedMerc < 2) {
			m_savedMerc++;
		}
%endif

		RandomLootManager::Update(ms);
		Platform::Service.InMenus(ShouldDisplayCursor());

		if (gameInput.MapOverlay.Pressed)
		{
			m_showMapOverlay = !m_showMapOverlay;
			Tutorial::RegisterAction("map_overlay");
		}

		if (gameInput.Ping.Down && gameInput.Attack1.Pressed)
		{
			vec2 posMouse = m_mice[0].GetPos(0);
			vec3 posMouseWorld = ToWorldspace(posMouse);

			auto record = GetLocalPlayerRecord();
			if (record.pingCount < 2 && m_prodPing !is null && GetVarBool("g_show_pings"))
			{
				record.pingCount++;

				UnitPtr unitPing = m_prodPing.Produce(g_scene, posMouseWorld);
				auto pingBehavior = cast<PingBehavior>(unitPing.GetScriptBehavior());
				@pingBehavior.m_owner = record;

				(Network::Message("PlayerPing") << xy(posMouseWorld)).SendToAll();
			}
		}


		if (m_dungeon !is null && m_dungeon.ShouldExploreMinimap())
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				Actor@ a = g_players[i].actor;
				if (a !is null)
					m_minimap.Explore(g_scene, xy(a.m_unit.GetPosition()), 200);
			}
		}

		BaseGameMode::UpdateFrame(ms, gameInput, menuInput);

		if (GlobalCache::Get("main_restart") == "1")
		{
			GlobalCache::Set("main_restart", "");

			auto ply = GetLocalPlayer();
			if (ply !is null)
			{
				if (cast<Town>(this) is null)
					ply.Kill(null, 0);
				else
					ply.m_unit.SetPosition(xyz(g_spawnPos));
			}
		}

		if (cast<Town>(g_gameMode) is null && m_shouldCountTime)
		{
			m_timePlayedC += ms;
			if (m_timePlayedC >= 1000)
			{
				m_timePlayedC -= 1000;
				m_timePlayedDungeon++;
				Stats::Add("time-played", 1, GetLocalPlayerRecord());
				Stats::Add("time-played-run", 1, GetLocalPlayerRecord());
			}
		}

		DiscordPresence::Update(ms);
		ServicePresence::Update(ms);

		Hooks::Call("GameModeUpdate", @this, ms, gameInput, menuInput);
	}

	void UpdateWidgets(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
		BaseGameMode::UpdateWidgets(ms, gameInput, menuInput);

		m_notifications.Update(ms);

		if (!m_gameOver.m_visible && m_widgetInputFocus is null)
		{
			if (gameInput.PlayerMenu.Pressed)
			{
				ToggleUserWindow(m_playerMenu);
				Tutorial::RegisterAction("player_menu");
			}
			else if (gameInput.GuildMenu.Pressed)
			{
%if HARDCORE
				ToggleUserWindow(m_mercenaryLedger);
%else
				ToggleUserWindow(m_guildHallMenu);
%endif
				Tutorial::RegisterAction("guild_menu");
			}
		}

		m_playerMenu.m_tabMap.m_showFog = m_playerMenu.m_tabMap.ShouldShowFog();

		auto player = GetLocalPlayerRecord();
		if (player !is null && player.HasBeenDeadFor(1000))
		{
			if (player.GetFreeLives() > 0)
			{
				m_hud.m_wDeadMessage.SetText(Resources::GetString(".dead.respawn"));
				m_hud.m_wDeadMessage2.SetText("");
			}
			else
			{
				if (m_allDead && g_scene.GetTime() > m_allDeadTime + 2000)
				{
					m_hud.m_wDeadMessage.SetText("");
					m_hud.m_wDeadMessage2.SetText("");

					if (Network::IsServer() && !m_gameOver.IsVisible())
					{
						m_gameOver.DoShow();
						(Network::Message("GameOver")).SendToAll();
						PauseGame(true, false);

						OnRunEnd(true);
					}
				}
				else
				{
					m_hud.m_wDeadMessage.SetText(Resources::GetString(".dead.gameover"));
					if (m_allDead)
						m_hud.m_wDeadMessage2.SetText("");
					else
						m_hud.m_wDeadMessage2.SetText(Resources::GetString(".dead.gameover.spectate"));
				}
			}

			if (Lobby::IsInLobby())
			{
				m_hud.m_wDeadMessage.m_visible = !m_spectating;
				m_hud.m_wDeadMessage2.m_visible = !m_spectating;
			}

			if (gameInput.Use.Pressed && !ShouldFreezeControls())
			{
				if (m_extraLives > 0 || player.GetFreeLives() > 0)
				{
					if (Network::IsServer())
						AttemptRespawn(player.peer);
					else
						Network::Message("AttemptRespawn").SendToHost();
				}
				else if (g_players.length() > 1)
					ToggleSpectating();
			}
		}
		else
		{
			m_hud.m_wDeadMessage.m_visible = false;
			m_hud.m_wDeadMessage2.m_visible = false;
		}

		PlayerRecord@ record = null;
		if (m_spectating)
			@record = g_players[m_spectatingPlayer];
		else
			@record = GetLocalPlayerRecord();

		if (record !is null)
		{
			auto plr = cast<PlayerBase>(record.actor);
			if (plr !is null)
			{
				m_darknessTimePrev = m_darknessTime;
				if (plr.m_buffs.Darkness())
				{
					if (m_darknessTime < Tweak::DarknessFadeTime)
						m_darknessTime += ms;
					if (m_darknessTime > Tweak::DarknessFadeTime)
						m_darknessTime = Tweak::DarknessFadeTime;
				}
				else
				{
					if (m_darknessTime > 0)
						m_darknessTime -= ms;
					if (m_darknessTime < 0)
						m_darknessTime = 0;
				}
			}
		}

		m_hud.Update(ms, record);
		m_hudCoop.Update(ms);

		if (GetVarInt("ui_speedrun") > 0 && m_hudSpeedrun !is null)
			m_hudSpeedrun.Update(ms);

		Hooks::Call("GameModeUpdateWidgets", @this, ms, gameInput, menuInput);
	}

	vec4 GetMinimapRect()
	{
		int minimapSize = GetVarInt("ui_minimap_size");
		if (minimapSize == -1 || m_showMapOverlay)
			return vec4(0, 0, m_wndWidth, m_wndHeight);
		else
		{
			return vec4(
				m_wndWidth - minimapSize,
				0,
				minimapSize,
				minimapSize
			);
		}
	}

	float GetMinimapScale()
	{
		return 4.0f;
	}

	bool ShouldShowMinimap()
	{
		return m_showMapOverlay || (GetVarInt("ui_minimap_size") != -1);
	}

	bool CanGetExperience()
	{
		return true;
	}

	void RenderFrame(int idt, SpriteBatch& sb) override
	{
		Hooks::Call("GameModeRenderFrame", @this, idt, sb);

		BaseGameMode::RenderFrame(idt, sb);
	}

	void RenderWidgets(PlayerRecord@ player, int idt, SpriteBatch& sb) override
	{
		DrawFloatingTexts(idt, sb);

		if (m_gameOver.m_visible)
		{
			for (uint i = 0; i < m_userWindows.length(); i++)
			{
				if (m_userWindows[i] !is m_gameOver && m_userWindows[i] !is m_playerMenu && m_userWindows[i].m_visible)
					m_userWindows[i].Close();
			}
		}

		if (!m_playerMenu.m_visible && m_currInput !is null && ShouldShowMinimap())
		{
			vec4 rectMinimap = GetMinimapRect();

			sb.PushClipping(rectMinimap);
			sb.DrawMinimap(vec2(rectMinimap.x - 32, rectMinimap.y - 32), m_minimap, int(rectMinimap.z + 64), int(rectMinimap.w + 64), m_playerMenu.m_tabMap.GetMapColor(), vec4(1, 1, 1, GetVarFloat("ui_minimap_alpha")));
			sb.PopClipping();

			if (m_textMapLevel is null)
			{
				auto font = Resources::GetBitmapFont("gui/fonts/arial11.fnt");
				@m_textMapLevel = font.BuildText(GetLevelName(true), -1, TextAlignment::Right);
			}
			sb.DrawString(vec2(m_wndWidth - m_textMapLevel.GetWidth() - 2, -1), m_textMapLevel);
		}

		DrawOverheadBossBars(sb, idt);

		// Render darkness if not dead
		auto plr = cast<PlayerBase>(player.actor);
		if (plr !is null && m_darknessTime > 0)
		{
			float alphaTime = lerp(float(m_darknessTimePrev), float(m_darknessTime), idt / 33.0f);
			float alpha = easeQuad(alphaTime / float(Tweak::DarknessFadeTime));
			vec4 color = vec4(0, 0, 0, alpha);

			float uiScale = GetUIScale();
			int wndHeight = m_wndHeight + 1;
			vec4 spriteRectSource(0, 0, 128, 128);
			vec4 spriteRect;
			spriteRect.z = spriteRectSource.z / uiScale;
			spriteRect.w = spriteRectSource.w / uiScale;
			spriteRect.x = (m_wndWidth + 1) / 2 - spriteRect.z / 2;
			spriteRect.y = wndHeight / 2 - spriteRect.w / 2;

			sb.DrawSprite(Resources::GetTexture2D("gui/darkness.png"), spriteRect, spriteRectSource, color);
			sb.FillRectangle(vec4(0, 0, spriteRect.x, wndHeight), color);
			sb.FillRectangle(vec4(spriteRect.x, 0, spriteRect.z, spriteRect.y), color);
			sb.FillRectangle(vec4(spriteRect.x, spriteRect.y + spriteRect.w, spriteRect.z, spriteRect.y + 1), color);
			sb.FillRectangle(vec4(spriteRect.x + spriteRect.z, 0, spriteRect.x, wndHeight), color);
		}

		m_hud.Draw(sb, idt);
		m_hudCoop.Draw(sb, idt);

		if (GetVarInt("ui_speedrun") > 0 && m_hudSpeedrun !is null)
			m_hudSpeedrun.Draw(sb, idt);

		BaseGameMode::RenderWidgets(player, idt, sb);

		if (GetVarBool("ui_notifications"))
			m_notifications.Draw(sb, idt);

		int uiFlags = GetVarInt("ui_flags");
		if (m_hudFlags !is null && uiFlags > 0)
			m_hudFlags.Draw(sb, idt, uiFlags);

		Hooks::Call("GameModeRenderWidgets", @this, @player, idt, sb);
	}

	void PreRenderFrame(int idt) override
	{
		if (idt == 0 || idt < m_prevIdt)
		{
			if (m_playerMenu.m_visible)
				m_playerMenu.AfterUpdate();
			else if (m_currInput !is null && ShouldShowMinimap())
			{
				//float scale = m_playerMenu.m_tabMap.GetMapScale();
				float scale = GetMinimapScale();
				vec4 minimapRect = GetMinimapRect();
				m_minimap.Prepare(g_scene, m_camPos, int((minimapRect.z + 64) * scale), int((minimapRect.w + 64) * scale), ~0);
			}
		}
		m_prevIdt = idt;

		BaseGameMode::PreRenderFrame(idt);
	}

	// Called as soon as game over
	// Called as soon as EndOfGame is triggered
	void OnRunEnd(bool died)
	{
		auto record = GetLocalPlayerRecord();

%if HARDCORE
		if (died)
		{
			if (record.HasInsurance(m_dungeon.m_id))
			{
				int takeGold = ApplyTaxRate(m_townLocal.m_gold, record.runGold);
				m_townLocal.m_gold += takeGold;
				m_townLocal.m_ore += record.runOre;
				print("Mercenary life insurance saved " + takeGold + " gold and " + record.runOre + " ore to town");
			}

			record.mercenaryLocked = true;
			print("Locked Mercenary - RunEnd (Died)");
			record.mercenaryPointsReward = record.GetPrestige();
			record.mercenaryDiedDungeon = m_dungeon.m_id;
			record.mercenaryDiedLevel = m_levelCount;
			m_townLocal.m_legacyPoints += record.mercenaryPointsReward;
			m_townLocal.m_earnedLegacyPoints += record.mercenaryPointsReward;
			print("Mercenary death with " + record.mercenaryPointsReward + " points rewarded in dungeon \"" + record.mercenaryDiedDungeon + "\" level " + record.mercenaryDiedLevel);
		}
		else
		{
			if (record.mercenaryLocked)
			{
				record.mercenaryLocked = false;
				print("Unlocked Mercenary - Revived via RunEnd");
			}
		}

		record.TakeInsurance(m_dungeon.m_id);
%endif

		// Stop counting time
		m_shouldCountTime = false;

		// Remove items & keys
		record.items.removeRange(0, record.items.length());
		record.itemsRecycled.removeRange(0, record.itemsRecycled.length());
		record.itemsBought.removeRange(0, record.itemsBought.length());
		record.tavernDrinks.removeRange(0, record.tavernDrinks.length());
		record.tavernDrinksBought.removeRange(0, record.tavernDrinksBought.length());
		record.temporaryBuffs.removeRange(0, record.temporaryBuffs.length());
		for (uint i = 0; i < record.keys.length(); i++)
			record.keys[i] = 0;

		// Remove items taken flags
		for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
			g_items.m_allItemsList[i].inUse = false;

		// Remove flags
		auto flagKeys = g_flags.m_flags.getKeys();
		for (uint i = 0; i < flagKeys.length(); i++)
		{
			int64 state;
			g_flags.m_flags.get(flagKeys[i], state);

			if (FlagState(state) == FlagState::Run)
				g_flags.m_flags.delete(flagKeys[i]);
		}

		// Clear top numbers
		m_hud.ClearTopNumberIcons();

		// Deposit gold & ore to town
		DepositRun(record, died);

		// Calculate new handicap
		HandicapCalculate(record);

		// Reset some values
		record.hp = 1;
		record.mana = 1;
		record.potionChargesUsed = 0;
		record.runGold = 0;
		record.runOre = 0;
		record.curses = 0;
		record.runEnded = true;
		record.randomBuffNegative = 0;
		record.randomBuffPositive = 0;
		record.soulLinks.removeRange(0, record.soulLinks.length());
		record.soulLinkedBy = -1;
		record.generalStoreItemsSaved = -1;
		record.generalStoreItems.removeRange(0, record.generalStoreItems.length());
		record.generalStoreItemsPlumes.removeRange(0, record.generalStoreItemsPlumes.length());
		record.generalStoreItemsBought = 0;
		record.sarcophagusItemsSaved = -1;
		record.sarcophagusItems.removeRange(0, record.sarcophagusItems.length());
		record.itemDealerSaved = -1;
		record.itemDealerReward = "";
		record.itemForgeCrafted = -1;

		// Only reset blood altar rewards if we died (they remain when finishing the game)
		if (died)
			record.bloodAltarRewards.removeRange(0, record.bloodAltarRewards.length());

		Fountain::ClearEffects();

		Hooks::Call("GameModeOnRunEnd", @this, @record, died);

		// Done, save player and local town now
		//SavePlayer(record);
		SaveLocalTown();
	}

	void HandicapCalculate(PlayerRecord& record)
	{
		// Check against the previous run
		int runDiff = m_levelCount - record.previousRun;

		if (runDiff > 0)
			record.handicap *= 0.5f;
		else if (runDiff == 0)
			record.handicap *= 0.75f;
		else
			record.handicap = min(1.0f, record.handicap + 1.0f / record.statistics.GetStatInt("total-runs"));

		print("Level diff " + runDiff + " calls for new handicap: " + record.handicap);

		// Remember this run as the previous run
		record.previousRun = m_levelCount;
	}

	void DepositRun(PlayerRecord& record, bool died)
	{
		auto player = cast<Player>(record.actor);
		
		if (!died)
		{
			int takeGold = ApplyTaxRate(Currency::GetHomeGold(record), record.runGold, 2);
			Stats::Add("gold-stored", takeGold, record);

			int takeOre = record.runOre;
			Stats::Add("ores-stored", takeOre, record);

			Currency::GiveHome(record, takeGold, takeOre);
		}

		record.runGold = 0;
		record.runOre = 0;
		
		if (died)
		{
			int64 xpDiff = (record.experience - record.LevelExperience(record.level - 1));
			record.experience -= int64(xpDiff * Tweak::DeathExperienceLoss);
		}
	}

	void InitializePlayer(PlayerRecord& player) override
	{
		BaseGameMode::InitializePlayer(player);
		player.hp = StartingHealth;

		if (player.charClass == "")
		{
			array<string> classes = { "ranger", "paladin", "thief", "sorcerer", "warlock" };
			//array<string> classes = { "thief" };

			player.charClass = classes[randi(classes.length())];

			auto mapping = Materials::GetDyeMapping(player.charClass);
			if (mapping !is null)
			{
				for (uint i = 0; i < mapping.m_categories.length(); i++)
				{
					auto category = mapping.m_categories[i];
					auto dye = Materials::GetRandomDye(category);
					player.colors.insertLast(dye);
				}
			}
			else
				PrintError("Couldn't get material mapping for class \"" + player.charClass + "\"");
		}

		Hooks::Call("GameModeInitializePlayer", @this, @player);
	}

	void SavePlayer(SValueBuilder& builder, PlayerRecord& player) override
	{
		Hooks::Call("PlayerRecordSave", @player, builder);

		BaseGameMode::SavePlayer(builder, player);

		builder.PushString("name", player.name);

		builder.PushString("class", player.charClass);
		builder.PushInteger("face", player.face);
		builder.PushString("voice-id", player.voice);

		builder.PushArray("colors");
		for (uint i = 0; i < player.colors.length(); i++)
		{
			auto dye = player.colors[i];

			builder.PushArray();
			builder.PushInteger(int(dye.m_category));
			builder.PushInteger(dye.m_idHash);
			builder.PopArray();
		}
		builder.PopArray();

		builder.PushBoolean("free-customization-used", player.freeCustomizationUsed);
		builder.PushInteger("current-trail", player.currentTrail);
		builder.PushInteger("current-frame", player.currentFrame);
		builder.PushInteger("current-combo-style", player.currentComboStyle);
		builder.PushInteger("current-corpse", player.currentCorpse);

		builder.PushArray("hardcore-skills");
		for (uint i = 0; i < player.hardcoreSkills.length(); i++)
		{
			auto skill = player.hardcoreSkills[i];
			if (skill !is null)
				builder.PushInteger(int(skill.m_idHash));
			else
				builder.PushInteger(0);
		}
		builder.PopArray();

		builder.PushBoolean("free-respec-used", player.freeRespecUsed);
		builder.PushBoolean("new-boss-vampire", true);

		builder.PushFloat("handicap", player.handicap);
		builder.PushInteger("previous-run", player.previousRun);

		player.ngps.Save(builder, "ngps");

		builder.PushInteger("gladiator-points", player.gladiatorPoints);
		builder.PushArray("arena-flags");
		for (uint i = 0; i < player.arenaFlags.length(); i++)
			builder.PushInteger(int(player.arenaFlags[i]));
		builder.PopArray();

		player.retiredAttackPower.Save(builder, "retired-attack-power");
		player.retiredSkillPower.Save(builder, "retired-skill-power");
		player.retiredArmor.Save(builder, "retired-armor");
		player.retiredResistance.Save(builder, "retired-resistance");

		builder.PushBoolean("mercenary", player.mercenary);
		builder.PushArray("mercenary-insurances");
		for (uint i = 0; i < player.mercenaryInsurances.length(); i++)
			builder.PushString(player.mercenaryInsurances[i]);
		builder.PopArray();
		builder.PushBoolean("mercenary-locked", player.mercenaryLocked);
		if (player.mercenaryLocked)
		{
			builder.PushInteger("mercenary-points-reward", player.mercenaryPointsReward);
			builder.PushString("mercenary-died-dungeon", player.mercenaryDiedDungeon);
			builder.PushInteger("mercenary-died-level", player.mercenaryDiedLevel);
		}
		else
			builder.PushInteger("mercenary-prestige", player.GetPrestige());
		builder.PushArray("mercenary-upgrades");
		for (uint i = 0; i < player.mercenaryUpgrades.length(); i++)
		{
			auto ownedUpgrade = player.mercenaryUpgrades[i];
			builder.PushArray();
			builder.PushInteger(ownedUpgrade.m_idHash);
			builder.PushInteger(ownedUpgrade.m_level);
			builder.PopArray();
		}
		builder.PopArray();

		builder.PushInteger("title", player.titleIndex);
		builder.PushInteger("shortcut", player.shortcut);
		builder.PushInteger("random-buff-negative", player.randomBuffNegative);
		builder.PushInteger("random-buff-positive", player.randomBuffPositive);

		builder.PushInteger("mercenary-gold", player.mercenaryGold);
		builder.PushInteger("mercenary-ore", player.mercenaryOre);

		builder.PushInteger("run-gold", player.runGold);
		builder.PushInteger("run-ore", player.runOre);
		builder.PushInteger("curses", player.curses);

		builder.PushInteger("potion-charges-used", player.potionChargesUsed);

		builder.PushFloat("drifting-offset", player.driftingOffset);

		builder.PushDictionary("upgrades");
		for (uint i = 0; i < player.upgrades.length(); i++)
			builder.PushInteger(player.upgrades[i].m_id, player.upgrades[i].m_level);
		builder.PopDictionary();

		builder.PushArray("tavern-drinks");
		for (uint i = 0; i < player.tavernDrinks.length(); i++)
			builder.PushString(player.tavernDrinks[i]);
		builder.PopArray();

		builder.PushArray("tavern-drinks-bought");
		for (uint i = 0; i < player.tavernDrinksBought.length(); i++)
			builder.PushString(player.tavernDrinksBought[i]);
		builder.PopArray();
		
		builder.PushArray("temp-buffs");
		for (uint i = 0; i < player.temporaryBuffs.length(); i++)
			builder.PushInteger(player.temporaryBuffs[i]);
		builder.PopArray();
		
		builder.PushArray("items");
		for (uint i = 0; i < player.items.length(); i++)
			builder.PushString(player.items[i]);
		builder.PopArray();

		builder.PushArray("items-bought");
		for (uint i = 0; i < player.itemsBought.length(); i++)
			builder.PushString(player.itemsBought[i]);
		builder.PopArray();

		builder.PushArray("items-recycled");
		for (uint i = 0; i < player.itemsRecycled.length(); i++)
			builder.PushString(player.itemsRecycled[i]);
		builder.PopArray();
		
		builder.PushArray("keys");
		for (uint i = 0; i < player.keys.length(); i++)
			builder.PushInteger(player.keys[i]);
		builder.PopArray();
		
		builder.PushArray("soul-links");
		for (uint i = 0; i < player.soulLinks.length(); i++)
			builder.PushInteger(player.soulLinks[i]);
		builder.PopArray();

		builder.PushInteger("soul-linked-by", player.soulLinkedBy);

		if (player.revealDesertExit != 0)
			builder.PushInteger("reveal-desert-exit", player.revealDesertExit);

		builder.PushInteger("mt-blocks", player.mtBlocks);

		builder.PushDictionary("statistics");
		player.statistics.Save(builder);
		builder.PopDictionary();

		builder.PushDictionary("statistics-session");
		player.statisticsSession.Save(builder);
		builder.PopDictionary();

		builder.PushArray("bestiary-attunements");
		for (uint i = 0; i < player.bestiaryAttunements.length(); i++)
		{
			auto entry = player.bestiaryAttunements[i];
			if (entry.m_attuned == 0)
				continue;

			builder.PushArray();
			builder.PushInteger(entry.m_idHash);
			builder.PushInteger(entry.m_attuned);
			builder.PopArray();
		}
		builder.PopArray();

		builder.PushArray("blood-altar-rewards");
		for (uint i = 0; i < player.bloodAltarRewards.length(); i++)
			builder.PushInteger(player.bloodAltarRewards[i]);
		builder.PopArray();

		builder.PushArray("generalstore");
		builder.PushInteger(player.generalStoreItemsSaved);
		for (uint i = 0; i < player.generalStoreItems.length(); i++)
			builder.PushInteger(player.generalStoreItems[i]);
		builder.PopArray();

		builder.PushArray("sarcophagus");
		builder.PushInteger(player.sarcophagusItemsSaved);
		for (uint i = 0; i < player.sarcophagusItems.length(); i++)
			builder.PushInteger(player.sarcophagusItems[i]);
		builder.PopArray();

		builder.PushInteger("item-dealer", player.itemDealerSaved);
		builder.PushString("item-dealer-reward", player.itemDealerReward);

		builder.PushDictionary("generalstore-plumes");
		for (uint i = 0; i < player.generalStoreItemsPlumes.length(); i++)
		{
			auto pair = player.generalStoreItemsPlumes[i];
			builder.PushInteger(pair.m_id, pair.m_category);
		}
		builder.PopDictionary();

		if (player.generalStoreItemsBought > 0)
			builder.PushInteger("generalstore-bought", player.generalStoreItemsBought);

		builder.PushArray("item-forge-attuned");
		for (uint i = 0; i < player.itemForgeAttuned.length(); i++)
			builder.PushInteger(player.itemForgeAttuned[i]);
		builder.PopArray();
		builder.PushInteger("item-forge-crafted", player.itemForgeCrafted);

		builder.PushArray("chapel-upgrades-purchased");
		for (uint i = 0; i < player.chapelUpgradesPurchased.length(); i++)
			builder.PushString(player.chapelUpgradesPurchased[i]);
		builder.PopArray();

		builder.PushArray("unlocked-pets");
		for (uint i = 0; i < player.unlockedPets.length(); i++)
			builder.PushInteger(player.unlockedPets[i]);
		builder.PopArray();

		builder.PushInteger("current-pet", player.currentPet);
		builder.PushInteger("current-pet-skin", player.currentPetSkin);
		builder.PushArray("current-pet-flags");
		for (uint i = 0; i < player.currentPetFlags.length(); i++)
			builder.PushInteger(player.currentPetFlags[i]);
		builder.PopArray();
	}

	void LoadPlayer(SValue& data, PlayerRecord& player) override
	{
		BaseGameMode::LoadPlayer(data, player);

		// Load main stats
		player.name = GetParamString(UnitPtr(), data, "name", false, player.name);

		player.charClass = GetParamString(UnitPtr(), data, "class", false, player.charClass);
		player.face = GetParamInt(UnitPtr(), data, "face", false, player.face);
		player.voice = GetParamString(UnitPtr(), data, "voice-id", false, player.voice);

		// Clear colors
		player.colors.removeRange(0, player.colors.length());

		// Player colors
		/*
		//TODO: Somehow use the old values?
		player.skinColor = GetParamInt(UnitPtr(), data, "color-skin", false, player.skinColor);
		player.color1 = GetParamInt(UnitPtr(), data, "color-1", false, player.color1);
		player.color2 = GetParamInt(UnitPtr(), data, "color-2", false, player.color2);
		player.color3 = GetParamInt(UnitPtr(), data, "color-3", false, player.color3);
		*/
		auto dyeMap = Materials::GetDyeMapping(player.charClass);
		auto arrColors = GetParamArray(UnitPtr(), data, "colors", false);
		if (arrColors !is null)
		{
			for (uint i = 0; i < arrColors.length(); i++)
			{
				auto arrCol = arrColors[i].GetArray();
				int category = arrCol[0].GetInteger();
				uint index = uint(arrCol[1].GetInteger());
				auto dye = Materials::GetDye(Materials::Category(category), index);
				if (dye is null)
				{
					PrintError("Couldn't load dye with category " + int(category) + " at index " + i + "!");
					continue;
				}
				player.colors.insertLast(dye);
			}

			if (dyeMap !is null && dyeMap.m_categories.length() > player.colors.length())
			{
				PrintError("WARNING: Missing colors on player, adding " + (dyeMap.m_categories.length() - player.colors.length()) + " random ones!");
				for (uint i = player.colors.length(); i < dyeMap.m_categories.length(); i++)
				{
					auto category = dyeMap.m_categories[i];
					auto dye = Materials::GetRandomDye(category);
					player.colors.insertLast(dye);
				}
			}
		}
		else if (dyeMap !is null)
		{
			for (uint i = 0; i < dyeMap.m_categories.length(); i++)
			{
				auto category = dyeMap.m_categories[i];
				auto dye = Materials::GetRandomDye(category);
				player.colors.insertLast(dye);
			}
		}

		player.freeCustomizationUsed = GetParamBool(UnitPtr(), data, "free-customization-used", false, false);
		player.currentTrail = GetParamInt(UnitPtr(), data, "current-trail", false);
		player.currentFrame = GetParamInt(UnitPtr(), data, "current-frame", false, HashString("default"));
		player.currentComboStyle = GetParamInt(UnitPtr(), data, "current-combo-style", false, HashString("default"));
		player.currentCorpse = GetParamInt(UnitPtr(), data, "current-corpse", false);

		player.handicap = GetParamFloat(UnitPtr(), data, "handicap", false, player.handicap);
		player.previousRun = GetParamInt(UnitPtr(), data, "previous-run", false, 0);

		// NGPs
		player.ngps.Load(data, "ngps");

		int gladiatorWins = GetParamInt(UnitPtr(), data, "gladiator-wins", false, 0); //TODO: Remove this (only for developer save compat)
		player.gladiatorPoints = GetParamInt(UnitPtr(), data, "gladiator-points", false, gladiatorWins);

		auto arrArenaFlags = GetParamArray(UnitPtr(), data, "arena-flags", false);
		if (arrArenaFlags !is null)
		{
			for (uint i = 0; i < arrArenaFlags.length(); i++)
			{
				uint flag = uint(arrArenaFlags[i].GetInteger());

				auto sw = SurvivalSwitches::GetSwitch(flag);
				if (sw is null)
				{
					PrintError("Couldn't find switch with flag hash " + flag);
					continue;
				}

				player.arenaFlags.insertLast(flag);
			}
		}

		int oldGladiatorUpgrade = GetParamInt(UnitPtr(), data, "gladiator-upgrade", false, 0);

		player.retiredAttackPower.Load(data, "retired-attack-power", oldGladiatorUpgrade);
		player.retiredSkillPower.Load(data, "retired-skill-power");
		player.retiredArmor.Load(data, "retired-armor");
		player.retiredResistance.Load(data, "retired-resistance");

		player.mercenary = GetParamBool(UnitPtr(), data, "mercenary", false, false);
		player.ClearInsurances();
		auto arrMercenaryInsurances = GetParamArray(UnitPtr(), data, "mercenary-insurances", false);
		if (arrMercenaryInsurances !is null)
		{
			for (uint i = 0; i < arrMercenaryInsurances.length(); i++)
				player.GiveInsurance(arrMercenaryInsurances[i].GetString());
		}
		player.mercenaryLocked = GetParamBool(UnitPtr(), data, "mercenary-locked", false, false);
		player.mercenaryPointsReward = GetParamInt(UnitPtr(), data, "mercenary-points-reward", false, 0);
		player.mercenaryDiedDungeon = GetParamString(UnitPtr(), data, "mercenary-died-dungeon", false, "");
		player.mercenaryDiedLevel = GetParamInt(UnitPtr(), data, "mercenary-died-level", false, 0);

		auto arrMercenaryUpgrades = GetParamArray(UnitPtr(), data, "mercenary-upgrades", false);
		if (arrMercenaryUpgrades !is null)
		{
			for (uint i = 0; i < arrMercenaryUpgrades.length(); i++)
			{
				auto arrOwnedUpgrade = arrMercenaryUpgrades[i].GetArray();

				auto ownedUpgrade = MercenaryUpgrade();
				ownedUpgrade.m_idHash = uint(arrOwnedUpgrade[0].GetInteger());
				ownedUpgrade.m_level = arrOwnedUpgrade[1].GetInteger();
				player.mercenaryUpgrades.insertLast(ownedUpgrade);
			}
		}

		player.titleIndex = GetParamInt(UnitPtr(), data, "title", false, player.titleIndex);
		player.shortcut = GetParamInt(UnitPtr(), data, "shortcut", false, 0);
		player.randomBuffNegative = GetParamInt(UnitPtr(), data, "random-buff-negative", false, 0);
		player.randomBuffPositive = GetParamInt(UnitPtr(), data, "random-buff-positive", false, 0);

		int baseNgp = player.ngps["base"];
		if (baseNgp > 0 && !player.mercenary)
			player.titleIndex = max(player.titleIndex, baseNgp + 5);

		if (!GetParamBool(UnitPtr(), data, "new-boss-vampire", false) && player.titleIndex >= 5)
			player.titleIndex++;

		player.mercenaryGold = GetParamInt(UnitPtr(), data, "mercenary-gold", false, 0);
		player.mercenaryOre = GetParamInt(UnitPtr(), data, "mercenary-ore", false, 0);

		player.runGold = GetParamInt(UnitPtr(), data, "run-gold", false, 0);
		player.runOre = GetParamInt(UnitPtr(), data, "run-ore", false, 0);
		player.curses = GetParamInt(UnitPtr(), data, "curses", false, 0);

		player.potionChargesUsed = GetParamInt(UnitPtr(), data, "potion-charges-used", false, 0);

		player.driftingOffset = GetParamFloat(UnitPtr(), data, "drifting-offset", false, 0.0f);

		// Clear upgrades
		player.upgrades.removeRange(0, player.upgrades.length());

		// Load upgrades
		bool hasSkillUpgrade = false;
		auto dicUpgrades = GetParamDictionary(UnitPtr(), data, "upgrades", false);
		if (dicUpgrades !is null)
		{
			auto arrKeys = dicUpgrades.GetDictionary().getKeys();

			print("Upgrades: " + arrKeys.length());
			for (uint i = 0; i < arrKeys.length(); i++)
			{
				string id = arrKeys[i];
				int level = GetParamInt(UnitPtr(), dicUpgrades, arrKeys[i]);

				OwnedUpgrade ownedUpgrade;
				ownedUpgrade.m_id = id;
				ownedUpgrade.m_idHash = HashString(id);
				ownedUpgrade.m_level = level;

				auto upgrade = Upgrades::GetShopUpgrade(ownedUpgrade.m_id, player);
				if (upgrade is null)
				{
					PrintError("Upgrade is null for \"" + ownedUpgrade.m_id + "\"");
					continue;
				}
				@ownedUpgrade.m_step = upgrade.GetStep(ownedUpgrade.m_level);

				player.upgrades.insertLast(ownedUpgrade);
			}

			print("Applying " + player.upgrades.length() + " upgrades to \"" + player.GetName() + "\":");
			
			for (uint i = 0; i < player.upgrades.length(); i++)
			{
				auto upgr = player.upgrades[i];

				if (cast<Upgrades::RecordUpgradeStep>(upgr.m_step) !is null)
					hasSkillUpgrade = true;

				/*
				string upgrInfo = Resources::GetString(upgr.m_step.m_name) + " (upgrade id \"" + upgr.m_id + "\" - hash " + upgr.m_idHash + ", level " + upgr.m_level + ")";
				if (upgr.m_step.ApplyNow(player))
					print("+ " + upgrInfo);
				else
					print("  " + upgrInfo);
				*/

				upgr.m_step.ApplyNow(player);
			}
		}

		// Hardcore skills
		auto arrHardcoreSkills = GetParamArray(UnitPtr(), data, "hardcore-skills", false);
		if (arrHardcoreSkills !is null)
		{
			for (int i = 0; i < min(player.hardcoreSkills.length(), arrHardcoreSkills.length()); i++)
			{
				uint skillHash = uint(arrHardcoreSkills[i].GetInteger());
				if (skillHash == 0)
					continue;

				auto hardcoreSkill = GetHardcoreSkill(skillHash);
				if (hardcoreSkill is null)
					continue;

				@player.hardcoreSkills[i] = hardcoreSkill;
			}
		}

		// Free respec
		player.freeRespecUsed = GetParamBool(UnitPtr(), data, "free-respec-used", false, false);
		if (!player.freeRespecUsed && !hasSkillUpgrade)
			player.freeRespecUsed = true;

		// Clear keys
		for (uint i = 0; i < player.keys.length(); i++)
			player.keys[i] = 0;

		// Load keys
		auto keyData = data.GetDictionaryEntry("keys");
		if (keyData !is null)
		{
			auto arr = keyData.GetArray();
			for (uint i = 0; i < arr.length() && i < player.keys.length(); i++)
				player.keys[i] = arr[i].GetInteger();
		}

		// Clear soul links
		player.soulLinks.removeRange(0, player.soulLinks.length());

		// Load soul links
		auto soulLinkData = data.GetDictionaryEntry("soul-links");
		if (soulLinkData !is null)
		{
			auto arr = soulLinkData.GetArray();
			for (uint i = 0; i < arr.length() && i < player.keys.length(); i++)
				player.soulLinks.insertLast(arr[i].GetInteger());
		}

		// Load soul linked by
		auto soulLinkedBy = data.GetDictionaryEntry("soul-linked-by");
		if (soulLinkedBy !is null)
			player.soulLinkedBy = soulLinkedBy.GetInteger();

		// Reveal desert exit
		if (m_startMode == StartMode::LoadGame)
		{
			auto revealDesertExit = data.GetDictionaryEntry("reveal-desert-exit");
			if (revealDesertExit !is null)
			{
				if (revealDesertExit.GetType() == SValueType::Integer)
					player.RevealDesertExit(revealDesertExit.GetInteger());
				else if (revealDesertExit.GetType() == SValueType::Boolean && revealDesertExit.GetBoolean())
					player.RevealDesertExit();
			}
		}

		// Moon Temple block reward
		player.mtBlocks = GetParamInt(UnitPtr(), data, "mt-blocks", false);

		// Clear tavern drinks
		player.tavernDrinks.removeRange(0, player.tavernDrinks.length());
		player.tavernDrinksBought.removeRange(0, player.tavernDrinksBought.length());
		
		// Load tavern drinks
		auto tdData = data.GetDictionaryEntry("tavern-drinks");
		if (tdData !is null)
		{
			auto arr = tdData.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				string drinkId = arr[i].GetString();
				if (TakeTavernDrink(HashString(drinkId)) !is null)
					player.tavernDrinks.insertLast(drinkId);
			}
		}

		// Load tavern drinks bought
		auto tdbData = data.GetDictionaryEntry("tavern-drinks-bought");
		if (tdbData !is null)
		{
			auto arr = tdbData.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				string drinkId = arr[i].GetString();
				if (GetTavernDrink(HashString(drinkId)) !is null)
					player.tavernDrinksBought.insertLast(drinkId);
			}
		}

		// Clear temp buffs
		player.temporaryBuffs.removeRange(0, player.temporaryBuffs.length());
		
		// Load temp buffs
		auto tbData = data.GetDictionaryEntry("temp-buffs");
		if (tbData !is null)
		{
			auto arr = tbData.GetArray();
			for (uint i = 0; i < arr.length(); i += 2)
			{
				auto buff = uint(arr[i + 0].GetInteger());
				auto ms = uint(arr[i + 1].GetInteger());
				
				if (ms <= 0)
					continue;
				
				player.temporaryBuffs.insertLast(buff);
				player.temporaryBuffs.insertLast(ms);
			}
		}
		
		// Clear items
		player.items.removeRange(0, player.items.length());
		player.itemsBought.removeRange(0, player.itemsBought.length());
		player.itemsRecycled.removeRange(0, player.itemsRecycled.length());
		
		// Load items
		auto itData = data.GetDictionaryEntry("items");
		if (itData !is null)
		{
			auto arr = itData.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				string itemId = arr[i].GetString();
				if (g_items.GetItem(itemId) !is null)
					player.items.insertLast(itemId);
			}
		}

		// Load items bought
		auto itBought = data.GetDictionaryEntry("items-bought");
		if (itBought !is null)
		{
			auto arr = itBought.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				string itemId = arr[i].GetString();
				if (g_items.GetItem(itemId) !is null)
					player.itemsBought.insertLast(itemId);
			}
		}

		// Load items recycled
		auto itRecycled = data.GetDictionaryEntry("items-recycled");
		if (itRecycled !is null)
		{
			auto arr = itRecycled.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				string itemId = arr[i].GetString();
				if (g_items.GetItem(itemId) !is null)
					player.itemsRecycled.insertLast(itemId);
			}
		}

		if (player.local)
		{
			// Make sure that all the items we own as the local player are "taken"
			for (uint i = 0; i < player.items.length(); i++)
				g_items.TakeItem(player.items[i]);

			// Make sure all recycled items are also in use
			for (uint i = 0; i < player.itemsRecycled.length(); i++)
				g_items.TakeItem(player.itemsRecycled[i]);
		}

		// Load character statistics
		auto dictStatistics = GetParamDictionary(UnitPtr(), data, "statistics", false);
		if (dictStatistics !is null)
			player.statistics.Load(dictStatistics);

		if (player.local)
			player.statistics.InitializeCounters("player");

		// Load session statistics
		auto dictStatisticsSession = GetParamDictionary(UnitPtr(), data, "statistics-session", false);
		if (dictStatisticsSession !is null)
			player.statisticsSession.Load(dictStatisticsSession);

		if (player.local)
			player.statistics.InitializeCounters("player_session");

		// Load bestiary attunements
		auto arrBestiaryAttunements = GetParamArray(UnitPtr(), data, "bestiary-attunements", false);
		if (arrBestiaryAttunements !is null)
		{
			for (uint i = 0; i < arrBestiaryAttunements.length(); i++)
			{
				auto arr = arrBestiaryAttunements[i].GetArray();
				uint prodHash = uint(arr[0].GetInteger());

				auto entry = player.GetBestiaryAttunement(prodHash);
				entry.m_attuned = arr[1].GetInteger();
			}
		}

		// Load blood altar rewards
		auto arrBloodAltarRewards = GetParamArray(UnitPtr(), data, "blood-altar-rewards", false);
		if (arrBloodAltarRewards !is null)
		{
			for (uint i = 0; i < arrBloodAltarRewards.length(); i++)
				player.bloodAltarRewards.insertLast(uint(arrBloodAltarRewards[i].GetInteger()));
		}

		// Load general store items
		auto arrGeneralStore = GetParamArray(UnitPtr(), data, "generalstore", false);
		if (arrGeneralStore !is null && arrGeneralStore.length() > 0)
		{
			player.generalStoreItemsSaved = arrGeneralStore[0].GetInteger();
			for (uint i = 1; i < arrGeneralStore.length(); i++)
				player.generalStoreItems.insertLast(arrGeneralStore[i].GetInteger());
		}
		else
			player.generalStoreItemsSaved = -1;

		// Load sarcophagus items
		auto arrSarcophagus = GetParamArray(UnitPtr(), data, "sarcophagus", false);
		if (arrSarcophagus !is null && arrSarcophagus.length() > 0)
		{
			player.sarcophagusItemsSaved = arrSarcophagus[0].GetInteger();
			for (uint i = 1; i < arrSarcophagus.length(); i++)
				player.sarcophagusItems.insertLast(arrSarcophagus[i].GetInteger());
		}
		else
			player.sarcophagusItemsSaved = -1;

		// Load item dealer
		player.itemDealerSaved = GetParamInt(UnitPtr(), data, "item-dealer", false, -1);
		player.itemDealerReward = GetParamString(UnitPtr(), data, "item-dealer-reward", false);

		// Compatibility: Fancy plume item
		auto svPlume = data.GetDictionaryEntry("generalstore-plume");
		if (svPlume !is null && svPlume.GetType() == SValueType::Integer)
			player.generalStoreItemsPlumes.insertLast(PlumePair("fancy-plume", svPlume.GetInteger()));

		// Load general store plume state
		auto svPlumes = data.GetDictionaryEntry("generalstore-plumes");
		if (svPlumes !is null)
		{
			auto dicPlumes = svPlumes.GetDictionary();
			auto arrPlumeKeys = dicPlumes.getKeys();
			for (uint i = 0; i < arrPlumeKeys.length(); i++)
			{
				string strId = arrPlumeKeys[i];

				auto svCategory = svPlumes.GetDictionaryEntry(strId);
				if (svCategory !is null)
					player.SetPlumePair(strId, svCategory.GetInteger());
			}
		}

		// Load general store item bought count
		player.generalStoreItemsBought = GetParamInt(UnitPtr(), data, "generalstore-bought", false);

		// Load item forge states
		auto arrItemForgeAttuned = GetParamArray(UnitPtr(), data, "item-forge-attuned", false);
		if (arrItemForgeAttuned !is null)
		{
			for (uint i = 0; i < arrItemForgeAttuned.length(); i++)
			{
				uint idHash = uint(arrItemForgeAttuned[i].GetInteger());

				auto item = g_items.GetItem(idHash);
				if (item is null || !item.canAttune)
					continue;

				player.itemForgeAttuned.insertLast(idHash);
			}
		}

		auto svForgeCrafted = data.GetDictionaryEntry("item-forge-crafted");
		if (svForgeCrafted !is null)
		{
			if (svForgeCrafted.GetType() == SValueType::Boolean)
				player.itemForgeCrafted = svForgeCrafted.GetBoolean() ? 0 : -1;
			else
				player.itemForgeCrafted = svForgeCrafted.GetInteger();
		}

		// Load owned chapel upgrades
		auto arrChapelUpgradesPurchased = GetParamArray(UnitPtr(), data, "chapel-upgrades-purchased", false);
		if (arrChapelUpgradesPurchased !is null)
		{
			for (uint i = 0; i < arrChapelUpgradesPurchased.length(); i++)
			{
				string id = arrChapelUpgradesPurchased[i].GetString();
				if (player.chapelUpgradesPurchased.find(id) == -1)
					player.chapelUpgradesPurchased.insertLast(id);
			}
		}

		// Load unlocked pets
		player.unlockedPets.removeRange(0, player.unlockedPets.length());
		auto arrUnlockedPets = GetParamArray(UnitPtr(), data, "unlocked-pets", false);
		if (arrUnlockedPets !is null)
		{
			for (uint i = 0; i < arrUnlockedPets.length(); i++)
				player.unlockedPets.insertLast(arrUnlockedPets[i].GetInteger());
		}

		// Load current pet
		player.currentPetSkin = GetParamInt(UnitPtr(), data, "current-pet-skin", false);

		player.currentPetFlags.removeRange(0, player.currentPetFlags.length());
		auto arrPetFlags = GetParamArray(UnitPtr(), data, "current-pet-flags", false);
		if (arrPetFlags !is null)
		{
			for (uint i = 0; i < arrPetFlags.length(); i++)
				player.currentPetFlags.insertLast(uint(arrPetFlags[i].GetInteger()));
		}

		
%if !HARDCORE
		player.currentPet = uint(GetParamInt(UnitPtr(), data, "current-pet", false));
%else
		auto petHash = GetParamInt(UnitPtr(), data, "current-pet", false, -1);
		if (petHash == -1)
		{
			player.currentPetSkin = randi(2);
			petHash = HashString("squire");

			for (uint i = 0; i < Pets::g_flags.length(); i++)
				if (Pets::g_flags[i].m_default)
					player.currentPetFlags.insertLast(Pets::g_flags[i].m_idHash);
		}

		player.currentPet = uint(petHash);
%endif
		

		Hooks::Call("PlayerRecordLoad", @player, @data);

		if (player.actor !is null)
			cast<PlayerBase>(player.actor).Refresh();
	}
}

void OpenInterfaceCFunc(cvar_t@ arg0, cvar_t@ arg1)
{
	// Emulate an OpenInterface worldscript
	auto wsOpenInterface = WorldScript::OpenInterface();
	wsOpenInterface.Filename = arg0.GetString();
	wsOpenInterface.Class = arg1.GetString();
	wsOpenInterface.MakeRoot = true;
	wsOpenInterface.Start(false);
}

void RevealDesertExitCFunc()
{
	auto record = GetLocalPlayerRecord();
	record.RevealDesertExit();
}

void SetLastGladiatorRankCFunc(cvar_t@ arg0)
{
	auto gm = cast<Campaign>(g_gameMode);
	gm.m_townLocal.m_lastGladiatorRank = arg0.GetInt();
}
