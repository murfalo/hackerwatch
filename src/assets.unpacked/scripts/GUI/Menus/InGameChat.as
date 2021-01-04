namespace Menu
{
	class InGameChat : IWidgetHoster
	{
		bool m_active;

		TransformWidget@ m_wTransform;
		GameChatWidget@ m_wGameChat;

		InGameChat()
		{
			super();
		}

		void Initialize(GUIBuilder@ b, string filename)
		{
			LoadWidget(b, filename);

			@m_wTransform = cast<TransformWidget>(m_widget.GetWidgetById("transform"));
			@m_wGameChat = cast<GameChatWidget>(m_widget.GetWidgetById("gamechat"));

			m_active = Lobby::IsInLobby();
			if (m_active)
			{
				auto main = cast<MainMenu>(g_gameMode);
				if (main !is null)
				{
					@main.m_wChat = m_wGameChat;
					if (main.m_wChat !is null)
						main.m_wChat.Initialize();
				}
			}
		}

		void BeginInput()
		{
			auto main = cast<MainMenu>(g_gameMode);
			if (main is null || main.m_wChat is null || main.m_wChat.m_wInput is null)
				return;

			auto wInputBox = m_widget.GetWidgetById("chat-input-box");
			if (wInputBox is null)
				return;

			main.m_wChat.m_visibleCounter = 4000;

			if (!wInputBox.m_visible)
			{
				wInputBox.m_visible = true;

				auto cb = GetControlBindings();
				if (cb !is null)
					cb.ExpectTextInput();

				g_gameMode.AddWidgetRoot(this);
				@g_gameMode.m_widgetInputFocus = main.m_wChat.m_wInput;
			}
		}

		void StopInput()
		{
			auto main = cast<MainMenu>(g_gameMode);
			if (main is null || main.m_wChat is null || main.m_wChat.m_wInput is null)
				return;

			main.m_wChat.m_wInput.ClearText();

			auto wInputBox = m_widget.GetWidgetById("chat-input-box");
			if (wInputBox !is null)
			{
				if (!wInputBox.m_visible)
					return;
				wInputBox.m_visible = false;
			}

			auto cb = GetControlBindings();
			if (cb !is null)
				cb.StopExpectTextInput();

			g_gameMode.RemoveWidgetRoot(this);
			@g_gameMode.m_widgetInputFocus = null;
		}

		void Update(int dt, MenuInput& menuInput)
		{
			if (!m_active)
				return;

			m_wTransform.m_scale = GetVarFloat("ui_chat_scale");
			m_wGameChat.m_widthScalar = GetVarFloat("ui_chat_width");
			m_wGameChat.m_anchor = GetVarVec2("ui_chat_pos");

			IWidgetHoster::Update(dt);

			auto main = cast<MainMenu>(g_gameMode);
			if (main is null || main.m_wChat is null || main.m_wChat.m_wInput is null)
				return;

			auto wBox = m_widget.GetWidgetById("chat-box");
			if (wBox is null)
				return;

			auto wInputBox = m_widget.GetWidgetById("chat-input-box");
			if (wInputBox is null)
				return;

			// This is a workaround for a bug where chat input is expected but text input is unexpected after a map switch
			if (wInputBox.m_visible)
			{
				auto cb = GetControlBindings();
				if (cb !is null && !cb.IsExpectingTextInput())
					cb.ExpectTextInput();
			}

			if (menuInput.ChatAll.Pressed)
				BeginInput();

			wBox.m_visible = (main.m_wChat.m_visibleCounter != 0 || wInputBox.m_visible);
		}

		void Draw(SpriteBatch& sb, int idt) override
		{
			if (!m_active)
				return;

			IWidgetHoster::Draw(sb, idt);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto main = cast<MainMenu>(g_gameMode);
			if (main is null || main.m_wChat is null || main.m_wChat.m_wInput is null)
				return;

			if (name == "sendchat" || name == "cancelchat")
			{
				string text = strTrim(main.m_wChat.m_wInput.m_text.plain());
				if (text != "" && name == "sendchat")
				{
					main.m_wChat.PlayerChat(Lobby::GetLocalPeer(), text);
					Lobby::SendChatMessage(text);
				}
				StopInput();
			}
		}
	}
}
