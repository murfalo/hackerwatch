class GameChatWidget : RectWidget
{
	ScrollableWidget@ m_wList;
	Widget@ m_wTemplate;
	TextInputWidget@ m_wInput;

	int m_visibleCounter;

	GameChatWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		RectWidget::Load(ctx);
	}

	void Initialize()
	{
		@m_wList = cast<ScrollableWidget>(GetWidgetById("chat-list"));
		@m_wTemplate = GetWidgetById("chat-template");
		@m_wInput = cast<TextInputWidget>(GetWidgetById("chat-input"));
	}

	void Update(int dt) override
	{
		RectWidget::Update(dt);

		if (m_visibleCounter > 0)
			m_visibleCounter = max(0, m_visibleCounter - dt);
	}

	void AddChat(string str, vec4 color = vec4(1, 1, 1, 1))
	{
		if (str == "")
			return;

		if (m_wList is null || m_wTemplate is null)
		{
			PrintError("No chat list or template!");
			return;
		}

		m_visibleCounter = GetVarInt("ui_chat_fade_time");

		TextWidget@ wNewChat = cast<TextWidget>(m_wTemplate.Clone());
		wNewChat.m_visible = true;
		wNewChat.SetID("");
		m_wList.AddChild(wNewChat);

		bool customColor = (str.findFirst("\\c") != -1);
		wNewChat.SetText(str, !customColor);
		if (!customColor)
			wNewChat.SetColor(color);

		m_wList.ScrollDown();
	}

	void PlayerChat(uint8 peer, string message)
	{
		string playerColor = GetPlayerColor(peer);
		string playerName = EscapeString(Lobby::GetPlayerName(peer));
		string playerMessage = EscapeString(message);

		AddChat("\\c" + playerColor + playerName + "\\d: " + playerMessage);

		cast<MainMenu>(g_gameMode).HandleChatMessage(peer, message);
	}

	void PlayerSystem(uint8 peer, string message)
	{
		string playerColor = GetPlayerColor(peer);
		string playerName = EscapeString(Lobby::GetPlayerName(peer));

		AddChat(Resources::GetString(message, { { "name", "\\c" + playerColor + playerName + "\\d" } }));
	}
}

ref@ LoadGameChatWidget(WidgetLoadingContext &ctx)
{
	GameChatWidget@ w = GameChatWidget();
	w.Load(ctx);
	return w;
}
