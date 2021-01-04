namespace Menu
{
	class SubOptionsMenu : Menu
	{
		string m_optionsListName = "options-list";

		SubOptionsMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void CancelCvarWidgets(string listID)
		{
			auto wList = m_widget.GetWidgetById(listID);
			if (wList is null)
				return;
			CancelCvarWidgetsInternal(wList);
		}

		void CancelCvarWidgetsInternal(Widget@ wList)
		{
			for (uint i = 0; i < wList.m_children.length(); i++)
			{
				auto wCheckGroup = cast<CheckBoxGroupWidget>(wList.m_children[i]);
				if (wCheckGroup !is null)
				{
					wCheckGroup.Cancel();
					continue;
				}

				auto wSlider = cast<SliderWidget>(wList.m_children[i]);
				if (wSlider !is null)
				{
					wSlider.Cancel();
					continue;
				}

				CancelCvarWidgetsInternal(wList.m_children[i]);
			}
		}

		void SaveCvarWidgets(string listID)
		{
			auto wList = m_widget.GetWidgetById(listID);
			if (wList is null)
				return;
			SaveCvarWidgetsInternal(wList);
		}

		void SaveCvarWidgetsInternal(Widget@ wList)
		{
			for (uint i = 0; i < wList.m_children.length(); i++)
			{
				auto wCheckGroup = cast<CheckBoxGroupWidget>(wList.m_children[i]);
				if (wCheckGroup !is null)
				{
					wCheckGroup.Save();
					continue;
				}

				auto wSlider = cast<SliderWidget>(wList.m_children[i]);
				if (wSlider !is null)
				{
					wSlider.Save();
					continue;
				}

				auto wCheckbox = cast<CheckBoxWidget>(wList.m_children[i]);
				if (wCheckbox !is null)
				{
					wCheckbox.Save();
					continue;
				}

				SaveCvarWidgetsInternal(wList.m_children[i]);
			}
		}

		void ResetCvarWidgets(string listID)
		{
			auto wList = m_widget.GetWidgetById(listID);
			if (wList is null)
				return;
			ResetCvarWidgetsInternal(wList);
		}

		void ResetCvarWidgetsInternal(Widget@ wList)
		{
			for (uint i = 0; i < wList.m_children.length(); i++)
			{
				auto wCheckGroup = cast<CheckBoxGroupWidget>(wList.m_children[i]);
				if (wCheckGroup !is null)
				{
					wCheckGroup.Reset();
					continue;
				}

				auto wSlider = cast<SliderWidget>(wList.m_children[i]);
				if (wSlider !is null)
				{
					wSlider.Reset();
					continue;
				}

				ResetCvarWidgetsInternal(wList.m_children[i]);
			}
		}

		bool AnyCvarChanged(string listID)
		{
			auto wList = m_widget.GetWidgetById(listID);
			if (wList is null)
				return false;
			return AnyCvarChangedInternal(wList);
		}

		bool AnyCvarChangedInternal(Widget@ wList)
		{
			for (uint i = 0; i < wList.m_children.length(); i++)
			{
				auto wCheckGroup = cast<CheckBoxGroupWidget>(wList.m_children[i]);
				if (wCheckGroup !is null && wCheckGroup.IsChanged())
					return true;

				auto wSlider = cast<SliderWidget>(wList.m_children[i]);
				if (wSlider !is null && wSlider.IsChanged())
					return true;

				auto wCheckbox = cast<CheckBoxWidget>(wList.m_children[i]);
				if (wCheckbox !is null && wCheckbox.IsChanged())
					return true;

				if (AnyCvarChangedInternal(wList.m_children[i]))
					return true;
			}
			return false;
		}

		bool GoBack() override
		{
			OnFunc(null, "back");
			return true;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "defaults")
				g_gameMode.ShowDialog(
					"defaults",
					Resources::GetString(".menu.defaults_dialog"),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					this
				);
			else if (name == "defaults yes")
				ResetCvarWidgets(m_optionsListName);
			else if (name == "back")
			{
				if (AnyCvarChanged(m_optionsListName))
					g_gameMode.ShowDialog(
						"cancel",
						Resources::GetString(".menu.unsaved_dialog"),
						Resources::GetString(".menu.yes"),
						Resources::GetString(".menu.no"),
						this
					);
				else
					Close();
			}
			else if (name == "cancel yes")
			{
				SaveCvarWidgets(m_optionsListName);
				Close();
			}
			else if (name == "cancel no")
			{
				CancelCvarWidgets(m_optionsListName);
				Close();
			}
			else
			{
				array<string> parse = name.split(" ");
				if (parse[0] == "cfg-set")
					SetVar(parse[1], parse[2]);
				else if (parse[0] == "cfg-radio")
				{
					auto wGroup = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById(parse[1]));
					if (wGroup !is null)
					{
						ICheckableWidget@ checkable = wGroup.GetChecked();
						if (checkable !is null)
						{
							cvar_type cvarType = GetVarType(wGroup.m_cvar);
							if (cvarType == cvar_type::String)
								SetVar(wGroup.m_cvar, checkable.GetValue());
							else if (cvarType == cvar_type::Int)
								SetVar(wGroup.m_cvar, parseInt(checkable.GetValue()));
							else if (cvarType == cvar_type::Float)
								SetVar(wGroup.m_cvar, parseFloat(checkable.GetValue()));
							else if (cvarType == cvar_type::Bool)
								SetVar(wGroup.m_cvar, checkable.GetValue() == "true");
						}
					}
				}
				else if (parse[0] == "cfg-check")
				{
					auto check = cast<CheckBoxWidget>(sender);
					if (check !is null)
					{
						cvar_type cvarType = GetVarType(parse[1]);
						if (cvarType == cvar_type::Bool)
							SetVar(parse[1], check.IsChecked());
					}
				}
				else if (parse[0] == "accept")
				{
					SaveCvarWidgets(m_optionsListName);
					OnFunc(sender, "back");
				}
				else
					Menu::OnFunc(sender, name);
			}
		}
	}
}
