class MenuProvider
{
	array<Menu::Menu@> m_menus;
	bool m_visible;

	SValue@ m_style;

	Menu::Backdrop@ m_backdrop;

	MenuProvider()
	{
	}

	void Initialize(GUIBuilder@ b, Menu::Menu@ menu, string initFile, Menu::Backdrop@ backdrop = null)
	{
		m_menus.insertLast(menu);
		menu.Initialize(menu.LoadWidget(b, initFile));

		if (backdrop !is null)
			@m_backdrop = backdrop;

		GetCurrentMenu().SetActive();
	}

	void SetStyle(GUIBuilder@ b, SValue@ svStyle)
	{
		@m_style = svStyle;

		string backdropGui = GetParamString(UnitPtr(), svStyle, "backdrop-gui");
		string backdropParallax = GetParamString(UnitPtr(), svStyle, "backdrop-parallax");

		@m_backdrop = Menu::Backdrop(b, backdropGui, backdropParallax);

		if (m_backdrop.m_widget is null)
			@m_backdrop = null;

		for (uint i = 0; i < m_menus.length(); i++)
			m_menus[i].SetStyle(svStyle);
	}

	// Gets the currently active menu (including popup menus)
	Menu::Menu@ GetCurrentMenu()
	{
		return m_menus[m_menus.length() - 1];
	}

	// Gets the currently active main menu (excluding popup menus)
	Menu::Menu@ GetTopmostMenu()
	{
		for (uint i = m_menus.length() - 1; i >= 0; i--)
		{
			if (!m_menus[i].m_isPopup)
				return m_menus[i];
		}
		return null;
	}

	bool GoBack()
	{
		return GetCurrentMenu().GoBack();
	}

	void Update(int ms, GameInput& gameInput, MenuInput& menuInput)
	{
		if (m_backdrop !is null)
			m_backdrop.Update(ms);

		for (uint i = 0; i < m_menus.length(); i++)
			m_menus[i].Update(ms);

		Menu::Menu@ curr = GetCurrentMenu();
		if (curr.m_closing)
		{
			m_menus.removeAt(m_menus.length() - 1);
			GetCurrentMenu().SetActive();
		}
	}

	void Render(int idt, SpriteBatch& sb)
	{
		if (m_backdrop !is null)
			m_backdrop.Draw(sb, idt);

		uint startMenu = 0;
		uint popupMenu = 0;

		for (uint i = m_menus.length() - 1; i >= 0; i--)
		{
			if (!m_menus[i].m_isPopup)
			{
				startMenu = i;
				break;
			}
			else
				popupMenu = i;
		}

		int w = g_gameMode.m_wndWidth;
		int h = g_gameMode.m_wndHeight;

		for (uint i = startMenu; i < m_menus.length(); i++)
		{
			sb.Begin(w, h, 0.5);

			if (popupMenu > 0 && popupMenu == i)
				sb.FillRectangle(vec4(0, 0, w, h), vec4(0, 0, 0, 0.75));

			m_menus[i].Draw(sb, idt);
			
			sb.End();
		}

		if (g_gameMode.m_dialogWindow !is null)
			g_gameMode.m_dialogWindow.Draw(sb, idt);
	}
}
