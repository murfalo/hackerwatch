class GuildHallMenu : UserWindow
{
	MenuTabSystem@ m_tabSystem;

	GuildHallMenu(GUIBuilder@ b)
	{
		super(b, "gui/guildhallmenu.gui");

		@m_tabSystem = MenuTabSystem(this);

		m_tabSystem.AddTab(GuildHallStatsTab());
		m_tabSystem.AddTab(GuildHallAccomplishmentsTab());
		m_tabSystem.AddTab(GuildHallBeastiaryTab());
		m_tabSystem.AddTab(GuildHallItemiaryTab());
	}

	bool BlocksLower() override
	{
		return true;
	}

	string GetScriptID() override { return "guildhall"; }

	void SetTab(string id)
	{
		GlobalCache::Set("guildhallmenu-tab", id);

		m_tabSystem.SetTab(id);
	}

	void Show() override
	{
		if (m_visible)
			return;

		UserWindow::Show();

		PauseGame(true, true);

		string startTab = GlobalCache::Get("guildhallmenu-tab");
		if (startTab == "")
			startTab = "stats";

		SetTab(startTab);
	}

	void Close() override
	{
		if (!m_visible)
			return;

		m_tabSystem.Close();

		UserWindow::Close();

		PauseGame(false, true);
	}

	void DoLayout() override
	{
		bool invalidated = m_invalidated;

		UserWindow::DoLayout();

		if (invalidated)
			m_tabSystem.DoLayout();
	}

	void Update(int dt) override
	{
		if (m_visible)
			m_tabSystem.Update(dt);

		UserWindow::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (!m_visible)
			return;

		UserWindow::Draw(sb, idt);

		m_tabSystem.Draw(sb, idt);
	}

	void AfterUpdate()
	{
		if (m_visible)
			m_tabSystem.AfterUpdate();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Close();
		else if (!m_tabSystem.OnFunc(sender, name))
			UserWindow::OnFunc(sender, name);
	}
}
