class MercenaryLedgerInfoTab : MenuTab
{
	MercenaryLedgerInfoTab()
	{
		m_id = "info";
	}

	string GetGuiFilename() override
	{
		return "gui/town/ledger/info.gui";
	}

	void OnCreated() override
	{
		auto player = GetLocalPlayer();

		auto wInfo = m_widget.GetWidgetById("info");
		auto wTemplateTitle = m_widget.GetWidgetById("title-template");

		for (uint i = 0; i < g_classTitles.m_titlesMercenary.m_titles.length(); i++)
		{
			auto title = g_classTitles.m_titlesMercenary.m_titles[i];
			auto modifiers = Modifiers::ModifierList(title.m_modifiers.m_modifiers);

			auto extra = g_classTitles.m_titlesMercenary.GetExtraModifiers(i);
			for (uint j = 0; j < extra.length(); j++)
				modifiers.Add(extra[j]);

			auto wNewTitle = wTemplateTitle.Clone();
			wNewTitle.SetID("");
			wNewTitle.m_visible = true;

			auto wTitle = cast<TextWidget>(wNewTitle.GetWidgetById("title"));
			if (wTitle !is null)
				wTitle.SetText(Resources::GetString(title.m_name));

			auto wPoints = cast<TextWidget>(wNewTitle.GetWidgetById("points"));
			if (wPoints !is null)
				wPoints.SetText(formatThousands(title.m_points));

			auto wGoldGain = cast<TextWidget>(wNewTitle.GetWidgetById("goldgain"));
			if (wGoldGain !is null)
			{
				float goldGainScale = modifiers.GoldGainScale(player);
				goldGainScale += modifiers.GoldGainScaleAdd(player);
				wGoldGain.SetText("+" + ((goldGainScale - 1.0f) * 100.0f) + "%");
			}

			wInfo.AddChild(wNewTitle);
		}
	}
}
