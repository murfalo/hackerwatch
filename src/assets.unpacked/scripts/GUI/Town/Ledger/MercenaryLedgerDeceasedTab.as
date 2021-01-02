class MercenaryLedgerDeceasedTab : MenuTab
{
	MercenaryLedger@ m_owner;

	GuildHallStatsBuilder@ m_statsBuilder;
	ScrollableWidget@ m_wList;

	array<TopMercenaries::Item@> m_listedCharacters;

	MercenaryLedgerDeceasedTab(MercenaryLedger@ owner)
	{
		m_id = "deceased";
		@m_owner = owner;
	}

	string GetGuiFilename() override
	{
		return "gui/town/ledger/deceased.gui";
	}

	void OnShow() override
	{
		@m_statsBuilder = GuildHallStatsBuilder(m_widget);
		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));

		ReloadList();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "delete")
		{
			int index = parseInt(parse[1]);
			auto svChar = m_listedCharacters[index].m_charData;

			string charName = GetParamString(UnitPtr(), svChar, "name");
			g_gameMode.ShowDialog("delete-confirm " + index,
				Resources::GetString(".town.mercenaryledger.delete.prompt", {
					{ "name", charName }
				}),
				Resources::GetString(".misc.yes"),
				Resources::GetString(".misc.no"), m_owner);

			return true;
		}
		else if (parse[0] == "delete-confirm")
		{
			if (parse[2] == "no")
				return true;

			int index = parseInt(parse[1]);
			HwrSaves::DeleteCharacter(m_listedCharacters[index].m_index);

			ReloadList();

			return true;
		}
		return false;
	}

	void ReloadList()
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		bool secondCharacter = false;

		m_listedCharacters = TopMercenaries::Get(true);
		for (uint i = 0; i < m_listedCharacters.length(); i++)
		{
			auto svChar = m_listedCharacters[i].m_charData;

			if (secondCharacter)
				m_statsBuilder.AddSeparatorToList(m_wList);
			secondCharacter = true;

			m_statsBuilder.AddCharacterToList(m_wList, svChar, i);
		}

		m_wList.ResumeScrolling();
	}
}
