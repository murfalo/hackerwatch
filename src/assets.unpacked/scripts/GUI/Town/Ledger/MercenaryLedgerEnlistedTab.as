class MercenaryLedgerEnlistedTab : MenuTab
{
	GuildHallStatsBuilder@ m_statsBuilder;
	ScrollableWidget@ m_wList;

	MercenaryLedgerEnlistedTab()
	{
		m_id = "enlisted";
	}

	string GetGuiFilename() override
	{
		return "gui/town/ledger/enlisted.gui";
	}

	void OnShow() override
	{
		@m_statsBuilder = GuildHallStatsBuilder(m_widget);
		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));

		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		bool secondCharacter = false;

		auto arrCharacters = TopMercenaries::Get(false);
		for (uint i = 0; i < arrCharacters.length(); i++)
		{
			auto svChar = arrCharacters[i].m_charData;

			if (secondCharacter)
				m_statsBuilder.AddSeparatorToList(m_wList);
			secondCharacter = true;

			m_statsBuilder.AddCharacterToList(m_wList, svChar, i);
		}

		m_wList.ResumeScrolling();
	}
}
