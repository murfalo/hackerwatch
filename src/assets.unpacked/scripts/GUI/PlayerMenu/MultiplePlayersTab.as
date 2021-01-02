class MultiplePlayersTab : PlayerMenuTab
{
	int m_currentPlayerIndex;

	void OnShow() override
	{
		PlayerMenuTab::OnShow();

		UpdateFromLocal();

		int connectedPlayers = NumConnectedPlayers();

		auto wPlayerButtonLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("player-button-left"));
		if (wPlayerButtonLeft !is null)
			wPlayerButtonLeft.m_enabled = (connectedPlayers > 1);

		auto wPlayerButtonRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("player-button-right"));
		if (wPlayerButtonRight !is null)
			wPlayerButtonRight.m_enabled = (connectedPlayers > 1);
	}

	void UpdateFromLocal()
	{
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].local)
			{
				m_currentPlayerIndex = i;
				break;
			}
		}
		UpdateNow(g_players[m_currentPlayerIndex]);
	}

	void UpdateNow()
	{
		int curIndex = 0;
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == 255)
				continue;

			if (curIndex == m_currentPlayerIndex)
			{
				UpdateNow(g_players[i]);
				return;
			}
			curIndex++;
		}

		PrintError("Couldn't find player with active index " + m_currentPlayerIndex);
		UpdateFromLocal();
	}

	void UpdateNow(PlayerRecord@ record)
	{
		// Player portrait
		auto wPortrait = cast<PortraitWidget>(m_widget.GetWidgetById("portrait"));
		if (wPortrait !is null)
			wPortrait.BindRecord(record);

		// Player header
		vec4 playerColor = ParseColorRGBA("#" + GetPlayerColor(record.peer) + "ff");

		auto wPlayerName = cast<TextWidget>(m_widget.GetWidgetById("playername"));
		if (wPlayerName !is null)
		{
			wPlayerName.SetText(Lobby::GetPlayerName(record.peer));
			wPlayerName.SetColor(playerColor);
		}

		auto wPlayerTitle = cast<TextWidget>(m_widget.GetWidgetById("playertitle"));
		if (wPlayerTitle !is null)
		{
			auto title = record.GetTitle();
			dictionary titleParams = {
				{ "name", record.GetName() },
				{ "title", title is null ? Resources::GetString(".titles.guild-0") : Resources::GetString(title.m_name) },
				{ "lvl", "" + record.level },
				{ "class", Resources::GetString(".class." + record.charClass) }
			};

%if HARDCORE
			wPlayerTitle.SetText(Resources::GetString(".hud.character.title.hardcore", titleParams));
%else
			wPlayerTitle.SetText(Resources::GetString(".hud.character.title", titleParams));
%endif
		}

		auto wDlcPop = m_widget.GetWidgetById("dlc-pop");
		if (wDlcPop !is null)
		{
			bool hasDLC = false;
			if (record.local)
				hasDLC = Platform::HasDLC("pop");
			else
				hasDLC = (Lobby::GetLobbyMemberData(record.peer, "dlc-pop") == "1");
			wDlcPop.m_visible = hasDLC;
		}

		auto wDlcWh = m_widget.GetWidgetById("dlc-wh");
		if (wDlcWh !is null)
		{
			bool hasDLC = false;
			if (record.local)
				hasDLC = Platform::HasDLC("wh");
			else
				hasDLC = (Lobby::GetLobbyMemberData(record.peer, "dlc-wh") == "1");
			wDlcWh.m_visible = hasDLC;
		}

		auto wDlcMt = m_widget.GetWidgetById("dlc-mt");
		if (wDlcMt !is null)
		{
			bool hasDLC = false;
			if (record.local)
				hasDLC = Platform::HasDLC("mt");
			else
				hasDLC = (Lobby::GetLobbyMemberData(record.peer, "dlc-mt") == "1");
			wDlcMt.m_visible = hasDLC;
		}

		auto wPlayerHeader = cast<RectWidget>(m_widget.GetWidgetById("playerheader"));
		if (wPlayerHeader !is null)
		{
			if (record.local)
				wPlayerHeader.m_color = ParseColorRGBA("#202A26FF");
			else
				wPlayerHeader.m_color = desaturate(playerColor);

			string tooltipText = record.ngps.BuildCharacterInfoTooltip();

			int gladiatorRank = record.GladiatorRank();
			if (gladiatorRank > 0)
				tooltipText += Resources::GetString(".charinfo.arena.rank", { { "rank", gladiatorRank } });

			wPlayerHeader.m_tooltipText = strTrim(tooltipText);
			if (wPlayerHeader.m_tooltipText != "")
				wPlayerHeader.m_tooltipTitle = record.GetName();
			else
				wPlayerHeader.m_tooltipTitle = "";
		}
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "char-prev")
		{
			if (--m_currentPlayerIndex < 0)
				m_currentPlayerIndex = NumConnectedPlayers() - 1;
			UpdateNow();
			return true;
		}
		else if (name == "char-next")
		{
			if (++m_currentPlayerIndex >= NumConnectedPlayers())
				m_currentPlayerIndex = 0;
			UpdateNow();
			return true;
		}
		return false;
	}
}
