namespace Menu
{
	class ControlMapMenu : Menu
	{
		ControlMap@ m_map;
		string m_mapID;

		RectWidget@ m_wTemplate;
		Widget@ m_wControls;

		ControlMapMenu(MenuProvider@ provider, string mapID)
		{
			m_mapID = mapID;

			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			auto cb = GetControlBindings();

			@m_map = cb.GetMap(m_mapID);
			if (m_map is null)
			{
				PrintError("Control map \"" + m_mapID + "\" was not found!");
				return;
			}

			m_map.BeginStaging();

			@m_wTemplate = cast<RectWidget>(m_widget.GetWidgetById("template"));
			@m_wControls = m_widget.GetWidgetById("controls");

			if (m_wTemplate is null)
				return;

			if (m_mapID == "kbm")
			{
				AddNewControlAxis(false, "move_y", ControlBindingSetAxis::Low);
				AddNewControlAxis(true, "move_y", ControlBindingSetAxis::High);
				AddNewControlAxis(false, "move_x", ControlBindingSetAxis::Low);
				AddNewControlAxis(true, "move_x", ControlBindingSetAxis::High);
			}

			array<string>@ actions = cb.GetAvailableActions();
			for (uint i = 0; i < actions.length(); i++)
				AddNewControl(i % 2 == 1, actions[i]);
		}

		void AddNewControlAxis(bool uneven, string action, ControlBindingSetAxis setAxis)
		{
			Widget@ w = AddNewControl(uneven, action);

			MenuControlInputWidget@ wInput = cast<MenuControlInputWidget>(w.GetWidgetById("button"));
			wInput.m_axisAction = true;
			wInput.m_axisSet = setAxis;
			wInput.UpdateText();

			TextWidget@ wName = cast<TextWidget>(w.GetWidgetById("name"));
			if (wName !is null)
				wName.SetText(Resources::GetString(".menu.controls." + action.toLower() + ".axis" + setAxis));
		}

		Widget@ AddNewControl(bool uneven, string action)
		{
			RectWidget@ wNewControl = cast<RectWidget>(m_wTemplate.Clone());
			wNewControl.m_visible = true;
			wNewControl.SetID("");

			if (uneven)
				wNewControl.m_color = tocolor(vec4(0.9, 0.9, 1, 0.05));

			TextWidget@ wName = cast<TextWidget>(wNewControl.GetWidgetById("name"));
			if (wName !is null)
			{
				wName.SetText(Resources::GetString(".menu.controls." + action.toLower()));
				if (action.substr(0, 6) == "Weapon")
					wName.m_tooltipText = Resources::GetString(".menu.controls." + action.toLower() + ".help");
			}

			MenuControlInputWidget@ wInput = cast<MenuControlInputWidget>(wNewControl.GetWidgetById("button"));
			if (wInput !is null)
			{
				@wInput.m_map = m_map;
				wInput.m_func = action;
				wInput.UpdateText();
			}

			m_wControls.AddChild(wNewControl);

			return wNewControl;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "reset-controls")
			{
				g_gameMode.ShowDialog(
					"reset-controls",
					Resources::GetString(".menu.controls.defaults_dialog"),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					this
				);
			}
			else if (name == "reset-controls yes")
			{
				m_map.Defaults();
				m_map.BeginStaging();

				for (uint i = 0; i < m_wControls.m_children.length(); i++)
				{
					Widget@ wBox = m_wControls.m_children[i];
					MenuControlInputWidget@ wInput = cast<MenuControlInputWidget>(wBox.GetWidgetById("button"));
					if (wInput !is null)
						wInput.UpdateText();
				}
			}
			else if (name == "apply-controls")
			{
				m_map.CommitStaging();

				auto cb = GetControlBindings();
				if (cb !is null)
					cb.Save();

				Close();
			}
			else
				Menu::OnFunc(sender, name);
		}
	}
}
