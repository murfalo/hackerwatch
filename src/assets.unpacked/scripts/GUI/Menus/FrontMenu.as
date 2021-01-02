namespace Menu
{
	class FrontMenu : HwrMenu
	{
		Widget@ m_wLogoContainer;
		SpriteWidget@ m_wLogo;
		SpriteWidget@ m_wCrackshellIcon;

		Widget@ m_wPopupMultiplayer;
		Widget@ m_wPopupOptions;
		Widget@ m_wPopupConfirmRestart;
		Widget@ m_wPopupConfirmStop;

		array<Widget@> m_arrPopups;

		bool m_haveUnpackedMods;

		FrontMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			HwrMenu::Initialize(def);

			@m_wLogoContainer = m_widget.GetWidgetById("logo-container");
			@m_wLogo = cast<SpriteWidget>(m_widget.GetWidgetById("logo"));

			@m_wCrackshellIcon = cast<SpriteWidget>(m_widget.GetWidgetById("icon-crackshell"));

			auto wStoreDlcPop = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("store-dlc-pop"));
			if (wStoreDlcPop !is null && Platform::HasDLC("pop"))
				wStoreDlcPop.m_tooltipText = Resources::GetString(".menu.store.pop.owned");

			auto wStoreDlcWh = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("store-dlc-wh"));
			if (wStoreDlcWh !is null && Platform::HasDLC("wh"))
				wStoreDlcWh.m_tooltipText = Resources::GetString(".menu.store.wh.owned");

			auto wStoreDlcMt = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("store-dlc-mt"));
			if (wStoreDlcMt !is null && Platform::HasDLC("mt"))
				wStoreDlcMt.m_tooltipText = Resources::GetString(".menu.store.mt.owned");

			auto wMultiTest = m_widget.GetWidgetById("multi-test");
			if (wMultiTest !is null)
				wMultiTest.m_visible = GetVarBool("g_multi_test");

			m_arrPopups.insertLast(@m_wPopupMultiplayer = m_widget.GetWidgetById("popup-multiplayer"));
			m_arrPopups.insertLast(@m_wPopupOptions = m_widget.GetWidgetById("popup-options"));
			m_arrPopups.insertLast(@m_wPopupConfirmRestart = m_widget.GetWidgetById("popup-restart"));
			m_arrPopups.insertLast(@m_wPopupConfirmStop = m_widget.GetWidgetById("popup-stop"));

			Widget@ wLobbyPlayers = m_widget.GetWidgetById("players-list");
			if (wLobbyPlayers !is null && Lobby::IsInLobby())
			{
				int addWidth = wLobbyPlayers.m_width + wLobbyPlayers.m_parent.m_spacing;

				wLobbyPlayers.m_visible = true;
				wLobbyPlayers.m_parent.m_width += addWidth;

				for (uint i = 0; i < m_arrPopups.length(); i++)
				{
					if (m_arrPopups[i] !is null)
						m_arrPopups[i].m_offset.x += addWidth / 2;
				}
			}

			auto enabledMods = HwrSaves::GetEnabledMods();
			for (uint i = 0; i < enabledMods.length(); i++)
			{
				if (!enabledMods[i].Packaged)
				{
					m_haveUnpackedMods = true;
					break;
				}
			}
		}

		bool Close() override
		{
			return false;
		}

		void SetStyle(SValue@ svStyle) override
		{
			if (m_wCrackshellIcon !is null)
			{
				string crackshellIcon = GetParamString(UnitPtr(), svStyle, "crackshell-icon");
				m_wCrackshellIcon.SetSprite(crackshellIcon);
			}

			if (m_wLogoContainer !is null && m_wLogo !is null)
			{
				string logo = GetParamString(UnitPtr(), svStyle, "logo");
				m_wLogo.SetSprite(logo);
				m_wLogoContainer.m_width = m_wLogo.m_width;
				m_wLogoContainer.m_height = m_wLogo.m_height;
			}
		}

		void TogglePopupMenu(Widget@ w)
		{
			for (uint i = 0; i < m_arrPopups.length(); i++)
			{
				if (m_arrPopups[i] is null)
					continue;

				if (m_arrPopups[i] is w)
					m_arrPopups[i].m_visible = !m_arrPopups[i].m_visible;
				else
					m_arrPopups[i].m_visible = false;
			}
		}

		void Update(int dt) override
		{
			HwrMenu::Update(dt);

			if (m_wPopupMultiplayer !is null)
			{
				bool onlineAvailable = Platform::Service.IsMultiplayerAvailable();
				for (uint i = 0; i < m_wPopupMultiplayer.m_children.length(); i++)
				{
					auto wButton = cast<ScalableSpriteButtonWidget>(m_wPopupMultiplayer.m_children[i]);
					if (wButton is null)
						continue;

					wButton.m_enabled = onlineAvailable;

					if (!onlineAvailable)
					{
						if (m_haveUnpackedMods)
							wButton.m_tooltipText = Resources::GetString(".mainmenu.multiplayer.disabled.mods");
						else
							wButton.m_tooltipText = Resources::GetString(".mainmenu.multiplayer.disabled");
					}
					else
						wButton.m_tooltipText = "";
				}
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "logo")
				m_wLogo.m_visible = !m_wLogo.m_visible;

			else if (name == "slots")
				OpenMenu(SlotsMenu(m_provider), "gui/main_menu/slots.gui");

			else if (name == "single")
				ShowCharacterSelection("");

			else if (name == "multi-test")
			{
				auto gm = cast<MainMenu>(g_gameMode);
				gm.m_testLevel = true;
				HwrSaves::PickCharacter(0);
				Lobby::CreateLobby();
			}

			else if (name == "multi")
				TogglePopupMenu(m_wPopupMultiplayer);
			else if (name == "multi-host")
				ShowCharacterSelection("multi-host");
			else if (name == "multi-serverlist")
				ShowCharacterSelection("multi-serverlist");

			else if (name == "options")
				TogglePopupMenu(m_wPopupOptions);
			else if (name == "options-gameplay")
				OpenMenu(GameOptionsMenu(m_provider), "gui/main_menu/options_game.gui");
			else if (name == "options-graphics")
				OpenMenu(GraphicsMenu(m_provider), "gui/main_menu/options_graphics.gui");
			else if (name == "options-sound")
				OpenMenu(SoundMenu(m_provider), "gui/main_menu/options_sound.gui");
			else if (name == "options-controls")
				OpenMenu(ControlsMenu(m_provider), "gui/main_menu/options_controls.gui");
			else if (name == "options-credits")
				OpenMenu(CreditsMenu(m_provider), "gui/main_menu/credits.gui");

			else if (name == "options-players")
				OpenMenu(LobbyPlayersMenu(m_provider), "gui/ingame_menu/lobbyplayers.gui");

			else if (name == "resume")
				ResumeGame();

			else if (name == "restart" || name == "restart-no")
				TogglePopupMenu(m_wPopupConfirmRestart);
			else if (name == "restart-yes")
			{
				ResumeGame();
				GlobalCache::Set("main_restart", "1");
			}

			else if (name == "quit")
				QuitGame();

			else if (name == "wiki")
				Platform::OpenUrl("http://wiki.heroesofhammerwatch.com/Main_Page");
			else if (name == "discord")
				Platform::OpenUrl("https://discord.gg/hammerwatch");

			else if (name == "store-crackshell")
			{
%if USING_STEAM || USING_STEAM_FAILED
				Platform::Service.OverlayBrowser("https://store.steampowered.com/search/?developer=Crackshell");
%else
				Platform::Service.OverlayBrowser("https://www.gog.com/games?devpub=crackshell");
%endif
			}
			else if (name == "store-dlc-pop")
			{
%if USING_STEAM || USING_STEAM_FAILED
				Platform::Service.OverlayBrowser("https://store.steampowered.com/app/1015030");
%else
				Platform::Service.OverlayBrowser("https://www.gog.com/game/heroes_of_hammerwatch_pyramid_of_prophecy");
%endif
			}
			else if (name == "store-dlc-wh")
			{
%if USING_STEAM || USING_STEAM_FAILED
				Platform::Service.OverlayBrowser("https://store.steampowered.com/app/1086870");
%else
				Platform::Service.OverlayBrowser("https://www.gog.com/game/heroes_of_hammerwatch_witch_hunter");
%endif
			}
			else if (name == "store-dlc-mt")
			{
%if USING_STEAM || USING_STEAM_FAILED
				Platform::Service.OverlayBrowser("https://store.steampowered.com/app/1142880");
%else
				Platform::Service.OverlayBrowser("https://www.gog.com/game/heroes_of_hammerwatch_moon_temple");
%endif
			}

			else if (name == "stop" || name == "stop-no")
				TogglePopupMenu(m_wPopupConfirmStop);
			else if (name == "stop-yes")
				StopScenario();

			else
				HwrMenu::OnFunc(sender, name);
		}
	}
}
