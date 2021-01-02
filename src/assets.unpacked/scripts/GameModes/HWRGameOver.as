class HWRGameOver : GameOver
{
	HWRGameOver(GUIBuilder@ b)
	{
		super(b);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "restart" && Network::IsServer())
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm.m_dungeon !is null)
				g_startId = gm.m_dungeon.m_townSpawn;

			if (g_startId == "" && g_flags.IsSet("dlc_pop"))
				g_startId = "city_of_stone";

			ChangeLevel(GetTownLevelFilename());
		}
		else if (name == "exit")
		{
			PauseGame(false, false);
			StopScenario();
			return;
		}
		else if (name == "scoreclose")
			g_gameMode.ReplaceTopWidgetRoot(this);
		else
			GameOver::OnFunc(sender, name);
	}
}
