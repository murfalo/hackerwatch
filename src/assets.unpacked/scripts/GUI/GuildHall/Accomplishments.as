class GuildHallAccomplishmentsTab : GuildHallMenuTab
{
	Widget@ m_wList;

	Widget@ m_wTemplateHeader;
	Widget@ m_wTemplateBar;
	Widget@ m_wTemplateVerticalSeparator;
	Widget@ m_wTemplateBoss;
	Widget@ m_wTemplateBossClass;

	int m_numBosses;

	GuildHallAccomplishmentsTab()
	{
		m_id = "accomplishments";
	}

	void OnShow() override
	{
		GuildHallMenuTab::OnShow();

		@m_wList = m_widget.GetWidgetById("list");

		@m_wTemplateHeader = m_widget.GetWidgetById("template-header");
		@m_wTemplateBar = m_widget.GetWidgetById("template-bar");
		@m_wTemplateVerticalSeparator = m_widget.GetWidgetById("template-separator");
		@m_wTemplateBoss = m_widget.GetWidgetById("template-boss");
		@m_wTemplateBossClass = m_widget.GetWidgetById("template-boss-class");

		RefreshList();
	}

	Widget@ AddHeader(string text)
	{
		auto wNewHeader = m_wTemplateHeader.Clone();
		wNewHeader.SetID("");
		wNewHeader.m_visible = true;

		auto wNewHeaderText = cast<TextWidget>(wNewHeader.GetWidgetById("text"));
		wNewHeaderText.SetText(text);

		m_wList.AddChild(wNewHeader);

		return wNewHeader;
	}

	void RefreshList()
	{
		m_wList.ClearChildren();

		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		string lastCategory = "";
		Widget@ lastSeparatorLeft, lastSeparatorRight;

		int currentY = 0;

		bool showAllAccomplishmentsCheat = GetVarBool("show_all_accomplishments");

		Stats::StatList@ stats = gm.m_townLocal.m_statistics;
		for (uint i = 0; i < stats.m_stats.length(); i++)
		{
			Stats::Stat@ stat = stats.m_stats[i];

			if (stat.m_accomplishments.length() == 0)
				continue;

			if (stat.m_dlc != "" && !Platform::HasDLC(stat.m_dlc))
				continue;

			string categoryName = Resources::GetString(".stats.category." + stat.m_category);
			if (lastCategory != categoryName)
			{
				auto wNewHeader = AddHeader(utf8string(categoryName).toUpper().plain());
				currentY += wNewHeader.m_height;

				lastCategory = categoryName;

				@lastSeparatorLeft = m_wTemplateVerticalSeparator.Clone();
				lastSeparatorLeft.SetID("");
				lastSeparatorLeft.m_visible = true;
				lastSeparatorLeft.m_offset = vec2(144, currentY);
				m_wList.AddChild(lastSeparatorLeft);

				@lastSeparatorRight = m_wTemplateVerticalSeparator.Clone();
				lastSeparatorRight.SetID("");
				lastSeparatorRight.m_visible = true;
				lastSeparatorRight.m_offset = vec2(363, currentY);
				m_wList.AddChild(lastSeparatorRight);
			}

			Stats::Accomplishment@ lastAccomplishment;
			int lastAccomplishmentIndex = -1;

			for (uint j = 0; j < stat.m_accomplishments.length(); j++)
			{
				@lastAccomplishment = stat.m_accomplishments[j];
				lastAccomplishmentIndex = j;

				if (!stat.m_accomplishments[j].m_finished)
					break;
			}

			string accomplishmentName = lastAccomplishment.GetName();

			auto wNewBar = m_wTemplateBar.Clone();
			wNewBar.SetID("");
			wNewBar.m_visible = true;

			currentY += wNewBar.m_height;

			bool hidden = (stat.ValueInt() == 0);
			if (showAllAccomplishmentsCheat)
				hidden = false;

			auto wNewBarName = cast<TextWidget>(wNewBar.GetWidgetById("name"));

			if (hidden)
				wNewBarName.SetText("?????");
			else
				wNewBarName.SetText(accomplishmentName);

			if (stat.m_dlc != "")
			{
				auto wNewBarDlc = cast<SpriteWidget>(wNewBar.GetWidgetById("dlc"));
				if (wNewBarDlc !is null)
				{
					wNewBarDlc.m_visible = true;
					wNewBarDlc.SetSprite("icon-dlc-" + stat.m_dlc);
				}
			}

			auto wNewBarBar = cast<BarWidget>(wNewBar.GetWidgetById("bar"));

			if (!hidden)
			{
				wNewBarBar.m_tooltipEnabled = true;
				wNewBarBar.m_tooltipTitle = accomplishmentName;
				wNewBarBar.m_tooltipText = lastAccomplishment.GetDescription();
				wNewBarBar.AddTooltipSub(m_def.GetSprite("reputation-points"), formatThousands(lastAccomplishment.m_reputation));
			}

			auto wNewBarText = cast<TextWidget>(wNewBarBar.GetWidgetById("text"));

			if (hidden)
				wNewBarText.SetText("? / ?");
			else
			{
				if (lastAccomplishment.m_finished)
				{
					wNewBarBar.m_spriteRectVariation = 1;
					wNewBarBar.SetScale(1.0f);

					wNewBarText.SetText(formatThousands(stat.ValueInt()));
				}
				else
				{
					int goodStart = 0;
					int goodEnd = lastAccomplishment.m_value;

					if (lastAccomplishmentIndex > 0)
						goodStart = stat.m_accomplishments[lastAccomplishmentIndex - 1].m_value;

					float scale = ilerp(goodStart, goodEnd, stat.ValueInt());

					wNewBarBar.SetScale(scale);
					wNewBarText.SetText(stat.ToString(true) + " / " + stat.ToString(goodEnd, true));
				}
			}

			m_wList.AddChild(wNewBar);

			lastSeparatorLeft.m_height += wNewBar.m_height;
			lastSeparatorRight.m_height += wNewBar.m_height;
		}

		array<int> bossOrder = {
			0,  // Stone Guardian
			1,  // Warden
			2,  // Three Councilors
			3,  // Watcher
			5,  // Vampire Lord
			4,  // Thundersnow
			6,  // Pop 1
			7,  // Pop 2
			8,  // Pop 3
			9,  // Moon Temple 1
			10, // Moon Temple 2
			11  // Moon Temple 3
		};

		m_numBosses = 0;
		for (uint i = 0; i < bossOrder.length(); i++)
		{
			int bossIndex = bossOrder[i];
			AddBoss(bossIndex);
		}

		Invalidate();
	}

	void AddBoss(int i)
	{
		auto wNewBoss = m_wTemplateBoss.Clone();
		wNewBoss.SetID("");
		wNewBoss.m_visible = true;

		auto gm = cast<Campaign>(g_gameMode);
		uint killedFlags = gm.m_townLocal.m_bossesKilled[i];

		auto wName = cast<TextWidget>(wNewBoss.GetWidgetById("name"));
		if (wName !is null)
			wName.SetText(Resources::GetString(".guildhall.accomplishments.boss-" + (i + 1)));

		bool anyHasKilled = false;

		bool showAllAccomplishmentsCheat = GetVarBool("show_all_accomplishments");
		if (showAllAccomplishmentsCheat)
			anyHasKilled = true;

		auto wClasses = wNewBoss.GetWidgetById("classes");
		if (wClasses !is null)
		{
			int numClasses = 7 + 2; // Base classes + Gladiator + Witch Hunter

			for (int j = 0; j < numClasses; j++)
			{
				if (j == 7 && !Platform::HasDLC("pop"))
					continue;

				if (j == 8 && !Platform::HasDLC("wh"))
					continue;

				bool hasKilled = ((killedFlags & (1 << j)) != 0);
				if (hasKilled)
					anyHasKilled = true;

				auto wNewBossClass = cast<SpriteWidget>(m_wTemplateBossClass.Clone());
				wNewBossClass.SetID("");
				wNewBossClass.m_visible = true;

				string charClass = "";
				switch (j)
				{
					case 0: charClass = "paladin"; break;
					case 1: charClass = "ranger"; break;
					case 2: charClass = "sorcerer"; break;
					case 3: charClass = "warlock"; break;
					case 4: charClass = "thief"; break;
					case 5: charClass = "priest"; break;
					case 6: charClass = "wizard"; break;
					case 7: charClass = "gladiator"; break;
					case 8: charClass = "witch_hunter"; break;
				}
				wNewBossClass.SetSprite("char-icon-" + charClass);

				wNewBossClass.m_tooltipText = Resources::GetString(".class." + charClass);
				wNewBossClass.m_tooltipEnabled = hasKilled;

				if (hasKilled)
				{
					auto wNewBossClassCheck = wNewBossClass.GetWidgetById("check");
					if (wNewBossClassCheck !is null)
						wNewBossClassCheck.m_visible = true;
				}
				else
					wNewBossClass.m_colorize = true;

				wClasses.AddChild(wNewBossClass);
			}
		}

		if (anyHasKilled)
		{
			if (++m_numBosses == 1)
				AddHeader(Resources::GetString(".guildhall.accomplishments.bosses"));
			m_wList.AddChild(wNewBoss);
		}
	}
}
