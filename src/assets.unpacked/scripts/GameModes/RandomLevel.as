[GameMode]
class RandomLevel : Campaign
{
	EnemyPlacement@ m_enemyPlacer;

	RandomLevel(Scene@ scene)
	{
		super(scene);
	}
	
	void Generate(SValue@ save)
	{
		LoadDungeonProperties(save);

		int shortcut = 0;
		int numPlrs = 1;
		if (save !is null)
		{
			m_levelCount = GetParamInt(UnitPtr(), save, "level-count", false, GetVarInt("g_start_level"));
			shortcut = GetParamInt(UnitPtr(), save, "shortcut", false, 0);
			numPlrs = GetParamInt(UnitPtr(), save, "num-plrs", false, 1);

%if !HARDCORE
			if (GetParamBool(UnitPtr(), save, "soul-linked", false, false))
				g_flags.Set("allow_graveyard", FlagState::Level);
%endif

			g_ngp = GetParamInt(UnitPtr(), save, "ngp", false, 0);
			g_downscaling = GetParamBool(UnitPtr(), save, "downscaling", false, false);

			auto arrFountain = GetParamArray(UnitPtr(), save, "fountain", false);
			if (arrFountain !is null)
			{
				for (uint i = 0; i < arrFountain.length(); i++)
					Fountain::ApplyEffect(arrFountain[i].GetInteger());
			}
		}
		else
			m_levelCount = GetVarInt("g_start_level");
		
		auto townSave = HwrSaves::LoadHostTown();
		auto arrFlags = GetParamArray(UnitPtr(), townSave, "flags", false);
		if (arrFlags !is null)
		{
			for (uint i = 0; i < arrFlags.length(); i++)
				g_flags.Set(arrFlags[i].GetString(), FlagState::Town);
		}
		
		print("NewGame+ " +g_ngp);
		print("Downscaling: " + g_downscaling);
		GenerateDungeon(this, m_levelCount, shortcut, numPlrs);
	}
	
	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		if (sMode != StartMode::LoadGame)
			m_useSpawnLogic = false;
	
		Campaign::Start(peer, save, sMode);

		for (uint i = 0; i < g_prefabsToSpawn.length(); i++)
			g_prefabsToSpawn[i].Fabricate();
		
		g_prefabsToSpawn.removeRange(0, g_prefabsToSpawn.length());

		RandomLevel::PostStart();

		auto record = GetLocalPlayerRecord();

		if (sMode != StartMode::LoadGame)
			Stats::Add("floors-visited", 1, record);

		DungeonLevelRichPresence(this);
	}

	void PostStart() override
	{
		Campaign::PostStart();

		auto record = GetLocalPlayerRecord();

		if (m_levelCount == 0 && m_startMode != StartMode::LoadGame && Network::IsServer())
		{
			if (Fountain::HasEffect("ace_key"))
				record.keys[3]++;

			/*
			auto player = GetLocalPlayer();
			if (Fountain::HasEffect("rare_item") && player !is null)
				player.AddItem(g_items.TakeRandomItem(ActorItemQuality::Rare));
			*/
		}
	}
}

void DungeonLevelRichPresence(Campaign@ gm)
{
	auto record = GetLocalPlayerRecord();
	auto level = gm.m_dungeon.GetLevel(gm.m_levelCount);

	DiscordPresence::Clear();

	if (gm.m_dungeon.m_discordState != "")
		DiscordPresence::SetState(gm.m_dungeon.m_discordState);
	else
		DiscordPresence::SetState("In dungeon");

	DiscordPresence::SetDetails("Act " + (level.m_act + 1) + " floor " + (level.m_level + 1));
	if (g_ngp > 0)
		DiscordPresence::AddDetails(", NG+" + g_ngp);
	DiscordPresence::SetStartTimestamp(time() - record.statisticsSession.GetStatInt("time-played"));
	DiscordPresence::SetLargeImageKey(gm.m_dungeon.GetDiscordActImage(level));
	DiscordPresence::SetLargeImageText(UcFirst(gm.m_dungeon.GetActName(level, true), true));

	ServicePresence::Clear();
	if (g_ngp == 0)
		ServicePresence::Set("#Status_InDungeon");
	else
	{
		ServicePresence::Set("#Status_InDungeon_NGP");
		ServicePresence::Param("ngp", "" + g_ngp);
	}
	ServicePresence::Param("level", "" + record.level);
	ServicePresence::Param("act", gm.m_dungeon.m_statusPrefix + (level.m_act + 1));
	ServicePresence::Param("floor", "" + (level.m_level + 1));
}
