namespace Menu
{
	class ControlsMenu : Menu
	{
		ControlsMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			Widget@ wMaps = m_widget.GetWidgetById("maps");
			if (wMaps is null)
				return;

			auto wTemplate = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("maps-template"));
			if (wTemplate is null)
				return;

			auto cb = GetControlBindings();

			array<ControlMap@>@ arrMaps = cb.GetMaps();
			for (uint i = 0; i < arrMaps.length(); i++)
			{
				ControlMap@ map = arrMaps[i];

				auto wNewItem = cast<ScalableSpriteButtonWidget>(wTemplate.Clone());
				wNewItem.m_visible = true;
				wNewItem.SetID("");
				wNewItem.SetText(Resources::GetString(".menu.controls.layout." + map.ID));
				wNewItem.m_tooltipText = map.GetName();
				if (map.SteamController)
					wNewItem.m_func = "map-sc " + map.Handle;
				else
					wNewItem.m_func = "map " + map.ID;
				wMaps.AddChild(wNewItem);
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			array<string> parse = name.split(" ");
			if (parse[0] == "map")
				OpenMenu(ControlMapMenu(m_provider, parse[1]), "gui/main_menu/options_controlmap.gui");
			else if (parse[0] == "map-sc")
			{
				if (!Platform::Service.ControllerInterface(parseUInt(parse[1])))
					g_gameMode.ShowDialog("", Resources::GetString(".menu.controls.scinputs.prompt"), Resources::GetString(".menu.ok"), this);
			}
			else
				Menu::OnFunc(sender, name);
		}
	}
}
