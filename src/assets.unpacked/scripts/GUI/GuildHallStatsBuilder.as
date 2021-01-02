class GuildHallStatsBuilder
{
	Widget@ m_root;

	Widget@ m_wTemplateStats;
	Widget@ m_wTemplateStatsEmpty;
	Widget@ m_wTemplateStatsHeader;
	Widget@ m_wTemplateStatsSeparator;

	Widget@ m_wTemplateCharacter;
	Widget@ m_wTemplateSeparator;

	GuildHallStatsBuilder(Widget@ root)
	{
		@m_root = root;

		@m_wTemplateStats = m_root.GetWidgetById("template-stats");
		@m_wTemplateStatsEmpty = m_root.GetWidgetById("template-stats-empty");
		@m_wTemplateStatsHeader = m_root.GetWidgetById("template-stats-header");
		@m_wTemplateStatsSeparator = m_root.GetWidgetById("template-stats-separator");

		@m_wTemplateCharacter = m_root.GetWidgetById("template-character");
		@m_wTemplateSeparator = m_root.GetWidgetById("template-separator");
	}

	Widget@ AddSeparatorToList(Widget@ wList)
	{
		auto wNewItem = m_wTemplateSeparator.Clone();
		wNewItem.SetID("");
		wNewItem.m_visible = true;
		wList.AddChild(wNewItem);
		return wNewItem;
	}

	Widget@ AddHeaderToList(Widget@ wList, const string &in name)
	{
		auto wNewHeader = m_wTemplateStatsHeader.Clone();
		wNewHeader.m_visible = true;
		wNewHeader.SetID("");

		auto wHeaderCategory = cast<TextWidget>(wNewHeader.GetWidgetById("category"));
		if (wHeaderCategory !is null)
			wHeaderCategory.SetText(utf8string(name).toUpper().plain());

		wList.AddChild(wNewHeader);
		return wNewHeader;
	}

	Widget@ AddStatItemToList(Widget@ wList, const string &in name, const string &in value)
	{
		auto wNewItem = m_wTemplateStats.Clone();
		wNewItem.m_visible = true;
		wNewItem.SetID("");

		auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
		if (wName !is null)
			wName.SetText(name);

		auto wValue = cast<TextWidget>(wNewItem.GetWidgetById("value"));
		if (wValue !is null)
			wValue.SetText(value);

		wList.AddChild(wNewItem);
		return wNewItem;
	}

	void AddStatisticsToList(Stats::StatList@ stats, Widget@ wList)
	{
		string lastCategory;

		for (uint i = 0; i < stats.m_stats.length(); i++)
		{
			auto stat = stats.m_stats[i];

			if (stat.m_display == Stats::StatDisplay::None || stat.m_valueInt == 0)
				continue;

			if (stat.m_category != lastCategory)
			{
				if (lastCategory != "")
				{
					auto wNewSeparator = m_wTemplateStatsSeparator.Clone();
					wNewSeparator.m_visible = true;
					wNewSeparator.SetID("");
					wList.AddChild(wNewSeparator);
				}

				lastCategory = stat.m_category;

				AddHeaderToList(wList, Resources::GetString(".stats.category." + stat.m_category));
			}

			string strValue = "-";
			if (stat.m_valueInt != 0)
				strValue = stat.ToString();

			AddStatItemToList(wList, Resources::GetString(".stats." + stat.m_name), strValue);
		}

		if (wList.m_children.length() == 0)
		{
			auto wNewEmpty = m_wTemplateStatsEmpty.Clone();
			wNewEmpty.m_visible = true;
			wNewEmpty.SetID("");
			wList.AddChild(wNewEmpty);
		}
	}

	void AddCharacterToList(Widget@ wList, SValue@ svChar, int index = -1)
	{
		auto wNewItem = cast<DetailsWidget>(m_wTemplateCharacter.Clone());
		wNewItem.SetID("");
		wNewItem.m_visible = true;
		wList.AddChild(wNewItem);

		string name = GetParamString(UnitPtr(), svChar, "name");
		int level = GetParamInt(UnitPtr(), svChar, "level");
		string charClass = GetParamString(UnitPtr(), svChar, "class");
		int face = GetParamInt(UnitPtr(), svChar, "face", false);
		uint frame = uint(GetParamInt(UnitPtr(), svChar, "current-frame", false, HashString("default")));

		DungeonNgpList ngps;
		ngps.Load(svChar, "ngps");

		int ngp = ngps["base"];
		int desertNgp = ngps["pop"];

		int gladiatorPoints = GetParamInt(UnitPtr(), svChar, "gladiator-points", false);
		int gladiatorRank = gladiatorPoints / Tweak::PointsPerGladiatorRank;
		SValue@ svStatistics = svChar.GetDictionaryEntry("statistics");

		bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);

		int prestige = GetParamInt(UnitPtr(), svChar, "mercenary-prestige", false);
		prestige = max(prestige, GetParamInt(UnitPtr(), svChar, "mercenary-points-reward", false));
		prestige = max(prestige, GetParamInt(UnitPtr(), svChar, "mercenary-points-current", false));

		array<Materials::Dye@> dyes = Materials::DyesFromSval(svChar);

		string strTooltip = ngps.BuildCharacterInfoTooltip();
		if (gladiatorRank > 0)
			strTooltip += Resources::GetString(".charinfo.arena.rank", { { "rank", gladiatorRank } }) + "\n";

		if (mercenary && prestige > 0)
			strTooltip += Resources::GetString(".charinfo.prestige", { { "points", prestige } }) + "\n";

		wNewItem.m_tooltipText = strTrim(strTooltip);

		auto wUnit = cast<UnitWidget>(wNewItem.GetWidgetById("unit"));
		if (wUnit !is null)
		{
			wUnit.AddUnit("players/" + charClass + ".unit", "idle-3");
			wUnit.m_dyeStates = Materials::MakeDyeStates(dyes);
		}

		auto wPortrait = cast<PortraitWidget>(wNewItem.GetWidgetById("portrait"));
		if (wPortrait !is null)
		{
			wPortrait.SetClass(charClass);
			wPortrait.SetFace(face);
			wPortrait.SetDyes(dyes);
			wPortrait.SetFrame(frame);
			wPortrait.UpdatePortrait();
		}

		auto wLevel = cast<TextWidget>(wNewItem.GetWidgetById("level"));
		if (wLevel !is null)
		{
			wLevel.SetText("" + level);
			if (ngp == 0 && desertNgp == 0)
				wLevel.m_anchor.y = 0.5;

			if (mercenary)
				wLevel.SetColor(ParseColorRGBA("#CC7D4FFF"));
		}

		auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
		if (wName !is null)
		{
			if (mercenary)
			{
				auto title = g_classTitles.m_titlesMercenary.GetTitleFromPoints(prestige);
				wName.SetText(Resources::GetString(title.m_name) + " " + name);
			}
			else
			{
				string charClassName = Resources::GetString(".class." + charClass);
				dictionary params = { { "name", name }, { "class", charClassName } };
				wName.SetText(Resources::GetString(".mainmenu.character.select.name", params));
			}

			if (mercenary)
				wName.SetColor(ParseColorRGBA("#CC7D4FFF"));
		}

		auto wDeleteButton = cast<SpriteButtonWidget>(wNewItem.GetWidgetById("button-delete"));
		if (wDeleteButton !is null)
			wDeleteButton.m_func = "delete " + index;

		if (mercenary)
		{
			array<Widget@> arrMercFrames = {
				wNewItem.GetWidgetById("merc-frame-unit"),
				wNewItem.GetWidgetById("merc-frame-level"),
				wNewItem.GetWidgetById("merc-frame-name")
			};

			for (uint j = 0; j < arrMercFrames.length(); j++)
				arrMercFrames[j].m_visible = true;
		}

		Stats::StatList@ stats = Stats::LoadList("tweak/stats.sval");

		if (svStatistics !is null)
			stats.Load(svStatistics);

		AddStatisticsToList(stats, wNewItem.m_wDetails);
	}
}
