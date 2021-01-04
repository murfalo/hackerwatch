class ScoreDialog : UserWindow
{
	IWidgetHoster@ m_owner;

	ScoreDialog(GUIBuilder@ b, IWidgetHoster@ owner)
	{
		super(b, "gui/scoredialog.gui");

		@m_owner = owner;
	}

	SValue@ BuildData()
	{
		SValueBuilder sval;
		sval.PushDictionary();

		sval.PushArray("players");

		for (uint i = 0; i < g_players.length(); i++)
		{
			PlayerRecord@ player = g_players[i];
			if (player.peer == 255)
				continue;

			sval.PushDictionary();
			sval.PushInteger("peer", player.peer);
			sval.PushInteger("kills", player.kills);
			sval.PushInteger("deaths", player.deaths);
			sval.PopDictionary();
		}

		sval.PopArray();

		return sval.Build();
	}

	void Set(SValue@ sv, string header)
	{
		auto wHeader = cast<TextWidget>(m_widget.GetWidgetById("header"));
		if (wHeader !is null)
			wHeader.SetText(header);

		Widget@ wList = m_widget.GetWidgetById("player-list");
		if (wList !is null)
			wList.ClearChildren();

		Widget@ wTemplate = m_widget.GetWidgetById("player-template");

		array<SValue@>@ dictPlayers = GetParamArray(UnitPtr(), sv, "players", false);
		if (wList !is null && wTemplate !is null && dictPlayers !is null)
		{
			for (uint i = 0; i < dictPlayers.length(); i++)
			{
				SValue@ dictPlayer = dictPlayers[i];
				uint8 peer = GetParamInt(UnitPtr(), dictPlayer, "peer");

				PlayerRecord@ player = GetPlayerRecordByPeer(peer);
				if (player is null)
					continue;

				Widget@ wNewItem = wTemplate.Clone();
				wNewItem.m_visible = true;
				wNewItem.SetID("");

				TextWidget@ wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
				if (wName !is null)
				{
					wName.SetText(player.GetName());
					wName.SetColor(ParseColorRGBA("#" + GetPlayerColor(player.peer) + "ff"));
				}

				TextWidget@ wKills = cast<TextWidget>(wNewItem.GetWidgetById("kills"));
				if (wKills !is null)
					wKills.SetText("" + GetParamInt(UnitPtr(), dictPlayer, "kills"));

				TextWidget@ wDeaths = cast<TextWidget>(wNewItem.GetWidgetById("deaths"));
				if (wDeaths !is null)
					wDeaths.SetText("" + GetParamInt(UnitPtr(), dictPlayer, "deaths"));

				wList.AddChild(wNewItem);
			}
		}

		Widget@ wStatsLevel = m_widget.GetWidgetById("stats-level");
		if (wStatsLevel !is null)
		{
			Campaign@ campaign = cast<Campaign>(g_gameMode);

			TextWidget@ wStatsTime = cast<TextWidget>(wStatsLevel.GetWidgetById("time"));
			if (wStatsTime !is null)
				wStatsTime.SetText(formatTime(CurrPlaytimeLevel() / 1000.0f, false, true, true));

			TextWidget@ wStatsSecrets = cast<TextWidget>(wStatsLevel.GetWidgetById("secrets"));
			if (wStatsSecrets !is null)
				wStatsSecrets.SetText("-");

			TextWidget@ wStatsRestarts = cast<TextWidget>(wStatsLevel.GetWidgetById("restarts"));
			if (wStatsRestarts !is null)
				wStatsRestarts.SetText("" + GetRestartCount());
		}

		Widget@ wStatsGame = m_widget.GetWidgetById("stats-game");
		if (wStatsGame !is null)
		{
			Campaign@ campaign = cast<Campaign>(g_gameMode);

			TextWidget@ wStatsTime = cast<TextWidget>(wStatsGame.GetWidgetById("time"));
			if (wStatsTime !is null)
				wStatsTime.SetText(formatTime(CurrPlaytimeTotal() / 1000.0f, false, true, true));

			TextWidget@ wStatsSecrets = cast<TextWidget>(wStatsGame.GetWidgetById("secrets"));
			if (wStatsSecrets !is null)
				wStatsSecrets.SetText("-");

			TextWidget@ wStatsRestarts = cast<TextWidget>(wStatsGame.GetWidgetById("restarts"));
			if (wStatsRestarts !is null)
				wStatsRestarts.SetText("" + GetRestartCount());
		}
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
		{
			Close();
			if (m_owner !is null)
				m_owner.OnFunc(sender, "scoreclose");
		}
		else
			UserWindow::OnFunc(sender, name);
	}
}
