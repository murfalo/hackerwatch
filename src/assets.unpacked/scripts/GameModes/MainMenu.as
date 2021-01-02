array<WorldScript::MenuAnchorPoint@> g_menuAnchors;

[GameMode default]
class MainMenu : BaseGameMode
{
	MenuControlInputWidget@ m_expectingInput;

	MenuProvider@ m_mainMenu;
	MenuProvider@ m_ingameMenu;
	Menu::InGameChat@ m_ingameChat;
	Menu::InGameNotifier@ m_ingameNotifier;

	GameChatWidget@ m_wChat;

	MenuProvider@ m_gameMenu;
	MenuState m_state;

	SoundInstance@ m_musicInstance;

	bool m_testLevel;
	bool m_hostPrivate;
	string m_hostName;
	pint m_hostMaxPlayers;
	pint m_hostMaxLevel;
	pint m_hostMinLevel;
	pint m_hostNgp;
	bool m_hostDownscaling;
	bool m_hostAllowModded;

	uint64 m_inviteAcceptID;
	int m_inviteAcceptMaxLevel;
	int m_inviteAcceptMinLevel;
	bool m_inviteAcceptMercenary;

	int m_frameCount;
	bool m_lostConnection;
	int m_joinFailed = -1;

	TownRecord@ m_town;

	Menu::JoiningLobbyMenu@ m_joiningMenu;

	SValue@ m_menuStyle;

	MainMenu(Scene@ scene)
	{
		super(scene);

		if (!VarExists("g_menustyle"))
			AddVar("g_menustyle", "");

		if (!VarExists("g_intro_logos"))
			AddVar("g_intro_logos", true);
		if (!VarExists("g_intro_logos_shown"))
			AddVar("g_intro_logos_shown", false);
		if (!VarExists("g_debug_menu"))
			AddVar("g_debug_menu", false);
		if (!VarExists("g_multi_test"))
			AddVar("g_multi_test", false, null, 0);

		if (!VarExists("ui_show_chat"))
			AddVar("ui_show_chat", true);

		AddFunction("lobby_say", { cvar_type::String }, LobbySayCfunc);

		@m_mainMenu = MenuProvider();
		@m_ingameMenu = MenuProvider();

		@m_ingameNotifier = Menu::InGameNotifier();
		m_ingameNotifier.Initialize(m_guiBuilder, "gui/ingame_menu/notifier.gui");

		WidgetProducers::LoadMainMenu(m_guiBuilder);
		LoadMenu();

		if (Platform::GetSessionCount() == 0)
		{
			auto cb = GetControlBindings();
			GetControlBindings().AssignControls(1);
		}

		InstantiateMice();
	}

	void SetMenuStyle(string style)
	{
		auto svStyles = Resources::GetSValue("tweak/menustyles.sval");
		auto svdicStyles = GetParamDictionary(UnitPtr(), svStyles, "styles");

		if (style == "")
		{
			auto arrAuto = GetParamArray(UnitPtr(), svStyles, "auto");
			for (uint i = 0; i < arrAuto.length(); i++)
			{
				string id = arrAuto[i].GetString();
				auto svStyle = svdicStyles.GetDictionaryEntry(id);

				string dlc = GetParamString(UnitPtr(), svStyle, "dlc", false);
				if (dlc == "" || Platform::HasDLC(dlc))
				{
					style = id;
					break;
				}
			}
		}
		else if (style == "?")
		{
			auto arrKeys = svdicStyles.GetDictionary().getKeys();
			for (int i = int(arrKeys.length() - 1); i >= 0; i--)
			{
				auto svStyle = svdicStyles.GetDictionaryEntry(arrKeys[i]);
				string dlc = GetParamString(UnitPtr(), svStyle, "dlc", false);
				if (dlc != "" && !Platform::HasDLC(dlc))
					arrKeys.removeAt(i);
			}

			int randomIndex = randi(arrKeys.length());
			style = arrKeys[randomIndex];
		}

		@m_menuStyle = svdicStyles.GetDictionaryEntry(style);
		if (m_menuStyle is null)
		{
			PrintError("Menu style \"" + style + "\" doesn't exist! Falling back to default.");
			style = "default";
			@m_menuStyle = svdicStyles.GetDictionaryEntry("default");
		}

		string dlc = GetParamString(UnitPtr(), m_menuStyle, "dlc", false);
		if (dlc != "" && !Platform::HasDLC(dlc))
		{
			SetMenuStyle("default");
			return;
		}

		m_mainMenu.SetStyle(m_guiBuilder, m_menuStyle);
		m_ingameMenu.SetStyle(m_guiBuilder, m_menuStyle);

		if (m_musicInstance !is null)
		{
			m_musicInstance.Stop();
			@m_musicInstance = null;

			UpdateMusic();
		}
	}

	void InstantiateMice()
	{
		m_mice.removeRange(0, m_mice.length());
		int numInputs = Platform::GetInputCount();
		for (int i = 0; i < numInputs; i++) {
			GameInput@ gi = Platform::GetGameInput(i);
			MenuInput@ mi = Platform::GetMenuInput(i);
			m_mice.insertLast(MenuMouse(gi, mi, numInputs > 1));
		}
	}

	Menu::ServerlistMenu@ GetServerlistMenu()
	{
		for (uint i = 0; i < m_gameMenu.m_menus.length(); i++)
		{
			auto menu = cast<Menu::ServerlistMenu>(m_gameMenu.m_menus[i]);
			if (menu !is null)
				return menu;
		}
		return null;
	}

	void ShowMessage(MenuMessage message)
	{
		if (message == MenuMessage::Saved)
			m_ingameNotifier.ShowSaved(2000);
		else if (message == MenuMessage::LostConnection)
			m_lostConnection = true;
	}

	void LoadMenu()
	{
		@m_gameMenu = m_mainMenu;

		SetMenuStyle(GetVarString("g_menustyle"));

		if (GetVarBool("g_debug_menu"))
			m_mainMenu.Initialize(m_guiBuilder, Menu::TestMenu(m_mainMenu), "gui/test.gui");
		else
		{
			if (GetVarBool("g_intro_logos") && !GetVarBool("g_intro_logos_shown"))
				m_mainMenu.Initialize(m_guiBuilder, Menu::IntroMenu(m_mainMenu), "gui/main_menu/intro.gui");
			else
				m_mainMenu.Initialize(m_guiBuilder, Menu::FrontMenu(m_mainMenu), "gui/main_menu/main.gui");
		}

		Menu::Backdrop@ ingameBackdrop = Menu::Backdrop(m_guiBuilder, "gui/ingame_menu/backdrop.gui");
		@m_gameMenu = m_ingameMenu;
		m_ingameMenu.Initialize(m_guiBuilder, Menu::FrontMenu(m_ingameMenu), "gui/ingame_menu/main.gui", ingameBackdrop);

		@m_ingameChat = Menu::InGameChat();
		m_ingameChat.Initialize(m_guiBuilder, "gui/ingame_menu/chat.gui");

		g_gameMode.ClearWidgetRoot();
	}

	void Start(uint8 peer, SValue@ save, StartMode sMode) override
	{
		@m_town = TownRecord();
		m_town.Load(HwrSaves::LoadLocalTown());

		m_hostNgp = m_town.m_currentNgp;

		CenterMousePos();
	}

	void SpawnPlayers() override
	{
	}

	bool ShouldDisplayCursor() override
	{
		return (m_state != MenuState::Hidden) || (m_dialogWindow !is null);
	}

	void ResizeWindow(int w, int h, float scale) override
	{
		BaseGameMode::ResizeWindow(w, h, scale);

		if (m_gameMenu !is null)
		{
			for (uint i = 0; i < m_gameMenu.m_menus.length(); i++)
				m_gameMenu.m_menus[i].Invalidate();
		}
	}

	void SetMenuState(MenuState state)
	{
		m_ingameChat.StopInput();

		g_gameMode.ClearWidgetRoot();

		m_state = state;

		if (m_state == MenuState::InGameMenu)
			@m_gameMenu = m_ingameMenu;
		else if (m_state == MenuState::MainMenu)
		{
			@m_gameMenu = m_mainMenu;

			DiscordPresence::Clear();
			DiscordPresence::SetState("In main menu");

			ServicePresence::Clear();
			ServicePresence::Set("#Status_InMainMenu");
		}
		else if (m_state == MenuState::Hidden)
		{
			if (m_musicInstance !is null && m_musicInstance.IsPlaying())
				m_musicInstance.Stop();
			return;
		}

		g_gameMode.AddWidgetRoot(m_gameMenu.GetCurrentMenu());
		m_gameMenu.GetCurrentMenu().SetActive();

		UpdateMusic();
	}

	void UpdateMusic()
	{
		if (m_state == MenuState::MainMenu)
		{
			if (m_musicInstance is null)
			{
				string musicPath = GetParamString(UnitPtr(), m_menuStyle, "music", false);
				SoundEvent@ music = Resources::GetSoundEvent(musicPath);

				if (music !is null)
				{
					@m_musicInstance = music.PlayTracked();
					m_musicInstance.SetLooped(true);
					m_musicInstance.SetPaused(false);
				}
			}
		}
		else if (m_musicInstance !is null)
		{
			m_musicInstance.Stop();
			@m_musicInstance = null;
		}
	}

	bool MenuBack() override
	{
		if (m_state == MenuState::Hidden)
			return false;

		if (!BaseGameMode::MenuBack())
		{
			if (m_gameMenu is m_ingameMenu)
				return m_gameMenu.GoBack();
			else
				m_gameMenu.GoBack();
		}

		return true;
	}

	void UpdateFrame(int ms, GameInput& gameInput, MenuInput& menuInput) override
	{
		BaseGameMode::UpdateFrame(ms, gameInput, menuInput);

		Platform::Service.InMenus(true);

		if (m_state == MenuState::Hidden)
		{
			m_ingameNotifier.Update(ms);
			m_ingameChat.Update(ms, menuInput);
			return;
		}
		
%PROFILE_START GameMenu Update
		m_gameMenu.Update(ms, gameInput, menuInput);
%PROFILE_STOP

		if (m_lostConnection)
		{
			m_lostConnection = false;
			ShowDialog("connectionlost", Resources::GetString(".menu.notifier.lostconnection"), Resources::GetString(".menu.ok"), m_gameMenu.GetCurrentMenu());
		}

		if (m_joinFailed != -1)
		{
			string prompt = "join";
			if (m_joinFailed == 1)
				prompt = "host";
			ShowDialog("joinfailed", Resources::GetString(".menu.notifier.joinfailed." + prompt), Resources::GetString(".menu.ok"), m_gameMenu.GetCurrentMenu());
			m_joinFailed = -1;
		}

		m_frameCount++;

		if (m_state == MenuState::MainMenu)
		{
			DiscordPresence::Update(ms);
			ServicePresence::Update(ms);
		}
	}

	vec2 GetCameraPos(int idt) override
	{
		float scalar = (m_frameCount + idt / 33.0f);
		vec2 camOffset = vec2(sin(scalar / 40.0f) * 8.0f, cos(scalar / 60.0f) * 4.0f);
		return m_camPos + camOffset;
	}
	
	void PreRenderFrame(int idt) override
	{
	}
	
	void RenderFrame(int idt, SpriteBatch& sb) override
	{
		sb.PushTransformation(mat::scale(mat4(), GetUIScale()));
	
		int w = g_gameMode.m_wndWidth;
		int h = g_gameMode.m_wndHeight;

		if (m_state == MenuState::Hidden)
		{
			if (GetVarBool("ui_show_chat"))
				m_ingameChat.Draw(sb, idt);
			m_ingameNotifier.Draw(sb, idt);

			if (m_dialogWindow !is null && m_dialogWindow.m_visible)
			{
				m_dialogWindow.Draw(sb, idt);
				DrawMouse(idt, sb);
			}
			
			sb.PopTransformation();
			return;
		}

		m_gameMenu.Render(idt, sb);

		RenderWidgets(null, idt, sb);

		if (m_gameMenu.GetCurrentMenu().ShouldDisplayCursor())
			DrawMouse(idt, sb);
			
		sb.PopTransformation();
	}
	
	void RenderFrameLoading(int idt, SpriteBatch& sb)
	{
		BitmapFont@ loadFont = Resources::GetBitmapFont("gui/fonts/code2003_20_bold.fnt");
		if (loadFont is null)
			return;
		
		auto loadText = loadFont.BuildText(Resources::GetString(".menu.loading"), -1, TextAlignment::Center);
	
		sb.Begin(m_wndWidth, m_wndHeight, m_wndScale);
		sb.DrawSprite(null, vec4(-5, -5, m_wndWidth + 10, m_wndHeight + 10), vec4(), vec4(0, 0, 0, 1));
		sb.DrawString(vec2((m_wndWidth - loadText.GetWidth()) / 2, (m_wndHeight - loadText.GetHeight()) / 2), loadText);
		
		auto loadStates = Lobby::GetPlayerLoadStates();
		if (loadStates !is null)
		{
			BitmapFont@ plrFont = Resources::GetBitmapFont("gui/fonts/arial11.fnt");
			if (plrFont is null)
				return;
		
			for (uint i = 0; i < loadStates.length(); i++)
			{
				auto name = Lobby::GetPlayerName(loadStates[i].Peer);
				
				string text;
				
				switch(loadStates[i].Progress)
				{
				case 0:
					text = "\\c000000...\\d " + name;
					break;
				case 1:
					text = ".\\c000000..\\d " + name;
					break;
				case 2:
					text = "..\\c000000.\\d " + name;
					break;
				case 3:
					text = "... " + name;
					break;
				}
				
				auto plrText = plrFont.BuildText(text, -1, TextAlignment::Left);
				sb.DrawString(vec2(4, 2 + i * plrText.GetHeight()), plrText);
			}		
		}
		
		sb.End();
	}
	
	void ChatMessage(uint8 peer, string msg)
	{
		if (Lobby::IsPlayerLocal(peer))
			return;

		if (m_wChat !is null)
			m_wChat.PlayerChat(peer, msg);
	}

	void LobbyDataUpdate()
	{
		//NOTE: Steam seems to trigger a data update for the lobby right after it triggers
		//      a data update for a lobby member. Not sure why, but this means that you should
		//      be careful when setting lobby member data in this callback, as it could result
		//      in never-ending events. (I suppose the same counts for regular lobby data too)
	}

	void LobbyMemberDataUpdate(uint8 peer)
	{
		//NOTE: See note above in LobbyDataUpdate.
	}

	void HandleChatMessage(uint8 peer, string message)
	{
		if (message.length() >= 1 && message.length() <= 2)
		{
			if (!GetVarBool("ui_chat_dialog"))
				return;

			auto charData = HwrSaves::LoadCharacter(peer);
			if (charData is null)
			{
				PrintError("Couldn't get character data for peer " + peer);
				return;
			}

			string voiceID = GetParamString(UnitPtr(), charData, "voice-id", false);
			auto voice = Voices::GetVoice(voiceID);
			if (voice is null)
			{
				PrintError("Couldn't find voice with ID \"" + voiceID + "\"");
				return;
			}

			if (message == "0")
			{
				if (voice.m_soundChatLines.length() > 0)
				{
					int randomIndex = randi(voice.m_soundChatLines.length());
					PlaySound2D(voice.m_soundChatLines[randomIndex]);
				}
				return;
			}

			int num = parseInt(message);
			if (num >= 1 && num <= int(voice.m_soundChatLines.length()))
				PlaySound2D(voice.m_soundChatLines[num - 1]);
		}
	}

	void LobbyCreated(bool loadingSave)
	{
		print("LobbyCreated()");

		UpdateLobbyMemberData();

		if (m_testLevel)
		{
			m_hostMaxLevel = -1;
			m_hostPrivate = true;
			m_hostMaxPlayers = 16;
			m_hostAllowModded = true;
		}

		Lobby::SetPrivate(m_hostPrivate);
		Lobby::SetLobbyData("name", m_hostName);
		Lobby::SetPlayerLimit(m_hostMaxPlayers);
		Lobby::SetLobbyData("max-level", int(m_hostMaxLevel));
		Lobby::SetLobbyData("min-level", int(m_hostMinLevel));
		Lobby::SetLobbyData("downscaling", m_hostDownscaling ? "true" : "false");

		if (HwrSaves::IsModded())
			Lobby::SetLobbyData("allow-modded", "true");
		else
			Lobby::SetLobbyData("allow-modded", m_hostAllowModded ? "true" : "false");

		auto enabledMods = HwrSaves::GetEnabledMods();
		Lobby::SetLobbyData("mods-count", enabledMods.length());

		string modsInfo = "";
		for (uint i = 0; i < enabledMods.length(); i++)
			modsInfo += enabledMods[i].ID + ":" + enabledMods[i].Name + "\n";
		if (modsInfo.length() > 4095) // GOG lobbies have a 4095 byte limit but let's not go crazy here
			modsInfo = modsInfo.substr(0, 4095);
		Lobby::SetLobbyData("mods", strTrim(modsInfo));

		string dlcs = "";
		if (Platform::HasDLC("pop"))
			dlcs += "pop,";
		if (Platform::HasDLC("wh"))
			dlcs += "wh,";
		if (Platform::HasDLC("mt"))
			dlcs += "mt,";
		Lobby::SetLobbyData("dlcs", strTrim(dlcs, ","));

		auto charData = HwrSaves::LoadCharacter();
		bool mercenary = GetParamBool(UnitPtr(), charData, "mercenary", false);
		if (mercenary && Platform::HasDLC("mt"))
			Lobby::SetLobbyData("mercenary", "true");

		GlobalCache::Set("start_host_ngp", "" + m_hostNgp);
		GlobalCache::Set("start_host_downscaling", m_hostDownscaling ? "true" : "false");

		if (m_testLevel)
			Lobby::SetLevel("levels/test/mt_test.lvl");
		else
			Lobby::SetLevel(GetTownLevelFilename());
		Lobby::StartGame();
		//Lobby::SetJoinable(true);
	}

	void JoiningLobby()
	{
		@m_joiningMenu = Menu::JoiningLobbyMenu(m_gameMenu);
		m_gameMenu.GetCurrentMenu().OpenMenu(m_joiningMenu, "gui/main_menu/joininglobby.gui");
	}

	void LobbyInviteAccepted(uint64 id)
	{
		print("Invite accepted to join \"" + Lobby::GetLobbyData(id, "name") + "\"");

		if (!Platform::Service.IsMultiplayerAvailable())
		{
			print("Can't join because multiplayer is not available");
			//TODO: Give different error if using unpacked mods
			ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.join"), Resources::GetString(".menu.ok"), null);
			return;
		}

		string strAllowModded = Lobby::GetLobbyData(id, "allow-modded");
		if (strAllowModded != "true" && HwrSaves::IsModded())
		{
			print("Can't join because host doesn't allow modded saves");
			ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.allowedmods"), Resources::GetString(".menu.ok"), null);
			return;
		}

		uint modsHash = uint(parseInt(Lobby::GetLobbyData(id, "mods-hash")));
		if (modsHash != Resources::GetModHash())
		{
			auto enabledMods = HwrSaves::GetEnabledMods();

			int modsCount = parseInt(Lobby::GetLobbyData(id, "mods-count"));
			string mods = Lobby::GetLobbyData(id, "mods");
			auto arrMods = mods.split("\n");

			PrintError("Can't join because mod hash mismatch (expected " + modsCount + " mods with hash " + modsHash + " / " + Resources::GetModHash() + ")");

			if (modsCount != int(arrMods.length()))
				PrintError("WARNING: Mods list is probably too long, parsed array is not the same length!");

			string strMissing;
			string strHostMissing;

			for (uint i = 0; i < arrMods.length(); i++)
			{
				string mod = arrMods[i];
				int index = mod.findFirst(":");

				string modId = mod.substr(0, index);
				string modName = mod.substr(index + 1);

				bool modInstalled = false;
				for (uint j = 0; j < enabledMods.length(); j++)
				{
					if (enabledMods[j].ID == modId)
					{
						modInstalled = true;
						enabledMods.removeAt(j);
						break;
					}
				}

				if (!modInstalled)
				{
					if (strMissing.length() > 0)
						strMissing += ", ";
					strMissing += "\\cFFFFFF" + modName + "\\cF8941D";

					PrintError("Missing mod: \"" + modName + "\" (ID: " + modId + ")");
				}
			}

			for (uint i = 0; i < enabledMods.length(); i++)
			{
				auto mod = enabledMods[i];

				if (strHostMissing.length() > 0)
					strHostMissing += ", ";
				strHostMissing += "\\cFFFFFF" + mod.Name + "\\cF8941D";

				PrintError("Mod installed that host doesn't have: \"" + mod.Name + "\" (ID: " + mod.ID + ")");
			}

			if (strMissing.length() > 0)
			{
				strMissing = "\n" + Resources::GetString(".menu.notifier.joinfailed.mods.missing", {
					{ "missing", strMissing }
				});
			}

			if (strHostMissing.length() > 0)
			{
				strHostMissing = "\n" + Resources::GetString(".menu.notifier.joinfailed.mods.hostmissing", {
					{ "missing", strHostMissing }
				});
			}

			ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.mods", {
				{ "missing", strMissing },
				{ "hostmissing", strHostMissing }
			}), Resources::GetString(".menu.ok"), null);
			return;
		}

		bool pure = (parseInt(Lobby::GetLobbyData(id, "pure")) == 1);
		if (pure != GetVarBool("g_pure"))
		{
			PrintError("Can't join because pure state mismatch");
			//TODO: Give different error
			ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.join"), Resources::GetString(".menu.ok"), null);
			return;
		}

		m_inviteAcceptID = id;
		m_inviteAcceptMaxLevel = parseInt(Lobby::GetLobbyData(id, "max-level"));
		m_inviteAcceptMinLevel = parseInt(Lobby::GetLobbyData(id, "min-level"));
		m_inviteAcceptMercenary = (Lobby::GetLobbyData(id, "mercenary") == "true");

		auto menu = cast<Menu::HwrMenu>(m_gameMenu.m_menus[0]);
		if (menu is null)
		{
			PrintError("First menu is not HwrMenu!");
			return;
		}

		menu.ShowCharacterSelection("multi-invite");
	}

	void UpdateLobbyMemberData()
	{
		Lobby::SetLobbyMemberData("dlc-pop", Platform::HasDLC("pop") ? "1" : "0");
		Lobby::SetLobbyMemberData("dlc-wh", Platform::HasDLC("wh") ? "1" : "0");
		Lobby::SetLobbyMemberData("dlc-mt", Platform::HasDLC("mt") ? "1" : "0");
	}

	void LobbyEntered()
	{
		UpdateLobbyMemberData();
	}

	void LobbyFailedJoin(bool host)
	{
		m_joinFailed = host ? 1 : 0;

		if (m_joiningMenu !is null)
		{
			m_joiningMenu.Close();
			@m_joiningMenu = null;
		}

		ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.join"), Resources::GetString(".menu.ok"), null);
	}

	void AddPlayer(uint8 peer) override
	{
		if (m_wChat !is null)
			m_wChat.PlayerSystem(peer, ".menu.lobby.chat.isjoined");
	}

	void RemovePlayer(uint8 peer, bool kicked) override
	{
		if (m_wChat !is null)
		{
			if (kicked)
				m_wChat.PlayerSystem(peer, ".menu.lobby.chat.iskicked");
			else
				m_wChat.PlayerSystem(peer, ".menu.lobby.chat.isleft");
		}
	}
	
	void SystemMessage(string name, SValue@ data)
	{
		if (name == "AddChat")
		{
			if (m_wChat !is null)
				m_wChat.AddChat(data.GetString());
		}
		else if (name == "SetNGP" && Network::IsServer())
			Lobby::SetLobbyData("ngp", data.GetInteger());
		else if (name == "SetDownscaling" && Network::IsServer())
			Lobby::SetLobbyData("downscaling", data.GetBoolean() ? "true" : "false");
	}

	void PlayGame(int numPlrs)
	{
		// Singleplayer
		StartGame(numPlrs, GetTownLevelFilename());
	}

	void OnBindingInput(ControllerType type, int key)
	{
		if (m_expectingInput !is null)
			m_expectingInput.ExpectedInput(type, key);
	}

	void LobbyList(array<uint64>@ lobbies)
	{
		auto listMenu = GetServerlistMenu();
		if (listMenu !is null)
			listMenu.OnLobbyList(lobbies);
	}
}

void LobbySayCfunc(cvar_t@ arg0)
{
	auto gm = cast<MainMenu>(g_gameMode);
	if (gm is null)
		return;

	string text = arg0.GetString();
	if (text == "")
		return;

	if (gm.m_wChat is null)
		return;

	gm.m_wChat.PlayerChat(Lobby::GetLocalPeer(), text);
	Lobby::SendChatMessage(text);
}
