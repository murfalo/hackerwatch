class MenuServerListItem : ScalableSpriteButtonWidget
{
	Menu::ServerlistMenu@ m_owner;

	string m_serverName;
	int m_serverPlayers;
	int m_serverPlayersMax;

	BitmapString@ m_textPlayers;
	//BitmapString@ m_textPing;

	GUIDef@ m_def;
	array<Sprite@> m_dlcSprites;

	MenuServerListItem()
	{
		super();
	}

	int opCmp(const Widget@ w) override
	{
		if (m_owner is null)
			return 0;

		const MenuServerListItem@ wServer = cast<MenuServerListItem>(w);
		if (wServer is null)
			return 0;

		if (m_owner.m_sortColumn == Menu::ServerlistSortColumn::None)
			return 0;
		else if (m_owner.m_sortColumn == Menu::ServerlistSortColumn::Name)
			return m_serverName.opCmp(wServer.m_serverName) * m_owner.m_sortDir;
		else if (m_owner.m_sortColumn == Menu::ServerlistSortColumn::Players)
		{
			if (m_serverPlayers < wServer.m_serverPlayers)
				return 1 * m_owner.m_sortDir;
			else if (m_serverPlayers > wServer.m_serverPlayers)
				return -1 * m_owner.m_sortDir;
			return 0;
		}

		return 0;
	}

	Widget@ Clone() override
	{
		MenuServerListItem@ w = MenuServerListItem();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		ScalableSpriteButtonWidget::Load(ctx);

		@m_def = ctx.GetGUIDef();

		m_textOffset.x = 10;
	}

	void Set(Menu::ServerlistMenu@ owner, string name, int players, int playersMax, int lobbyPing, array<string> dlcs)
	{
		@m_owner = owner;

		m_serverName = name;
		m_serverPlayers = players;
		m_serverPlayersMax = playersMax;

		SetText(name);

		@m_textPlayers = m_font.BuildText(players + " / " + playersMax);

		for (uint i = 0; i < dlcs.length(); i++)
			m_dlcSprites.insertLast(m_def.GetSprite("icon-dlc-" + dlcs[i]));

		/*
		string ping;

		if (lobbyPing < 0)
			ping = "?";
		else if (lobbyPing > 999)
			ping = "999";
		else
			ping = "" + lobbyPing;

		@m_textPing = m_font.BuildText(ping);
		*/
	}

	bool PassesFilter(const string &in str) override
	{
		if (m_serverName.toLower().findFirst(str) != -1)
			return true;
		return false;
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		ScalableSpriteButtonWidget::DoDraw(sb, pos);

		if (m_textPlayers !is null)
		{
			m_textPlayers.SetColor(GetTextColor());
			sb.DrawString(pos + vec2(
				m_width - m_textPlayers.GetWidth() - 10 /* - 24 */,
				m_height / 2.0f - m_textPlayers.GetHeight() / 2.0f
			), m_textPlayers);
		}

		int w = 0;
		if (m_text !is null)
			w = m_text.GetWidth();

		int dlcSpacing = 3;
		int dlcX = int(GetTextPos().x) + w + 3;

		for (uint i = 0; i < m_dlcSprites.length(); i++)
		{
			auto sprite = m_dlcSprites[i];
			if (sprite is null)
				continue;

			sb.DrawSprite(pos + vec2(
				dlcX,
				m_height / 2 - sprite.GetHeight() / 2
			), sprite, g_menuTime);
			dlcX += sprite.GetWidth() + dlcSpacing;
		}
		/*
		if (m_textPing !is null)
		{
			sb.DrawString(pos + vec2(
				m_width - m_textPing.GetWidth() - 10,
				m_height / 2.0f - m_textPing.GetHeight() / 2.0f
			), m_textPing);
		}
		*/
	}
}

ref@ LoadMenuServerListItemWidget(WidgetLoadingContext &ctx)
{
	MenuServerListItem@ w = MenuServerListItem();
	w.Load(ctx);
	return w;
}
