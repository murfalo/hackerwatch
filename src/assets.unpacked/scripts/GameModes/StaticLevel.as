[GameMode]
class StaticLevel : Campaign
{
	[Editable]
	string LevelName;

	[Editable]
	string LevelNameShort;

	[Editable]
	bool RevivePlayersOnSpawn;

	[Editable]
	string DiscordImage;

	EnemyPlacement@ m_enemyPlacer;

	StaticLevel(Scene@ scene)
	{
		super(scene);
	}
	
	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		Campaign::Start(peer, save, sMode);
		SetLevelFlags(m_levelCount);
		Campaign::PostStart();

		int numPlrs = 1;
		if (save !is null)
			numPlrs = GetParamInt(UnitPtr(), save, "num-plrs", false, 1);
			
		DungeonGenerator@ dgn = MakeDungeonGenerator(m_levelCount, numPlrs);
		if (dgn !is null)
			@m_enemyPlacer = dgn.m_enemyPlacer;
		else
			print("Null dungeon");

		auto record = GetLocalPlayerRecord();

		if (sMode != StartMode::LoadGame)
			Stats::Add("floors-visited", 1, record);

		DungeonLevelRichPresence(this);
		if (DiscordImage != "")
			DiscordPresence::SetLargeImageKey(DiscordImage);
	}

	bool ShouldRevivePlayerOnSpawn(PlayerRecord@ record) override
	{
		return RevivePlayersOnSpawn;
	}

	string GetLevelName(bool short = false) override
	{
		if (!short && LevelName != "")
			return Resources::GetString(LevelName);
		else if (short && LevelNameShort != "")
			return Resources::GetString(LevelNameShort);
		return Campaign::GetLevelName(short);
	}
}
