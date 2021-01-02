namespace Menu
{
	class MultiplayerMenu : Menu
	{
		array<ButtonWidget@> m_onlineWidgets;

		MultiplayerMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			Menu::Initialize(def);

			m_onlineWidgets.insertLast(cast<ButtonWidget>(m_widget.GetWidgetById("createlobby")));
			m_onlineWidgets.insertLast(cast<ButtonWidget>(m_widget.GetWidgetById("serverlist")));
			m_onlineWidgets.insertLast(cast<ButtonWidget>(m_widget.GetWidgetById("loadgame")));
		}

		void Update(int dt) override
		{
			bool onlineAvailable = Platform::Service.IsMultiplayerAvailable();
			for (uint i = 0; i < m_onlineWidgets.length(); i++)
				m_onlineWidgets[i].SetEnabled(onlineAvailable);

			Menu::Update(dt);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			/*if (name == "createlobby")
				OpenMenu(Menu::LobbyMenu(m_provider, true), "gui/main_menu/lobby.gui");
			else*/ if (name == "serverlist")
				OpenMenu(Menu::ServerlistMenu(m_provider), "gui/main_menu/serverlist.gui");
			/*else if (name == "loadgame")
				OpenMenu(LoadGameMenu(m_provider, true), "gui/main_menu/loadgame.gui");
			else if (name == "splitscreen")
				OpenMenu(SplitscreenMenu(m_provider), "gui/main_menu/splitscreen.gui");*/

			else
				Menu::OnFunc(sender, name);
		}
	}
}
