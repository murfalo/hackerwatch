class ShopMenu : UserWindow
{
	GUIBuilder@ m_guiBuilder;

	SoundEvent@ m_sndBuyGold;
	SoundEvent@ m_sndBuyOre;
	SoundEvent@ m_sndBuySkill;
	SoundEvent@ m_sndBuyFree;
	SoundEvent@ m_sndCantBuy;

	Widget@ m_wStars;
	Widget@ m_wLevelList;
	SpriteWidget@ m_wLevelTemplate;

	TextWidget@ m_wName;

	Widget@ m_wInnerFrame;
	Widget@ m_wTitle;
	Widget@ m_wTitleSeparator;
	Widget@ m_wContent;
	ShopMenuContent@ m_menuContent;

	WorldScript::ShopArea@ m_shopArea;

	int m_currentShopLevel;

	bool m_upgradedBuilding;

	ShopMenu(GUIBuilder@ b)
	{
		super(b, "gui/shop.gui");

		@m_guiBuilder = b;

		@m_sndBuyGold = Resources::GetSoundEvent("event:/ui/buy_gold");
		@m_sndBuyOre = Resources::GetSoundEvent("event:/ui/buy_ore");
		@m_sndBuySkill = Resources::GetSoundEvent("event:/ui/buy_skill");
		@m_sndBuyFree = Resources::GetSoundEvent("event:/ui/buy_skill");//buy_free");
		@m_sndCantBuy = Resources::GetSoundEvent("event:/ui/cant_buy");

		@m_wStars = m_widget.GetWidgetById("stars");
		@m_wLevelList = m_widget.GetWidgetById("level-list");
		@m_wLevelTemplate = cast<SpriteWidget>(m_widget.GetWidgetById("level-template"));

		@m_wName = cast<TextWidget>(m_widget.GetWidgetById("name"));

		@m_wInnerFrame = m_widget.GetWidgetById("inner-frame");
		@m_wTitle = m_widget.GetWidgetById("title");
		@m_wTitleSeparator = m_widget.GetWidgetById("title-separator");
		@m_wContent = m_widget.GetWidgetById("content");
	}

	void Show(ShopMenuContent@ menuContent, int shopLevel)
	{
		PrintError("Deprecated function called: ShopMenu::Show with 2 parameters!");
		DumpStack();

		Show(null, menuContent, shopLevel);
	}

	void Show(WorldScript::ShopArea@ shopArea, ShopMenuContent@ menuContent, int shopLevel)
	{
		@m_shopArea = shopArea;

		if (m_menuContent !is null)
		{
			m_wContent.ClearChildren();
			@m_menuContent.m_widget = null;
		}

		m_wStars.m_visible = menuContent.ShouldShowStars();

		m_currentShopLevel = shopLevel;
		@m_menuContent = menuContent;
		@m_menuContent.m_def = m_wContent.AddResource(m_guiBuilder, m_menuContent.GetGuiFilename());
		@m_menuContent.m_widget = m_wContent;
		m_menuContent.OnShow();

		cast<BaseGameMode>(g_gameMode).ShowUserWindow(this);

		m_wInnerFrame.m_width = m_wContent.m_width + 4; // 2 left border + 2 right border

		m_wTitle.m_width = m_wContent.m_width - 21; // 21 close button
		m_wTitleSeparator.m_width = m_wContent.m_width;

		Invalidate();
	}

	void Show() override
	{
		m_wName.SetText(m_menuContent.GetTitle());

		m_wLevelList.ClearChildren();
		for (int i = 0; i < m_currentShopLevel; i++)
		{
			auto wNewIcon = cast<SpriteWidget>(m_wLevelTemplate.Clone());
			wNewIcon.m_visible = true;
			wNewIcon.SetID("");
			wNewIcon.SetSprite("shop-level-" + (i + 1));
			m_wLevelList.AddChild(wNewIcon);
		}

		UserWindow::Show();

		if (!g_isTown)
			PauseGame(true, true);
	}

	void Close() override
	{
		if (!m_visible)
			return;

		UserWindow::Close();

		if (!g_isTown)
			PauseGame(false, true);

		if (m_menuContent !is null)
			m_menuContent.OnClose();

		if (m_upgradedBuilding)
			ChangeLevel(GetCurrentLevelFilename());
	}

	void Update(int dt) override
	{
		if (m_visible)
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			if (gm.m_widgetInputFocus is null)
			{
				auto input = GetInput();
				if (input.PlayerMenu.Pressed)
					Close();
			}
		}

		if (m_menuContent !is null)
			m_menuContent.Update(dt);

		UserWindow::Update(dt);
	}

	void DoLayout() override
	{
		m_wInnerFrame.m_height = m_wContent.m_height + 25; // 2 top border + 21 header + 2 bottom border

		UserWindow::DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (m_menuContent !is null)
			m_menuContent.OnFunc(sender, name);

		UserWindow::OnFunc(sender, name);
	}
}
