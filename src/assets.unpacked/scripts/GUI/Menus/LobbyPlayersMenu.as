namespace Menu
{
	class LobbyPlayersMenu : Menu
	{
		Widget@ m_wPlayerWindow;
		Widget@ m_wPlayerList;
		Widget@ m_wPlayerTemplate;

		TextWidget@ m_wTitle;

		int m_kickPeer;

		int m_lastNumPlayers = 0;
		int m_pingC = 1000;

		LobbyPlayersMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			Menu::Initialize(def);

			@m_wPlayerWindow = m_widget.GetWidgetById("player-window");
			@m_wPlayerList = m_widget.GetWidgetById("player-list");
			@m_wPlayerTemplate = m_widget.GetWidgetById("player-template");

			@m_wTitle = cast<TextWidget>(m_widget.GetWidgetById("title"));

			m_wPlayerWindow.m_visible = true;
			UpdatePlayerList();
		}

		void Show() override
		{
			UpdatePlayerList();
		}

		int GetPeerPing(int peer)
		{
			int localPeer = Lobby::GetLocalPeer();
			if (!Lobby::IsPlayerHost(localPeer))
			{
				if (peer == localPeer)
					return Lobby::GetPlayerPing(0);
				else if (peer == 0)
					return Lobby::GetPlayerPing(localPeer);
			}
			return Lobby::GetPlayerPing(peer);
		}

		void UpdatePlayerList()
		{
			if (!Lobby::IsInLobby())
				return;

			int numPlayers = Lobby::GetLobbyPlayerCount();

			m_lastNumPlayers = numPlayers;

			if (numPlayers <= 4)
				m_wTitle.SetText(Resources::GetString(".mainmenu.lobbyplayers.title"));
			else
			{
				m_wTitle.SetText(Resources::GetString(".mainmenu.lobbyplayers.title.multiple", {
					{ "count", numPlayers }
				}));
			}

			m_wPlayerList.ClearChildren();

			for (int i = 0; i < numPlayers; i++)
			{
				auto wPlayer = m_wPlayerTemplate.Clone();
				wPlayer.SetID("player-" + i);
				wPlayer.m_visible = true;

				UpdatePlayer(wPlayer, i);

				m_wPlayerList.AddChild(wPlayer);
			}
		}

		void UpdatePlayer(Widget@ wPlayer, int peer)
		{
			int localPeer = Lobby::GetLocalPeer();
			bool isLocal = (localPeer == peer);
			bool isHost = Lobby::IsPlayerHost(localPeer);
			string playerName = Lobby::GetPlayerName(peer);
			int playerPing = GetPeerPing(peer);

			auto plrSave = HwrSaves::LoadCharacter(peer);
			if (plrSave is null)
				return;

			string charName = GetParamString(UnitPtr(), plrSave, "name", false);
			string charClass = GetParamString(UnitPtr(), plrSave, "class", false);
			int charLevel = GetParamInt(UnitPtr(), plrSave, "level", false);

			auto wName = cast<TextWidget>(wPlayer.GetWidgetById("name"));
			if (wName !is null)
			{
				wName.SetText(
					charName +
					" (" + playerName + "), " +
					Resources::GetString(".mainmenu.lobbyplayers.level", { { "level", charLevel } }) + " " +
					Resources::GetString(".class." + charClass)
				);
				wName.SetColor(ParseColorRGBA("#" + GetPlayerColor(peer) + "ff"));
			}

			auto wPing = cast<TextWidget>(wPlayer.GetWidgetById("ping"));
			if (wPing !is null)
				wPing.SetText(playerPing + " ms");

			auto wProfileButton = cast<SpriteButtonWidget>(wPlayer.GetWidgetById("profile-button"));
			if (wProfileButton !is null)
			{
				wProfileButton.m_enabled = Lobby::CanOpenProfile(peer);
				wProfileButton.m_func = "profile " + peer;
			}

			auto wKickButton = cast<SpriteButtonWidget>(wPlayer.GetWidgetById("kick-button"));
			if (wKickButton !is null)
			{
				wKickButton.m_enabled = (isHost && !isLocal);
				wKickButton.m_func = "kick " + peer;
			}
		}

		void Update(int dt) override
		{
			m_pingC -= dt;
			if (m_pingC <= 0)
			{
				m_pingC += 1000;

				int numPlayers = Lobby::GetLobbyPlayerCount();
				if (m_lastNumPlayers != numPlayers)
					UpdatePlayerList();
				else
				{
					for (int i = 0; i < numPlayers; i++)
					{
						auto wPlayer = m_widget.GetWidgetById("player-" + i);
						if (wPlayer !is null)
							UpdatePlayer(wPlayer, i);
					}
				}
			}

			Menu::Update(dt);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");

			if (parse[0] == "profile")
				Lobby::OpenProfile(parseInt(parse[1]));
			else if (parse[0] == "kick")
			{
				if (parse[1] == "yes")
					Lobby::KickPlayer(m_kickPeer);
				else if (parse[1] != "no")
				{
					m_kickPeer = parseInt(parse[1]);
					g_gameMode.ShowDialog("kick", Resources::GetString(".mainmenu.lobbyplayers.kick.prompt", {
						{ "name", Lobby::GetPlayerName(m_kickPeer) }
					}), Resources::GetString(".menu.yes"), Resources::GetString(".menu.no"), this);
				}
			}

			else
				Menu::OnFunc(sender, name);
		}
	}
}
