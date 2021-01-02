class MercenaryLedger : UserWindow
{
	MenuTabSystem@ m_tabSystem;

	MercenaryLedger(GUIBuilder@ b)
	{
		super(b, "gui/town/mercenaryledger.gui");

		@m_tabSystem = MenuTabSystem(this);
		m_tabSystem.AddTab(MercenaryLedgerInfoTab());
		m_tabSystem.AddTab(MercenaryLedgerCompanyTab());
		m_tabSystem.AddTab(MercenaryLedgerEnlistedTab());
		m_tabSystem.AddTab(MercenaryLedgerDeceasedTab(this));
		m_tabSystem.AddTab(GuildHallBeastiaryTab());
		m_tabSystem.AddTab(GuildHallItemiaryTab());
	}

	string GetScriptID() override { return "mercenaryledger"; }

	void Show() override
	{
		if (m_visible)
			return;

		UserWindow::Show();

		PauseGame(true, true);

		m_tabSystem.SetTab("company");
	}

	void Close() override
	{
		if (!m_visible)
			return;

		m_tabSystem.Close();

		UserWindow::Close();

		PauseGame(false, true);
	}

	void Update(int dt) override
	{
		m_tabSystem.Update(dt);

		UserWindow::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		UserWindow::Draw(sb, idt);

		m_tabSystem.Draw(sb, idt);
	}

	void DoLayout() override
	{
		bool invalidated = m_invalidated;

		UserWindow::DoLayout();

		if (invalidated)
			m_tabSystem.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "stop")
			Close();
		else if (!m_tabSystem.OnFunc(sender, name))
			UserWindow::OnFunc(sender, name);
	}
}
