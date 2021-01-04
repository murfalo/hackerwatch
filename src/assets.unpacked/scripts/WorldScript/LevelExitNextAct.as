namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;192;288;32;32"]
	class LevelExitNextAct
	{
		[Editable]
		string StartID;
		
		SValue@ ServerExecute()
		{
			Lobby::SetJoinable(false);
			
			g_startId = StartID;

			auto gm = cast<BaseGameMode>(g_gameMode);

			if (gm.m_dungeon is null)
			{
				PrintError("There is no dungeon rotation set! Set one with the StartDungeon worldscript when starting a run.");
				return null;
			}

			int newIndex = gm.m_dungeon.GetNextActIndex(gm.m_levelCount);

			auto nextLevel = gm.m_dungeon.GetLevel(newIndex);
			if (nextLevel is null)
			{
				PrintError("There is no available next act in the dungeon rotation!");
				return null;
			}

			gm.m_levelCount = newIndex;

			if (nextLevel.m_startId != "")
				g_startId = nextLevel.m_startId;

			ChangeLevel(nextLevel.m_filename);
			return null;
		}
	}
}
