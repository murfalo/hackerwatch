namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;192;288;32;32"]
	class LevelExitNext
	{
		[Editable]
		string StartID;
	
		SValue@ ServerExecute()
		{
			Lobby::SetJoinable(false);
			
			g_startId = StartID;

			auto gm = cast<Campaign>(g_gameMode);
			gm.m_levelCount++;
			gm.m_minimap.Clear();

			if (gm.m_dungeon is null)
			{
				PrintError("There is no dungeon rotation set! Set one with the StartDungeon worldscript when starting a run.");
				return null;
			}

			auto nextLevel = gm.m_dungeon.GetLevel(gm.m_levelCount);
			if (nextLevel is null)
			{
				PrintError("There is no available next level in the dungeon rotation!");
				return null;
			}

			if (nextLevel.m_startId != "")
				g_startId = nextLevel.m_startId;

			ChangeLevel(nextLevel.m_filename);
			return null;
		}
	}
}
