class UserWindow : IWidgetHoster
{
	bool m_visible;

	UserWindow(GUIBuilder@ b, string filename)
	{
		LoadWidget(b, filename);
	}

	string GetScriptID() { return ""; }

	bool IsVisible() { return m_visible; }

	void Show()
	{
		if (m_visible)
			return;

		m_visible = true;
		g_gameMode.AddWidgetRoot(this);

		Invalidate();
	}

	void Close()
	{
		if (!m_visible)
			return;

		m_visible = false;
		g_gameMode.RemoveWidgetRoot(this);

		CloseTooltip();
	}

	void CloseTooltip()
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm !is null)
			gm.m_tooltip.Hide();
	}

	void Update(int dt) override
	{
		if (m_visible)
			IWidgetHoster::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (m_visible)
			IWidgetHoster::Draw(sb, idt);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Close();
	}
}
