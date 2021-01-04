class DialogWindow : IWidgetHoster
{
	bool m_visible;

	string m_id;
	IWidgetHoster@ m_returnHost;
	string m_result;
	bool m_question;
	bool m_input;

	DialogWindow(GUIBuilder@ b)
	{
		LoadWidget(b, "gui/dialogwindow.gui");

		m_visible = false;
	}

	bool BlocksLower() override
	{
		return true;
	}

	void SetID(string id)
	{
		m_id = id;
		m_result = "cancel";
	}

	void SetQuestion(string question)
	{
		auto wQuestion = cast<TextWidget>(m_widget.GetWidgetById("question"));
		if (wQuestion !is null)
		{
			if (m_input)
				wQuestion.m_anchor.y = 0.3;
			else
				wQuestion.m_anchor.y = 0.5;
			wQuestion.SetText("\\cF8941D" + question, false);
		}

		Invalidate();
	}

	void SetButtonYes(string yes)
	{
		m_input = false;

		auto wInput = cast<TextInputWidget>(m_widget.GetWidgetById("input"));
		if (wInput !is null)
			wInput.m_parent.m_visible = false;

		auto wYes = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("yes"));
		if (wYes !is null)
		{
			auto wNo = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("no"));

			if (yes == "")
			{
				wYes.m_visible = false;
				m_question = false;
			}
			else
			{
				m_question = true;
				wYes.m_visible = true;
				wYes.SetText(yes);
			}

			Invalidate();
		}
	}

	void SetButtonNo(string no)
	{
		m_input = false;

		auto wNo = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("no"));
		if (wNo is null)
			return;

		wNo.m_visible = true;
		wNo.SetText(no);

		Invalidate();
	}

	void SetInput(string defaultText)
	{
		m_question = false;
		m_input = true;

		auto wYes = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("yes"));
		if (wYes !is null)
		{
			wYes.m_visible = true;
			wYes.SetText(Resources::GetString(".menu.accept"));
		}

		auto wNo = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("no"));
		if (wNo !is null)
		{
			wNo.m_visible = true;
			wNo.SetText(Resources::GetString(".menu.cancel"));
		}

		auto wInput = cast<TextInputWidget>(m_widget.GetWidgetById("input"));
		if (wInput !is null)
		{
			wInput.m_parent.m_visible = true;
			wInput.m_text = defaultText;
			wInput.UpdateText();
			wInput.m_cursorPos = defaultText.length();
			wInput.UpdateCursorPos();
			wInput.m_drawOffset = 0;
		}

		Invalidate();
	}

	void FocusInput()
	{
		auto wInput = cast<TextInputWidget>(m_widget.GetWidgetById("input"));
		if (wInput is null)
			return;

		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm !is null)
			@gm.m_widgetInputFocus = wInput;
	}

	void SetReturnHost(IWidgetHoster@ returnHost)
	{
		@m_returnHost = returnHost;
	}

	void Update(int dt) override
	{
		if (!m_visible)
			return;

		IWidgetHoster::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (m_visible)
			IWidgetHoster::Draw(sb, idt);
	}

	void Close()
	{
		m_visible = false;

		g_gameMode.RemoveWidgetRoot(this);

		if (m_returnHost is null)
			return;

		if (m_input)
		{
			if (m_result == "yes")
			{
				auto wInput = cast<TextInputWidget>(m_widget.GetWidgetById("input"));
				m_returnHost.OnFunc(wInput, m_id);
			}
		}
		else if (m_question)
			m_returnHost.OnFunc(null, m_id + " " + m_result);
		else
			m_returnHost.OnFunc(null, m_id);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		m_result = name;
		Close();

		IWidgetHoster::OnFunc(sender, name);
	}
}
