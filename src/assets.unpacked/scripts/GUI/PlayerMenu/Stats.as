class PlayerMenuStatsTab : MultiplePlayersTab
{
	PlayerMenuStatsTab()
	{
		m_id = "stats";
	}

	void UpdateNow(PlayerRecord@ record) override
	{
		MultiplePlayersTab::UpdateNow(record);

		auto wList = m_widget.GetWidgetById("list");

		auto wTemplateHeader = m_widget.GetWidgetById("template-header");
		auto wTemplateSeparator = m_widget.GetWidgetById("template-separator");
		auto wTemplate = m_widget.GetWidgetById("template");

		if (wList is null || wTemplate is null)
			return;

		auto stats = record.statistics;
		auto statsSession = record.statisticsSession;

		string lastCategory;

		wList.ClearChildren();
		for (uint i = 0; i < stats.m_stats.length(); i++)
		{
			auto stat = stats.m_stats[i];
			auto statSession = statsSession.GetStat(stat.m_name);

			if (stat.m_display == Stats::StatDisplay::None || (stat.m_valueInt == 0 && statSession.m_valueInt == 0))
				continue;

			if (stat.m_category != lastCategory)
			{
				if (lastCategory != "")
				{
					auto wNewSeparator = wTemplateSeparator.Clone();
					wNewSeparator.m_visible = true;
					wNewSeparator.SetID("");
					wList.AddChild(wNewSeparator);
				}

				lastCategory = stat.m_category;

				auto wNewHeader = wTemplateHeader.Clone();
				wNewHeader.m_visible = true;
				wNewHeader.SetID("");

				auto wHeaderCategory = cast<TextWidget>(wNewHeader.GetWidgetById("category"));
				if (wHeaderCategory !is null)
					wHeaderCategory.SetText(Resources::GetString(".stats.category." + stat.m_category));

				wList.AddChild(wNewHeader);
			}

			auto wNewItem = wTemplate.Clone();
			wNewItem.m_visible = true;
			wNewItem.SetID("");

			auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
			if (wName !is null)
				wName.SetText(Resources::GetString(".stats." + stat.m_name));

			auto wValueSession = cast<TextWidget>(wNewItem.GetWidgetById("value-session"));
			if (wValueSession !is null)
			{
				if (statSession.m_valueInt == 0)
					wValueSession.SetText("-");
				else
					wValueSession.SetText(statSession.ToString());
			}

			auto wValue = cast<TextWidget>(wNewItem.GetWidgetById("value"));
			if (wValue !is null)
			{
				if (stat.m_valueInt == 0)
					wValue.SetText("-");
				else
					wValue.SetText(stat.ToString());
			}

			wList.AddChild(wNewItem);
		}

		Invalidate();
	}
}
