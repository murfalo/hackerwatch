enum LevelEndWorldFlags
{
	Flag1 = 1,
	Flag2 = 2,
	Flag3 = 4,
	Flag4 = 8,
	Flag5 = 16,
	Flag6 = 32,
	Flag7 = 64,
	Flag8 = 128,
	Flag9 = 256,
	Flag10 = 512,
	Flag11 = 1024,
	Flag12 = 2048,
	Flag13 = 4096,
	Flag14 = 8192
}

namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;192;288;32;32"]
	class LevelExit
	{
		[Editable default="levels/.lvl"]
		string Level;
		
		[Editable]
		string StartID;

		SValue@ ServerExecute()
		{
			Lobby::SetJoinable(false);
		
			g_startId = StartID;
			ChangeLevel(Level);
		
			return null;
		}
	}
}
