[GameMode]
class ShortcutLevel : Campaign
{
	ShortcutLevel(Scene@ scene)
	{
		super(scene);
	}
	
	// TODO: Delete this (USE_MULTIPLAYER)
	void Generate(SValue@ save) {}

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		Campaign::Start(peer, save, sMode);
		SetLevelFlags(m_levelCount);
		BaseGameMode::PostStart(); // Don't call Campaign::PostStart to avoid applying m_levelCount == 0 stuff

		if (sMode != StartMode::LoadGame)
			Stats::Add("floors-visited", 1, GetLocalPlayerRecord());

		auto record = GetLocalPlayerRecord();

		int nextLevelIndex = m_dungeon.GetNextActIndex(m_levelCount);
		auto level = m_dungeon.GetLevel(m_levelCount);
		auto nextLevel = m_dungeon.GetLevel(nextLevelIndex);

		DiscordPresence::Clear();
		DiscordPresence::SetState("In portal level");
		DiscordPresence::SetDetails(UcFirst(m_dungeon.GetActName(level, true), true) + " to " + UcFirst(m_dungeon.GetActName(nextLevel, true), true));
		DiscordPresence::SetStartTimestamp(time() - record.statisticsSession.GetStatInt("time-played"));
		DiscordPresence::SetLargeImageKey("portal");

		auto levelInfo = CalcLevel(m_levelCount);
		ServicePresence::Clear();
		if (g_ngp == 0)
			ServicePresence::Set("#Status_InPortalLevel");
		else
		{
			ServicePresence::Set("#Status_InPortalLevel_NGP");
			ServicePresence::Param("ngp", "" + g_ngp);
		}
		ServicePresence::Param("level", "" + record.level);
		ServicePresence::Param("act", "" + (levelInfo.x + 1));
		ServicePresence::Param("nextact", "" + (levelInfo.x + 2));
	}
}
