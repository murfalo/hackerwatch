pint g_gladiatorRating = 0;
bool g_isSurvival = false;

void SetCrowdValueCfunc(cvar_t@ arg0)
{
	auto gm = cast<Survival>(g_gameMode);
	if (gm is null)
		return;

	gm.m_crowdValue = float(arg0.GetInt());
}

[GameMode]
class Survival : Campaign
{
	HUDSurvival@ m_hudSurvival;

	array<WorldScript::SurvivalCrowdSound@> m_crowdSounds;

	array<SurvivalEnemySpawnPoint@> m_enemySpawns;

	int m_waveBest;
	int m_waveCount;
	int m_totalWaveCount;

	SurvivalWaveProgress@ m_currWave;

	pfloat m_crowdValue = 50.0f;

	int m_crowdTime = 10000;
	int m_crowdTimeC;

	bool m_crowdPaused;

	uint64 m_crowdTimeElapsed;

	bool m_expLocked;

	array<uint> m_savedFountainEffects;

	Survival(Scene@ scene)
	{
		super(scene);

		AddVar("g_debug_crowd", false, null, 0);

		AddFunction("set_crowd_value", { cvar_type::Int }, SetCrowdValueCfunc, 0);

		Crowd::LoadActions("tweak/crowd.sval");

		m_crowdTimeC = m_crowdTime;
		m_crowdPaused = false;

		m_expLocked = true;

		@m_hudSurvival = HUDSurvival(m_guiBuilder);
	}

	string GetLevelName(bool short = false) override
	{
		if (g_gladiatorRating == 0)
			return Resources::GetString(".world.coliseum");

		return Resources::GetString(".world.coliseum.rank", {
			{ "rank", int(g_gladiatorRating) }
		});
	}

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		g_isSurvival = true;

		g_flags.Set("in_survival", FlagState::Level);
		if (GetCurrentLevelFilename() == "levels/arena.lvl")
			g_flags.Set("dlc_pop", FlagState::Level);

		Campaign::Start(peer, save, sMode);

		m_savedFountainEffects = Fountain::CurrentEffects;
		Fountain::ClearEffects();
		Fountain::RefreshModifiers(g_allModifiers);

		if (Network::IsServer())
		{
			auto record = GetLocalPlayerRecord();
			for (uint i = 0; i < record.arenaFlags.length(); i++)
			{
				auto sw = SurvivalSwitches::GetSwitch(record.arenaFlags[i]);
				if (sw is null)
					continue;

				g_flags.Set(sw.m_flag, FlagState::Level);
				(Network::Message("SyncFlag") << sw.m_flag << true << false).SendToAll();
			}
		}

		g_gladiatorRating = 0;

		if (save !is null)
		{
			g_gladiatorRating = GetParamInt(UnitPtr(), save, "gladiator-rating");

			if (sMode == StartMode::LoadGame)
			{
				m_waveBest = GetParamInt(UnitPtr(), save, "wave-best", false, m_waveBest);
				m_waveCount = GetParamInt(UnitPtr(), save, "wave-count", false, m_waveCount);
				m_totalWaveCount = GetParamInt(UnitPtr(), save, "total-wave-count", false, m_totalWaveCount);

				auto svCurrentWave = GetParamDictionary(UnitPtr(), save, "current-wave", false);
				if (svCurrentWave !is null)
					@m_currWave = SurvivalWaveProgress(svCurrentWave);

				m_crowdValue = GetParamFloat(UnitPtr(), save, "crowd-value", false, m_crowdValue);

				float lastDelta = GetParamFloat(UnitPtr(), save, "last-delta", false);
				m_hudSurvival.OnValueChange(lastDelta);

				m_crowdTimeC = GetParamInt(UnitPtr(), save, "crowd-time", false, m_crowdTimeC);
				m_crowdPaused = GetParamBool(UnitPtr(), save, "crowd-paused", false, m_crowdPaused);
				m_crowdTimeElapsed = uint64(GetParamLong(UnitPtr(), save, "crowd-time-elapsed", false, int64(m_crowdTimeElapsed)));

				m_expLocked = GetParamBool(UnitPtr(), save, "exp-locked", false, m_expLocked);
			}
		}
		else
			g_gladiatorRating = parseInt(GlobalCache::Get("start_rating"));

		g_ngp = int(g_gladiatorRating) * 0.2f;

		PostStart();

		auto sndCrowdWs = g_scene.FetchAllWorldScripts("SurvivalCrowdSound");
		for (uint i = 0; i < sndCrowdWs.length(); i++)
		{
			auto unit = sndCrowdWs[i].GetUnit();
			auto b = cast<WorldScript::SurvivalCrowdSound>(unit.GetScriptBehavior());
			if (b is null)
				continue;

			b.Start();
			m_crowdSounds.insertLast(b);
		}

		UpdateCrowdSounds();
	}

	void PostStart() override
	{
		Campaign::PostStart();

		UpdateDiscordStatus();
	}

	void UpdateDiscordStatus()
	{
		DiscordPresence::Clear();
		DiscordPresence::SetState("In arena");
		if (m_waveCount > 0 && m_totalWaveCount > 0)
		{
			DiscordPresence::SetDetails("Wave " + m_waveCount + " / " + m_totalWaveCount);
			//TODO: Add NG+ (gladiator rank)
		}
		DiscordPresence::SetStartTimestamp(time());
		DiscordPresence::SetLargeImageKey("act_arena");

		ServicePresence::Clear();
		ServicePresence::Set("#Status_InArena");
		ServicePresence::Param("wave", "" + m_waveCount);
		ServicePresence::Param("totalwaves", "" + m_totalWaveCount);
	}

	void UpdateCrowdSounds()
	{
		for (uint i = 0; i < m_crowdSounds.length(); i++)
			m_crowdSounds[i].UpdateSound(m_crowdValue);
	}

	bool ShouldRevivePlayerOnSpawn(PlayerRecord@ record) override
	{
		return true;
	}

	void Save(SValueBuilder& builder) override
	{
		Fountain::CurrentEffects = m_savedFountainEffects;

		Campaign::Save(builder);

		builder.PushInteger("gladiator-rating", g_gladiatorRating);

		builder.PushInteger("wave-best", m_waveBest);
		builder.PushInteger("wave-count", m_waveCount);
		builder.PushInteger("total-wave-count", m_totalWaveCount);

		if (m_currWave !is null)
		{
			builder.PushDictionary("current-wave");
			m_currWave.Save(builder);
			builder.PopDictionary();
		}

		builder.PushFloat("crowd-value", m_crowdValue);
		builder.PushFloat("last-delta", m_hudSurvival.m_lastDelta);

		builder.PushInteger("crowd-time", m_crowdTimeC);
		builder.PushBoolean("crowd-paused", m_crowdPaused);
		builder.PushLong("crowd-time-elapsed", int64(m_crowdTimeElapsed));

		builder.PushBoolean("exp-locked", m_expLocked);
	}

	void LoadPlayer(SValue& data, PlayerRecord& player) override
	{
		Campaign::LoadPlayer(data, player);

		player.statisticsSession.Clear();

		if (m_startMode != StartMode::LoadGame)
		{
			player.hp = 1;
			player.mana = 1;
			player.potionChargesUsed = 0;
			player.runGold = 0;
			player.runOre = 0;
			player.curses = 0;
			player.soulLinkedBy = -1;
		}
	}

	void OnRunEnd(bool died) override
	{
		auto record = GetLocalPlayerRecord();

		array<string> itemsBought = record.itemsBought;
		array<string> tavernDrinksBought = record.tavernDrinksBought;

		Campaign::OnRunEnd(died);

		Fountain::CurrentEffects = m_savedFountainEffects;

		if (!died)
		{
			record.items = record.itemsBought = itemsBought;
			record.tavernDrinks = record.tavernDrinksBought = tavernDrinksBought;
		}
	}

	void ResizeWindow(int w, int h, float scale) override
	{
		Campaign::ResizeWindow(w, h, scale);

		if (m_hudSurvival !is null)
			m_hudSurvival.Invalidate();
	}

	bool CanGetExperience() override
	{
		return !m_expLocked;
	}

	void UpdateFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
		Campaign::UpdateFrame(ms, gameInput, menuInput);

		bool debugCrowd = GetVarBool("g_debug_crowd");

		Crowd::Update(ms);

		if (GetVarBool("ui_hud_survival"))
			m_hudSurvival.Update(ms);

		if (m_currWave !is null)
			m_currWave.Update(ms);

		if (!m_crowdPaused && Network::IsServer())
		{
			m_crowdTimeElapsed += ms;

			float crowdTimeMultiplier = 1.0f;
			/*
			if (g_flags.IsSet("arena_faster_waves"))
				crowdTimeMultiplier = 2.0f;
			*/

			m_crowdTimeC -= int(ms * crowdTimeMultiplier);
			if (m_crowdTimeC <= 0)
			{
				m_crowdTimeC = m_crowdTime;

				float delta = Crowd::ClearDelta();

				for (uint i = 0; i < g_crowdChangeTriggers.length(); i++)
					g_crowdChangeTriggers[i].OnChange(delta);

				if (debugCrowd)
				{
					if (delta < 0.0f)
						print("D:");
					else if (delta > 0.0f)
						print(":D");
					else
						print(":|");
				}

				float valueBefore = m_crowdValue;
				m_crowdValue = min(100.0f, max(0.0f, m_crowdValue + delta));

				int showValue = int(round(m_crowdValue));
				if (m_crowdValue != valueBefore)
				{
					if (showValue == 0)
					{
						if (debugCrowd)
							print("boooooo");
					}
					else if (showValue == 100)
					{
						if (debugCrowd)
							print("yeeeeee");
					}
				}

				if (debugCrowd)
					print("Crowd update: " + m_crowdValue + " (added " + delta + ")");

				m_hudSurvival.OnValueChange(delta);

				UpdateCrowdSounds();

				(Network::Message("SurvivalCrowdValue") << float(m_crowdValue) << delta).SendToAll();

				WorldScript::TriggerGlobalEvent("crowd_update");
			}
		}
	}

	void RenderWidgets(PlayerRecord@ player, int idt, SpriteBatch& sb) override
	{
		if (GetVarBool("ui_hud_survival"))
			m_hudSurvival.Draw(sb, idt);

		Campaign::RenderWidgets(player, idt, sb);
	}

	void SetWave(WorldScript::SurvivalWave@ wave)
	{
		m_waveCount++;

		if (m_waveCount > m_waveBest)
			m_waveBest = m_waveCount;

		@m_currWave = SurvivalWaveProgress(wave);

		UpdateDiscordStatus();
	}
}
