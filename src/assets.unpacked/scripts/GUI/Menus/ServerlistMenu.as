namespace Menu
{
	enum ServerlistSortColumn
	{
		None,
		Name,
		Players,
	}

	class ServerlistMenu : Menu
	{
		TextInputWidget@ m_wFilter;
		MenuServerListItem@ m_listTemplate;
		FilteredListWidget@ m_list;

		ServerlistSortColumn m_sortColumn = ServerlistSortColumn::Players;
		int m_sortDir = 1;

		Sprite@ m_spriteButton;
		Sprite@ m_spriteButtonHover;
		Sprite@ m_spriteButtonDown;

		int m_charLevel;
		bool m_charMercenary;

		ServerlistMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			@m_wFilter = cast<TextInputWidget>(m_widget.GetWidgetById("filter"));
			@m_listTemplate = cast<MenuServerListItem>(m_widget.GetWidgetById("serverlist-template"));
			@m_list = cast<FilteredListWidget>(m_widget.GetWidgetById("serverlist"));

			@m_spriteButton = def.GetSprite("listitem");
			@m_spriteButtonHover = def.GetSprite("listitem-hover");
			@m_spriteButtonDown = def.GetSprite("listitem-down");

			Lobby::ListLobbies();

			auto svChar = HwrSaves::LoadCharacter();
			if (svChar !is null)
			{
				m_charLevel = GetParamInt(UnitPtr(), svChar, "level", false, 1);
				m_charMercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);

				string name = GetParamString(UnitPtr(), svChar, "name");
				string charClass = GetParamString(UnitPtr(), svChar, "class");

				auto wCharUnit = cast<UnitWidget>(m_widget.GetWidgetById("char-unit"));
				wCharUnit.AddUnit("players/" + charClass + ".unit", "idle-3");

				auto dyes = Materials::DyesFromSval(svChar);
				wCharUnit.m_dyeStates = Materials::MakeDyeStates(dyes);

				string charClassName = Resources::GetString(".class." + charClass);
				auto wName = cast<TextWidget>(m_widget.GetWidgetById("char-name"));
				wName.SetText(Resources::GetString(".mainmenu.serverlist.charname", {
					{ "name", name },
					{ "lvl", m_charLevel },
					{ "class", charClassName }
				}));
			}
		}

		void Show() override
		{
			Menu::Show();

			Lobby::ListLobbies();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");
			if (parse[0] == "join")
			{
				if (parse.length() > 1)
				{
					MainMenu@ menu = cast<MainMenu>(g_gameMode);
					menu.JoiningLobby();
					Lobby::JoinLobby(parseUInt(parse[1]));
				}
			}
			else if (parse[0] == "refresh")
			{
				//m_list.ClearChildren();
				Lobby::ListLobbies();
			}
			else if (parse[0] == "filterlist")
				m_list.SetFilter(m_wFilter.m_text.plain());
			else if (parse[0] == "filterlist-clear")
			{
				m_wFilter.ClearText();
				m_list.ShowAll();
			}
			else if (parse[0] == "sort")
			{
				ServerlistSortColumn setCol = ServerlistSortColumn::None;
				if (parse[1] == "name")
					setCol = ServerlistSortColumn::Name;
				else if (parse[1] == "players")
					setCol = ServerlistSortColumn::Players;
				else
					setCol = ServerlistSortColumn::None;

				if (m_sortColumn == setCol)
				{
					if (m_sortDir == 0 || m_sortDir == -1)
						m_sortDir = 1;
					else if (m_sortDir == 1)
						m_sortDir = -1;
				}
				else
					m_sortDir = 1;
				m_sortColumn = setCol;

				m_list.m_children.sortAsc();
			}
			else
				Menu::OnFunc(sender, name);
		}

		void OnLobbyList(array<uint64>@ lobbies)
		{
			uint localModHash = Resources::GetModHash();

			m_list.ClearChildren();
			for (uint i = 0; i < lobbies.length(); i++)
			{
				string lobbyName = Lobby::GetLobbyData(lobbies[i], "name");
				int lobbyPlayerCount = Lobby::GetLobbyPlayerCount(lobbies[i]);
				int lobbyPlayerCountMax = Lobby::GetLobbyPlayerCountMax(lobbies[i]);
				int lobbyPing = Lobby::GetLobbyPing(lobbies[i]);

				int maxLevel = parseInt(Lobby::GetLobbyData(lobbies[i], "max-level"));
				int minLevel = parseInt(Lobby::GetLobbyData(lobbies[i], "min-level"));
				int ngp = parseInt(Lobby::GetLobbyData(lobbies[i], "ngp"));
				bool downscaling = (Lobby::GetLobbyData(lobbies[i], "downscaling") == "true");
				bool allowModded = (Lobby::GetLobbyData(lobbies[i], "allow-modded") == "true");

				uint modsHash = uint(parseInt(Lobby::GetLobbyData(lobbies[i], "mods-hash")));
				int modsCount = parseInt(Lobby::GetLobbyData(lobbies[i], "mods-count"));
				string mods = Lobby::GetLobbyData(lobbies[i], "mods");
				array<string> dlcs = Lobby::GetLobbyData(lobbies[i], "dlcs").split(",");
				bool pure = (parseInt(Lobby::GetLobbyData(lobbies[i], "pure")) == 1);
				bool mercenary = (Lobby::GetLobbyData(lobbies[i], "mercenary") == "true");

				MenuServerListItem@ wLobbyItem = cast<MenuServerListItem>(m_listTemplate.Clone());
				wLobbyItem.m_visible = true;
				wLobbyItem.m_func = "join " + lobbies[i];
				wLobbyItem.Set(this, lobbyName, lobbyPlayerCount, lobbyPlayerCountMax, lobbyPing, dlcs);

				if (lobbyPlayerCount >= lobbyPlayerCountMax)
					wLobbyItem.m_enabled = false;
				else if (m_charLevel < minLevel || (maxLevel != -1 && m_charLevel > maxLevel))
					wLobbyItem.m_enabled = false;
				else if (modsHash != localModHash)
					wLobbyItem.m_enabled = false;
				else if (!allowModded && HwrSaves::IsModded())
					wLobbyItem.m_enabled = false;
				else if (pure != GetVarBool("g_pure"))
					wLobbyItem.m_enabled = false;
				else if (m_charMercenary != mercenary)
					wLobbyItem.m_enabled = false;

				if (minLevel > 1 && maxLevel != -1)
				{
					string strMinLevel = "" + minLevel;
					string strMaxLevel = "" + maxLevel;
					if (m_charLevel < minLevel)
						strMinLevel = "\\cff0000" + minLevel;
					if (m_charLevel > maxLevel)
						strMaxLevel = "\\cff0000" + maxLevel;
					wLobbyItem.m_tooltipText = Resources::GetString(".mainmenu.serverlist.level-restriction.both", {
						{ "min", strMinLevel },
						{ "max", strMaxLevel }
					});
				}
				else if (minLevel > 1)
				{
					string strMinLevel = "" + minLevel;
					if (m_charLevel < minLevel)
						strMinLevel = "\\cff0000" + minLevel + "\\d";
					wLobbyItem.m_tooltipText = Resources::GetString(".mainmenu.serverlist.level-restriction.min", {
						{ "min", strMinLevel }
					});
				}
				else if (maxLevel != -1)
				{
					string strMaxLevel = "" + maxLevel;
					if (m_charLevel > maxLevel)
						strMaxLevel = "\\cff0000" + maxLevel + "\\d";
					wLobbyItem.m_tooltipText = Resources::GetString(".mainmenu.serverlist.level-restriction.max", {
						{ "max", strMaxLevel }
					});
				}

				if (ngp > 0)
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += Resources::GetString(".mainmenu.serverlist.ngp", {
						{ "ngp", ngp }
					});
				}

				if (downscaling)
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += Resources::GetString(".mainmenu.serverlist.downscaling");
				}

				if (modsHash != 0 || modsCount > 0)
				{
					string strModCount;
					if (modsCount == 1)
						strModCount = Resources::GetString(".mainmenu.serverlist.mods.one");
					else
						strModCount = Resources::GetString(".mainmenu.serverlist.mods.plural", { { "num", modsCount } });

					if (modsHash != localModHash)
						strModCount = "\\cff0000" + strModCount + "\\d - " + Resources::GetString(".mainmenu.serverlist.mods.dontmatch");

					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += strModCount + "\n\\c7f7f7f" + mods;
				}

				if (!allowModded && HwrSaves::IsModded())
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += Resources::GetString(".mainmenu.serverlist.mod-restriction");
				}
				else if (allowModded)
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += Resources::GetString(".mainmenu.serverlist.mods-allowed");
				}

				if (mercenary)
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += Resources::GetString(".mainmenu.serverlist.mercenary-only");
				}
				else if (!mercenary && m_charMercenary)
				{
					if (wLobbyItem.m_tooltipText != "")
						wLobbyItem.m_tooltipText += "\n\\d";
					wLobbyItem.m_tooltipText += "\\cff0000" + Resources::GetString(".mainmenu.serverlist.mercenary-regular");
				}

				m_list.AddChild(wLobbyItem);
			}

			m_list.m_children.sortAsc();
		}
	}
}
