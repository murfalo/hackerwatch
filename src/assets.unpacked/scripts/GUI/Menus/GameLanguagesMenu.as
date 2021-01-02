namespace Menu
{
	class GameLanguagesMenu : Menu
	{
		bool m_changedLanguage;
		bool m_restartWarningShown;

		GameLanguagesMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void Initialize(GUIDef@ def) override
		{
			auto wLanguages = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
			auto wTemplate = cast<CheckBoxWidget>(m_widget.GetWidgetById("template"));
			if (wLanguages is null || wTemplate is null)
				return;

			auto arr = Platform::GetLanguages();
			for (uint i = 0; i < arr.length(); i++)
			{
				string id = arr[i].ID;

				if (id == "english")
					continue;

				auto wNewLanguage = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewLanguage.m_visible = true;
				wNewLanguage.SetID("");
				wNewLanguage.m_value = id;
				wNewLanguage.SetText(arr[i].Name);
				wLanguages.AddChild(wNewLanguage);
			}

			string currentLanguage = GetVarString("g_language");
			wLanguages.SetChecked(currentLanguage);
		}

		bool Close() override
		{
			if (!m_changedLanguage || m_restartWarningShown)
				return Menu::Close();

			m_restartWarningShown = true;
			g_gameMode.ShowDialog("restart-ok", Resources::GetString(".mainmenu.languages.restart-confirm"), Resources::GetString(".menu.ok"), this);
			return false;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			array<string> parse = name.split(" ");
			if (parse[0] == "set-language")
			{
				auto wLanguages = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
				if (wLanguages !is null)
				{
					ICheckableWidget@ wChecked = wLanguages.GetChecked();
					if (wChecked !is null)
					{
						m_changedLanguage = true;
						SetVar("g_language", wChecked.GetValue());
						Config::SaveVar("g_language");
					}
				}
			}
			else if (parse[0] == "restart-ok")
				Close();
			else
				Menu::OnFunc(sender, name);
		}
	}
}
