namespace Menu
{
	class Menu : IWidgetHoster
	{
		MenuProvider@ m_provider;

		bool m_isPopup;
		bool m_closing;

		Menu(MenuProvider@ provider)
		{
			@m_provider = provider;

			m_isPopup = false;
			m_closing = false;
		}

		void Initialize(GUIDef@ def) {}

		void SetStyle(SValue@ svStyle) {}

		void SetActive()
		{
			g_gameMode.ReplaceTopWidgetRoot(this);
			SetStyle(m_provider.m_style);
		}

		void OpenMenu(string path)
		{
			Menu::SimpleMenu@ menu = Menu::SimpleMenu(m_provider);
			m_provider.m_menus.insertLast(menu);
			GUIDef@ def = menu.LoadWidget(g_gameMode.m_guiBuilder, path);
			menu.Initialize(def);
			menu.SetActive();
		}

		void OpenMenu(Menu::Menu@ menu, string path, int index = -1)
		{
			if (index == -1)
				m_provider.m_menus.insertLast(menu);
			else
				m_provider.m_menus.insertAt(index, menu);

			GUIDef@ def = menu.LoadWidget(g_gameMode.m_guiBuilder, path);
			menu.Initialize(def);
			menu.SetActive();

			auto gm = cast<BaseGameMode>(g_gameMode);
			if (gm !is null)
				gm.CenterMousePos();
		}

		bool GoBack()
		{
			return Close();
		}

		bool ShouldDisplayCursor() { return true; }

		bool Close()
		{
			if (m_closing)
				return true;

			BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
			if (gm !is null)
			{
				gm.m_tooltip.Hide();
				gm.CenterMousePos();
			}

			m_provider.m_menus[m_provider.m_menus.length() - 2].Show();
			m_closing = true;

			return true;
		}

		bool Close(int num)
		{
			if (m_closing)
				return true;

			BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
			if (gm !is null)
				gm.m_tooltip.Hide();

			for (int i = m_provider.m_menus.length() - 1; i > m_provider.m_menus.length() - (num + 1); i--)
				m_provider.m_menus[i].m_closing = true;
			m_provider.m_menus[m_provider.m_menus.length() - (num + 1)].Show();

			return true;
		}

		bool RemoveFromProvider()
		{
			int index = m_provider.m_menus.findByRef(this);
			if (index != -1)
			{
				m_provider.m_menus.removeAt(index);
				return true;
			}
			return false;
		}

		void PopFromProvider(int num)
		{
			int index = m_provider.m_menus.findByRef(this);
			if (index == -1)
				return;

			for (int i = index; i >= max(index - num + 1, 0); i--)
				m_provider.m_menus.removeAt(i);
		}

		void Show()
		{
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "connectionlost")
				StopScenario();
			else if (name == "back")
				Close();
		}
	}
}
