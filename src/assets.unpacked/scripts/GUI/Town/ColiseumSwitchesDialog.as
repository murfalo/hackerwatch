class ColiseumSwitchesDialog : IWidgetHoster
{
	ColiseumNPC@ m_owner;

	ColiseumSwitchesDialog(GUIBuilder@ b, ColiseumNPC@ owner)
	{
		LoadWidget(b, "gui/town/coliseum_switches.gui");

		@m_owner = owner;

		auto wList = m_widget.GetWidgetById("list");
		auto wTemplate = m_widget.GetWidgetById("template");

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < SurvivalSwitches::g_switches.length(); i++)
		{
			auto sw = SurvivalSwitches::g_switches[i];

			auto wNewItem = cast<CheckBoxWidget>(wTemplate.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.SetText(Resources::GetString(sw.m_name));
			wNewItem.m_tooltipText = Resources::GetString(sw.m_description);
			wNewItem.m_func = "set-flag " + sw.m_flag;
			wNewItem.SetChecked(record.arenaFlags.find(sw.m_flagHash) != -1);

			wList.AddChild(wNewItem);
		}
	}

	bool BlocksLower() override
	{
		return true;
	}

	void Close()
	{
		g_gameMode.RemoveWidgetRoot(this);
		@m_owner.m_switches = null;
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "back")
			Close();
		else if (parse[0] == "set-flag")
		{
			auto checkbox = cast<CheckBoxWidget>(sender);

			auto sw = SurvivalSwitches::GetSwitch(parse[1]);
			if (sw is null)
			{
				PrintError("Couldn't find flag \"" + parse[1] + "\"!");
				return;
			}

			auto record = GetLocalPlayerRecord();

			if (checkbox.IsChecked())
			{
				if (record.arenaFlags.find(sw.m_flagHash) != -1)
				{
					PrintError("Flag \"" + sw.m_flag + "\" is already set!");
					return;
				}
				record.arenaFlags.insertLast(sw.m_flagHash);
			}
			else
			{
				int index = record.arenaFlags.find(sw.m_flagHash);
				if (index == -1)
				{
					PrintError("Flag \"" + sw.m_flag + "\" is not set!");
					return;
				}
				record.arenaFlags.removeAt(index);
			}
		}
	}
}
