namespace WorldScript
{
	[WorldScript color="100 255 255" icon="system/icons.png;192;288;32;32"]
	class StartDungeon
	{
		[Editable default="base"]
		string Dungeon;

		SValue@ ServerExecute()
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm is null)
			{
				PrintError("Gamemode is not of type Campaign!");
				return null;
			}

			@gm.m_dungeon = DungeonProperties::Get(Dungeon);
			if (gm.m_dungeon is null)
			{
				PrintError("Unable to find dungeon properties with ID \"" + Dungeon + "\"!");
				return null;
			}

%if HARDCORE
			g_ngp = 0;
			for (uint i = 0; i < g_players.length(); i++)
			{
				auto player = g_players[i];
				if (player.peer == 255)
					continue;

				int playerNgp = player.ngps.GetHighest();//[gm.m_dungeon.m_idHash];
				if (float(playerNgp) > g_ngp)
					g_ngp = playerNgp;
			}
%else
			int highestNgp = gm.m_townLocal.m_highestNgps.GetHighest();

			if (g_ngp < 0)
				g_ngp = 0;
			else if (g_ngp > highestNgp)
				g_ngp = highestNgp;
%endif

			Lobby::SetJoinable(false);

			auto firstLevel = gm.m_dungeon.GetLevel(gm.m_levelCount);

			if (firstLevel.m_startId != "")
				g_startId = firstLevel.m_startId;

			for (uint i = 0; i < gm.m_dungeon.m_flags.length(); i++)
				g_flags.Set(gm.m_dungeon.m_flags[i], FlagState::Run);

			ChangeLevel(firstLevel.m_filename);
			return null;
		}
	}
}
