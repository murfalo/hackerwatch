interface IModScript
{
	void Run();
}

class ModLevelEntry
{
	bool m_isDungeon;

	string m_levelPath;

	string m_dungeonId;
	string m_startId;
	bool m_joinable;

	int m_dungeonStart;
}

class ModLevelsWindow : ScriptWidgetHost
{
	array<ModLevelEntry@> m_levelPaths;

	Widget@ m_wButtonList;
	Widget@ m_wButtonTemplate;
	Widget@ m_wHeaderTemplate;

	ModLevelsWindow(SValue& sval)
	{
		super();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	Widget@ AddHeader(string text)
	{
		auto wNewHeader = m_wHeaderTemplate.Clone();
		wNewHeader.SetID("");
		wNewHeader.m_visible = true;

		auto wHeaderText = cast<TextWidget>(wNewHeader.GetWidgetById("text"));
		if (wHeaderText !is null)
			wHeaderText.SetText(text);

		m_wButtonList.AddChild(wNewHeader);
		return wNewHeader;
	}

	ScalableSpriteButtonWidget@ AddButton(string text)
	{
		auto wNewButton = cast<ScalableSpriteButtonWidget>(m_wButtonTemplate.Clone());
		wNewButton.SetID("");
		wNewButton.m_visible = true;
		wNewButton.SetText(text);
		m_wButtonList.AddChild(wNewButton);
		return wNewButton;
	}

	void Initialize(bool loaded) override
	{
		@m_wButtonList = m_widget.GetWidgetById("button-list");
		@m_wButtonTemplate = m_widget.GetWidgetById("button-template");
		@m_wHeaderTemplate = m_widget.GetWidgetById("header-template");

		auto enabledMods = HwrSaves::GetEnabledMods();
		for (uint i = 0; i < enabledMods.length(); i++)
		{
			auto mod = enabledMods[i];
			auto sval = mod.Data;

			auto arrLevels = GetParamArray(UnitPtr(), sval, "levels", false);
			if (arrLevels !is null && arrLevels.length() > 0)
			{
				AddHeader(mod.Name + " (levels)"); //TODO: translate "levels"

				for (uint j = 0; j < arrLevels.length(); j++)
				{
					auto level = arrLevels[j];

					string levelName, levelDescription, levelPath, levelStartId;
					string dungeonId;
					int dungeonStart = -1;
					bool levelJoinable = false;

					if (level.GetType() == SValueType::Dictionary)
					{
						levelName = GetParamString(UnitPtr(), level, "name");
						levelDescription = GetParamString(UnitPtr(), level, "description", false);

						levelPath = GetParamString(UnitPtr(), level, "file", false);
						dungeonId = GetParamString(UnitPtr(), level, "dungeon", false);

						if (levelPath == "" && dungeonId == "")
						{
							PrintError("Levels need either a 'file' string (for single levels) or a 'dungeon' string (for dungeon rotations) for mod '" + mod.ID + "' at index " + j + ".");
							continue;
						}

						levelStartId = GetParamString(UnitPtr(), level, "startid", false);
						levelJoinable = GetParamBool(UnitPtr(), level, "joinable", false);

						if (dungeonId != "")
							dungeonStart = GetParamInt(UnitPtr(), level, "dungeon-start", false, -1);
					}
					else if (level.GetType() == SValueType::String)
						levelName = levelPath = level.GetString();
					else
					{
						PrintError("Unhandled svalue type in 'levels' array for mod '" + mod.ID + "' at index " + j + ". Expected: dict or string.");
						continue;
					}

					auto wNewLevel = AddButton(levelName);

					if (levelDescription != "")
						wNewLevel.m_tooltipText = levelDescription;
					wNewLevel.m_func = "load " + m_levelPaths.length();
					wNewLevel.m_enabled = Network::IsServer();

					auto newLevelEntry = ModLevelEntry();
					if (dungeonId != "")
					{
						newLevelEntry.m_isDungeon = true;
						newLevelEntry.m_dungeonId = dungeonId;
						newLevelEntry.m_dungeonStart = dungeonStart;
					}
					else
					{
						newLevelEntry.m_isDungeon = false;
						newLevelEntry.m_levelPath = levelPath;
					}
					newLevelEntry.m_startId = levelStartId;
					newLevelEntry.m_joinable = levelJoinable;
					m_levelPaths.insertLast(newLevelEntry);
				}
			}

			auto arrCustomClasses = GetParamArray(UnitPtr(), sval, "custom-character-classes", false);
			if (arrCustomClasses !is null && arrCustomClasses.length() > 0)
			{
				AddHeader(mod.Name + " (classes)"); //TODO: translate "classes"

				for (uint j = 0; j < arrCustomClasses.length(); j++)
				{
					auto svClass = arrCustomClasses[j];

					string classId, className, classDescription;

					if (svClass.GetType() == SValueType::Dictionary)
					{
						classId = GetParamString(UnitPtr(), svClass, "id");
						className = GetParamString(UnitPtr(), svClass, "name");
						classDescription = GetParamString(UnitPtr(), svClass, "description", false);
					}
					else if (svClass.GetType() == SValueType::String)
						classId = className = svClass.GetString();

					auto wNewClass = AddButton(className);
					if (classDescription != "")
						wNewClass.m_tooltipText = classDescription;
					wNewClass.m_func = "modclass " + classId;
				}
			}

			auto arrScripts = GetParamArray(UnitPtr(), sval, "run-scripts", false);
			if (arrScripts !is null && arrScripts.length() > 0)
			{
				AddHeader(mod.Name + " (scripts)"); // TODO: translate "scripts"

				for (uint j = 0; j < arrScripts.length(); j++)
				{
					auto svScript = arrScripts[j];

					string scriptClass, scriptName, scriptDescription;

					if (svScript.GetType() == SValueType::String)
						scriptClass = scriptName = svScript.GetString();
					else if (svScript.GetType() == SValueType::Dictionary)
					{
						scriptClass = GetParamString(UnitPtr(), svScript, "class");
						scriptName = GetParamString(UnitPtr(), svScript, "name", false, scriptClass);
						scriptDescription = GetParamString(UnitPtr(), svScript, "description", false);
					}

					auto wNewScript = AddButton(scriptName);
					if (scriptDescription != "")
						wNewScript.m_tooltipText = scriptDescription;
					wNewScript.m_func = "modscript " + scriptClass;
				}
			}
		}
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "close")
			Stop();
		else if (parse[0] == "load" && parse.length() == 2 && Network::IsServer())
		{
			uint num = parseUInt(parse[1]);
			if (num >= m_levelPaths.length())
				return;

			auto levelEntry = m_levelPaths[num];

			if (levelEntry.m_isDungeon)
			{
				auto gm = cast<Campaign>(g_gameMode);
				if (gm is null)
				{
					PrintError("Gamemode is not of type Campaign!");
					return;
				}

				@gm.m_dungeon = DungeonProperties::Get(levelEntry.m_dungeonId);
				if (gm.m_dungeon is null)
				{
					PrintError("Unable to find dungeon properties with ID \"" + levelEntry.m_dungeonId + "\"!");
					return;
				}

				int startLevelIndex = gm.m_levelCount;
				if (levelEntry.m_dungeonStart != -1)
					startLevelIndex = levelEntry.m_dungeonStart;

				auto startLevel = gm.m_dungeon.GetLevel(startLevelIndex);

				Lobby::SetJoinable(levelEntry.m_joinable);
				ChangeLevel(startLevel.m_filename);
			}
			else
			{
				Lobby::SetJoinable(levelEntry.m_joinable);
				g_startId = levelEntry.m_startId;
				ChangeLevel(levelEntry.m_levelPath);
			}
		}
		else if (parse[0] == "modclass" && parse.length() == 2)
		{
			auto record = GetLocalPlayerRecord();
			auto player = cast<Player>(record.actor);
			if (player is null)
				return;

			int preRenderableIndex = m_preRenderables.findByRef(player);
			if (preRenderableIndex != -1)
				m_preRenderables.removeAt(preRenderableIndex);

			player.DisableModifiers();

			record.charClass = parse[1];
			player.Initialize(record);

			(Network::Message("PlayerChangeClass") << parse[1]).SendToAll();

			Stop();
		}
		else if (parse[0] == "modscript" && parse.length() == 2)
		{
			print("Running mod script \"" + parse[1] + "\"");

			SValueBuilder builder;
			builder.PushNull();

			auto modScript = cast<IModScript>(InstantiateClass(parse[1], builder.Build()));
			if (modScript is null)
			{
				PrintError("Unable to instnatiate class \"" + parse[1] + "\". Does it implement IModScript?");
				return;
			}

			modScript.Run();
		}
	}
}
