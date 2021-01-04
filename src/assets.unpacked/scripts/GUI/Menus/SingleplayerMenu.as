namespace Menu
{
	class SingleplayerMenu : Menu
	{
		SingleplayerMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			SetVar("g_start_sessions", 1);
		}

		WorldScript::MenuAnchorPoint@ GetAnchorPoint(string scenarioID, int levelIndex)
		{
			for (uint i = 0; i < g_menuAnchors.length(); i++)
			{
				if (!g_menuAnchors[i].GraphicsOptions && g_menuAnchors[i].LevelIndex == levelIndex && g_menuAnchors[i].ScenarioID == scenarioID)
					return g_menuAnchors[i];
			}

			return null;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");
			if (parse[0] == "start")
				cast<MainMenu>(g_gameMode).PlayGame(GetVarInt("g_start_sessions"));
			else
				Menu::OnFunc(sender, name);
		}
	}
}
