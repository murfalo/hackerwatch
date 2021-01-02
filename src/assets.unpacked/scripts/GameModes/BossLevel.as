[GameMode]
class BossLevel : Campaign
{
	[Editable]
	string LevelName;

	[Editable]
	string LevelNameShort;

	BossLevel(Scene@ scene)
	{
		super(scene);
	}

	// TODO: Delete this (USE_MULTIPLAYER)
	void Generate(SValue@ save) {}

	string GetLevelName(bool short = false) override
	{
		if (!short && LevelName != "")
			return Resources::GetString(LevelName);
		else if (short && LevelNameShort != "")
			return Resources::GetString(LevelNameShort);
		return Campaign::GetLevelName(short);
	}

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		Campaign::Start(peer, save, sMode);
		SetLevelFlags(m_levelCount);
		Campaign::PostStart();

		if (sMode != StartMode::LoadGame)
			Stats::Add("floors-visited", 1, GetLocalPlayerRecord());
		
		if (sMode == StartMode::Continue)
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255)
					continue;

				if (g_players[i].hp > 0)
				{
					g_players[i].hp = 1;
					g_players[i].mana = 1;
				}
			}
		}

		auto record = GetLocalPlayerRecord();
		auto level = m_dungeon.GetLevel(m_levelCount);

		DiscordPresence::Clear();
		DiscordPresence::SetState("In boss battle");
		DiscordPresence::SetDetails("Act " + (level.m_act + 1) + " floor " + (level.m_level + 1));
		if (g_ngp > 0)
			DiscordPresence::AddDetails(", NG+" + g_ngp);
		DiscordPresence::SetStartTimestamp(time() - record.statisticsSession.GetStatInt("time-played"));
		DiscordPresence::SetLargeImageKey(m_dungeon.m_statusPrefix + "boss_" + level.m_act);
		DiscordPresence::SetLargeImageText(UcFirst(m_dungeon.GetActName(level, true), true));

		Platform::Service.ClearRichPresence();
		if (g_ngp == 0)
			Platform::Service.SetRichPresence("#Status_InBossBattle");
		else
		{
			Platform::Service.SetRichPresence("#Status_InBossBattle_NGP");
			Platform::Service.SetRichPresenceKey("ngp", "" + g_ngp);
		}
		Platform::Service.SetRichPresenceKey("level", "" + record.level);
		Platform::Service.SetRichPresenceKey("act", m_dungeon.m_statusPrefix + (level.m_act + 1));
	}
}
