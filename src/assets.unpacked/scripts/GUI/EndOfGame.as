class EndOfGame : ScriptWidgetHost
{
	EndOfGame(SValue& sval)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		auto wButtonTown = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button-town"));
		if (wButtonTown !is null)
			wButtonTown.m_enabled = Network::IsServer();

		if (loaded)
			return;

		auto gm = cast<Campaign>(g_gameMode);
		gm.OnRunEnd(false);

		if (gm.m_hudSpeedrun !is null)
			gm.m_hudSpeedrun.End();

		if (gm.m_dungeon !is null)
			gm.m_dungeon.OnEndOfGame();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }

	void Stop() override
	{
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (name == "town")
		{
			if (gm.m_dungeon !is null)
				g_startId = gm.m_dungeon.m_townSpawn;
			ChangeLevel(GetTownLevelFilename());
		}
		else if (name == "stats")
			gm.ShowUserWindow(gm.m_playerMenu);
	}
}
