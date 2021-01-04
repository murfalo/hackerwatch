class MercenaryLedgerCompanyTab : MenuTab
{
	Stats::StatList@ m_statistics;
	Stats::StatList@ m_statisticsSecond;

	GuildHallStatsBuilder@ m_statsBuilder;
	ScrollableWidget@ m_wList;

	Widget@ m_wTemplatePoints;

	MercenaryLedgerCompanyTab()
	{
		m_id = "company";

		@m_statistics = Stats::LoadList("tweak/stats.sval");
		@m_statisticsSecond = Stats::LoadList("tweak/stats.sval");
	}

	void OnCreated() override
	{
		@m_statsBuilder = GuildHallStatsBuilder(m_widget);
		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));

		@m_wTemplatePoints = m_widget.GetWidgetById("template-points");
	}

	string GetGuiFilename() override
	{
		return "gui/town/ledger/company.gui";
	}

	void OnShow() override
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		m_statistics.Clear();

		auto arrCharacters = HwrSaves::GetCharacters();
		bool secondCharacter = false;

		for (uint i = 0; i < arrCharacters.length(); i++)
		{
			auto svChar = arrCharacters[i];

			bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
			if (!mercenary)
				continue;

			auto svStatistics = svChar.GetDictionaryEntry("statistics");
			if (svStatistics is null)
				continue;

			if (secondCharacter)
			{
				m_statisticsSecond.Load(svStatistics);
				m_statistics.CombineStatsFrom(m_statisticsSecond);
			}
			else
			{
				m_statistics.Load(svStatistics);
				secondCharacter = true;
			}
		}

		// Add total points earned count
		auto wNewPoints = m_wTemplatePoints.Clone();
		wNewPoints.SetID("");
		wNewPoints.m_visible = true;

		auto wAmount = cast<TextWidget>(wNewPoints.GetWidgetById("amount"));
		if (wAmount !is null)
			wAmount.SetText(formatThousands(town.m_earnedLegacyPoints));

		m_wList.AddChild(wNewPoints);

		// Add separator
		m_statsBuilder.AddSeparatorToList(m_wList);

		// Add title list
		auto wNewTitleListHeader = m_statsBuilder.AddHeaderToList(m_wList, Resources::GetString(".town.mercenaryledger.titlelist"));

		auto wHeaderColumn2 = cast<TextWidget>(wNewTitleListHeader.GetWidgetById("column2"));
		if (wHeaderColumn2 !is null)
			wHeaderColumn2.SetText(Resources::GetString(".town.mercenaryledger.titlelist.column2"));

		auto arrCounts = TopMercenaries::TitleCounts();
		for (uint i = 0; i < arrCounts.length(); i++)
		{
			auto title = g_classTitles.m_titlesMercenary.GetTitle(i);
			int count = arrCounts[i];
			m_statsBuilder.AddStatItemToList(m_wList, Resources::GetString(title.m_name), formatThousands(count));
		}

		// Add separator
		m_statsBuilder.AddSeparatorToList(m_wList);

		// Add all statistics
		m_statsBuilder.AddStatisticsToList(m_statistics, m_wList);

		m_wList.ResumeScrolling();
	}
}
