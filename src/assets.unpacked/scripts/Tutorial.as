namespace Tutorial
{
	TextWidget@ m_wTutorial;


	void Initialize()
	{
		AddVar("ui_show_tutorial_attack1", 4);
		AddVar("ui_show_tutorial_attack2", 3);
		AddVar("ui_show_tutorial_map_overlay", 1);
		AddVar("ui_show_tutorial_player_menu", 1);
		AddVar("ui_show_tutorial_guild_menu", 1);
		AddVar("ui_show_tutorial_use", 2);
		AddVar("ui_show_tutorial_potion", 0); // 1
	}
	
	void AssignHUD(TextWidget@ text)
	{
		@m_wTutorial = text;
		m_wTutorial.m_visible = true;
	}

	void RegisterAction(string action)
	{
		if (!m_wTutorial.m_visible)
			return;

		int val = GetVarInt("ui_show_tutorial_" + action);
		if (val <= 0)
			return;
		
		SetVar("ui_show_tutorial_" + action, --val);
		Config::SaveVar("ui_show_tutorial_" + action, "" + val);
	}
	
	void Update(int dt)
	{
		if (!m_wTutorial.m_visible)
			return;

		string tutText = "";
		
		auto map = GetControlBindings().GetMap("kbm");
		if (map !is null)
		{
			int n = 0;
			auto record = GetLocalPlayerRecord();
			auto bindings = map.GetBindings();
			auto player = cast<PlayerBase>(record.actor);
			if (player !is null && player.m_skills !is null && player.m_skills.length() > 1)
			{
				tutText += MakeTutorialString("attack1", bindings, "Attack1", player.m_skills[0].m_name);
				tutText += MakeTutorialString("attack2", bindings, "Attack2", player.m_skills[1].m_name);
			}

			tutText += MakeTutorialString("map_overlay", bindings, "MapOverlay", ".menu.controls.mapoverlay");
			tutText += MakeTutorialString("player_menu", bindings, "PlayerMenu", ".menu.controls.playermenu");
			tutText += MakeTutorialString("guild_menu", bindings, "GuildMenu", ".menu.controls.guildmenu");
			tutText += MakeTutorialString("use", bindings, "Use", ".menu.controls.use");
			tutText += MakeTutorialString("potion", bindings, "Potion", ".menu.controls.potion");
			
			if (tutText.length() <= 0)
				m_wTutorial.m_visible = false;
			else
				m_wTutorial.SetText(tutText);
		}
	}
	
	string MakeTutorialString(string id, array<ControlMapBinding@>@ bindings, string action, string name)
	{
		int n = GetVarInt("ui_show_tutorial_" + id);
		if (n <= 0)
			return "";
		
		string post;
		if (n == 1)
			post = "\n";
		else if (n == 2)
			post = ".\n";
		else if (n == 3)
			post = "..\n";
		else
			post = "...\n";
			
		return "[" + GetMappedKey(bindings, action) + "] " + utf8string(Resources::GetString(name)).toUpper().plain() + post;
	}
	
	string GetMappedKey(array<ControlMapBinding@>@ bindings, string action)
	{
		for (uint i = 0; i < bindings.length(); i++)
		{
			if (bindings[i].Action == action)
			{
				string keyID = bindings[i].ID.toUpper();
				keyID = keyID.replace("_", " ");
				return keyID;
			}
		}

		return Resources::GetString("  ");
	}
}