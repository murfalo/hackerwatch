namespace Menu
{
	class MenuStyleMenu : Menu
	{
		CheckBoxGroupWidget@ m_wList;

		MenuStyleMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
			auto wTemplate = m_widget.GetWidgetById("template");

			string currentStyle = GetVarString("g_menustyle");

			auto svStyles = Resources::GetSValue("tweak/menustyles.sval");
			auto svdicStyles = GetParamDictionary(UnitPtr(), svStyles, "styles");
			auto arrKeys = svdicStyles.GetDictionary().getKeys();
			for (uint i = 0; i < arrKeys.length(); i++)
			{
				string id = arrKeys[i];
				auto svStyle = svdicStyles.GetDictionaryEntry(id);

				string name = GetParamString(UnitPtr(), svStyle, "name");
				string dlc = GetParamString(UnitPtr(), svStyle, "dlc", false);

				auto wNewItem = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewItem.SetID("");
				wNewItem.m_visible = true;

				wNewItem.m_value = id;
				wNewItem.SetText(Resources::GetString(name));

				if (dlc != "")
					wNewItem.m_enabled = Platform::HasDLC(dlc);

				m_wList.AddChild(wNewItem);
			}

			m_wList.SetChecked(currentStyle);
		}

		bool Close() override
		{
			Config::SaveVar("g_menustyle");

			return Menu::Close();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "set-style")
			{
				auto checked = m_wList.GetChecked();
				string style = checked.GetValue();
				SetVar("g_menustyle", style);

				auto gm = cast<MainMenu>(g_gameMode);
				gm.SetMenuStyle(style);
			}
			else
				Menu::OnFunc(sender, name);
		}
	}
}
