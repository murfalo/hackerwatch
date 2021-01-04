namespace Menu
{
	class ResolutionsMenu : Menu
	{
		ResolutionsMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			//TODO: What do we do if we have multiple monitors?
			//      Do we merge the resolution list from that?
			//      Or do we let the user pick which monitor to use?
			array<ivec2> resolutions = Platform::GetResolutions();

			auto wTemplate = m_widget.GetWidgetById("template");
			if (wTemplate is null)
				return;

			auto wResolutions = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
			if (wResolutions !is null)
			{
				for (uint i = 0; i < resolutions.length(); i++)
				{
					auto res = resolutions[i];
					auto wNewItem = cast<CheckBoxWidget>(wTemplate.Clone());
					wNewItem.SetID("");
					wNewItem.m_visible = true;
					wNewItem.m_value = res.x + "x" + res.y;
					wNewItem.m_func = "set-resolution " + res.x + "x" + res.y;
					wNewItem.SetText(wNewItem.m_value);
					wResolutions.AddChild(wNewItem);
				}
			}

			ivec2 currentResolution = GetVarIvec2("v_resolution");
			wResolutions.SetChecked(currentResolution.x + "x" + currentResolution.y);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			array<string> parse = name.split(" ");
			if (parse[0] == "set-resolution")
				SetVar("v_resolution", ParseVarIvec2(parse[1]));
			else
				Menu::OnFunc(sender, name);
		}
	}
}
