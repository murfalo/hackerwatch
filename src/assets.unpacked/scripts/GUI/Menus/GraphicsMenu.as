namespace Menu
{
	class GraphicsMenu : SubOptionsMenu
	{
		GraphicsMenu(MenuProvider@ provider)
		{
			super(provider);

			//TODO: Setting this menu as a popup messes up the preview panel
			//m_isPopup = true;
		}

		void Update(int dt) override
		{
			SubOptionsMenu::Update(dt);

			Menu::Backdrop@ backdrop = m_provider.m_backdrop;
			if (backdrop !is null)
			{
				Widget@ wPreview = m_widget.GetWidgetById("preview");
				if (wPreview !is null)
				{
					backdrop.m_clipping = !m_closing;
					backdrop.m_clippingRect = wPreview.GetRectangle();
				}
			}

			WorldScript::MenuAnchorPoint@ map = null;

			for (uint i = 0; i < g_menuAnchors.length(); i++)
			{
				if (g_menuAnchors[i].GraphicsOptions)
					@map = g_menuAnchors[i];
			}

			if (map is null)
				return;

			MainMenu@ gm = cast<MainMenu>(g_gameMode);
			gm.m_camPos = xy(map.Position);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			array<string> parse = name.split(" ");
			if (parse[0] == "cfg-resolution")
				OpenMenu(Menu::ResolutionsMenu(m_provider), "gui/main_menu/options_resolution.gui");
			else if (parse[0] == "accept")
			{
				Config::SaveVar("v_resolution");
				SubOptionsMenu::OnFunc(sender, "accept");
			}
			else
				SubOptionsMenu::OnFunc(sender, name);
		}
	}
}
