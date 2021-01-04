class GuildHallStatsTab : GuildHallMenuTab
{
	Widget@ m_wTemplateGuild;

	Widget@ m_wTemplateClasses;
	Widget@ m_wTemplateClassesClass;

	GuildHallStatsBuilder@ m_statsBuilder;

	GuildHallStatsTab()
	{
		m_id = "stats";
	}

	void OnShow() override
	{
		GuildHallMenuTab::OnShow();

		@m_statsBuilder = GuildHallStatsBuilder(m_widget);

		@m_wTemplateGuild = m_widget.GetWidgetById("template-guild");

		@m_wTemplateClasses = m_widget.GetWidgetById("template-classes");
		@m_wTemplateClassesClass = m_widget.GetWidgetById("template-classes-class");

		RefreshList();
	}

	void AddGuildToList(Widget@ wList)
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		auto wNewItem = cast<DetailsWidget>(m_wTemplateGuild.Clone());
		wNewItem.SetID("");
		wNewItem.m_visible = true;
		wList.AddChild(wNewItem);

		auto title = town.GetTitle();
		auto titleNext = town.GetNextTitle();

		string guildTitle = utf8string(Resources::GetString(title.m_name)).toUpper().plain();

		auto wGuildTitle = cast<TextWidget>(wNewItem.GetWidgetById("guild-title"));
		wGuildTitle.SetText(Resources::GetString(".guildhall.stats.guildtitle", { { "title", guildTitle } }));

		auto wBar = cast<BarWidget>(wNewItem.GetWidgetById("reputation-bar"));
		auto wBarText = cast<TextWidget>(wBar.GetWidgetById("text"));

		if (titleNext !is null)
		{
			int reputation = town.GetReputation();
			int goodStart = title.m_points;
			int goodEnd = titleNext.m_points;
			float scale = ilerp(goodStart, goodEnd, reputation);
			wBar.SetScale(scale);
			wBarText.SetText(formatThousands(reputation) + " / " + formatThousands(goodEnd));
		}
		else
		{
			wBar.m_spriteRectVariation = 1;
			wBarText.SetColor(vec4(0, 1, 0, 1));
		}

		m_statsBuilder.AddStatisticsToList(town.m_statistics, wNewItem.m_wDetails);
	}

	void AddClassesClassToList(Widget@ wList, string className, array<SValue@>@ characters, vec2 anchor)
	{
		SValue@ bestChar = null;
		Titles::Title@ bestCharTitle = null;
		int bestCharTitleIndex = -1;
		int actualBestCharTitleIndex = -1;

		int maxTitleIndex = Titles::GetMaxClassTitleIndex();

		for (uint i = 0; i < characters.length(); i++)
		{
			auto charData = characters[i];

			string charClass = GetParamString(UnitPtr(), charData, "class");
			if (charClass != className)
				continue;

			int titleIndex = GetParamInt(UnitPtr(), charData, "title", false);
			actualBestCharTitleIndex = max(actualBestCharTitleIndex, titleIndex);

			if (titleIndex > maxTitleIndex)
				titleIndex = maxTitleIndex;

			if (titleIndex <= bestCharTitleIndex)
				continue;

			auto title = g_classTitles.GetTitle(className, titleIndex);
			if (title is null)
				continue;

			bestCharTitleIndex = titleIndex;

			@bestChar = charData;
			@bestCharTitle = title;
		}

		auto wNewClass = m_wTemplateClassesClass.Clone();
		wNewClass.SetID("");
		wNewClass.m_visible = true;

		wNewClass.m_anchor = anchor;

		if (bestCharTitle !is null)
		{
			auto wTitle = cast<TextWidget>(wNewClass.GetWidgetById("title"));
			if (wTitle !is null)
				wTitle.SetText(bestCharTitleIndex + ". " + Resources::GetString(bestCharTitle.m_name));

			auto wBonus = wNewClass.GetWidgetById("bonus");
			auto wBonusSprite = cast<SpriteWidget>(wBonus.GetWidgetById("sprite"));
			auto wBonusValue = cast<TextWidget>(wBonus.GetWidgetById("value"));

			auto modifiers = Modifiers::ModifierList(bestCharTitle.m_modifiers.m_modifiers);

			auto titleList = g_classTitles.GetList(className);
			if (titleList !is null)
			{
				auto extra = titleList.GetExtraModifiers(bestCharTitleIndex);
				for (uint i = 0; i < extra.length(); i++)
					modifiers.Add(extra[i]);
			}

			vec2 armorAdd = modifiers.ArmorAdd(null, null);
			ivec2 damagePower = modifiers.DamagePower(null, null);
			vec2 regenAdd = modifiers.RegenAdd(null);

			float goldGain = modifiers.GoldGainScale(null);
			goldGain += modifiers.GoldGainScaleAdd(null);

			float critMul = modifiers.CritMul(null, null, false);
			critMul += modifiers.CritMulAdd(null, null, false);

			float critMulSpell = modifiers.CritMul(null, null, true);
			critMulSpell += modifiers.CritMulAdd(null, null, true);

			if (armorAdd.x > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.armor", { { "amount", formatFloat(armorAdd.x, "", 0, 2) } });
				wBonusSprite.SetSprite("icon-armor");
				wBonusValue.SetText(formatFloat(armorAdd.x, "", 0, 2));
			}
			else if (armorAdd.y > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.resistance", { { "amount", formatFloat(armorAdd.y, "", 0, 2) } });
				wBonusSprite.SetSprite("icon-resistance");
				wBonusValue.SetText(formatFloat(armorAdd.y, "", 0, 2));
			}
			else if (damagePower.x > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.attackpower", { { "amount", damagePower.x } });
				wBonusSprite.SetSprite("icon-attack-power");
				wBonusValue.SetText("" + damagePower.x);
			}
			else if (damagePower.y > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.spellpower", { { "amount", damagePower.y } });
				wBonusSprite.SetSprite("icon-spell-power");
				wBonusValue.SetText("" + damagePower.y);
			}
			else if (regenAdd.x > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.healthregen", { { "amount", formatFloat(regenAdd.x, "", 0, 2) } });
				wBonusSprite.SetSprite("icon-health-regen");
				wBonusValue.SetText(formatFloat(regenAdd.x, "", 0, 2));
			}
			else if (regenAdd.y > 0)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.manaregen", { { "amount", formatFloat(regenAdd.y, "", 0, 2) } });
				wBonusSprite.SetSprite("icon-mana-regen");
				wBonusValue.SetText(formatFloat(regenAdd.y, "", 0, 2));
			}
			else if (goldGain > 1.0f)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.goldgain", { { "amount", ((goldGain - 1.0f) * 100.0f) + "%" } });
				wBonusSprite.SetSprite("icon-gold-gain");
				wBonusValue.SetText("+" + formatFloat((goldGain - 1.0f) * 100.0f, "", 0, 1) + "%");
			}
			else if (critMul > 1.0f)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.critmul", { { "amount", ((critMul - 1.0f) * 100.0f) + "%" } });
				wBonusSprite.SetSprite("icon-crit-mul");
				wBonusValue.SetText("+" + formatFloat((critMul - 1.0f) * 100.0f, "", 0, 1) + "%");
			}
			else if (critMulSpell > 1.0f)
			{
				wBonus.m_tooltipText = Resources::GetString(".guildhall.stats.critmulspell", { { "amount", ((critMulSpell - 1.0f) * 100.0f) + "%" } });
				wBonusSprite.SetSprite("icon-crit-mul-spell");
				wBonusValue.SetText("+" + formatFloat((critMulSpell - 1.0f) * 100.0f, "", 0, 1) + "%");
			}

			if (actualBestCharTitleIndex > bestCharTitleIndex)
				wBonusValue.SetText(wBonusValue.m_str + " " + Resources::GetString(".misc.ngp", { { "ngp", int(g_ngp) } }));
		}

		if (bestChar !is null)
		{
			int face = GetParamInt(UnitPtr(), bestChar, "face");
			uint frame = uint(GetParamInt(UnitPtr(), bestChar, "current-frame", false, HashString("default")));
			auto dyes = Materials::DyesFromSval(bestChar);

			auto wPortrait = cast<PortraitWidget>(wNewClass.GetWidgetById("portrait"));
			if (wPortrait !is null)
			{
				wPortrait.m_visible = true;
				wPortrait.SetClass(className);
				wPortrait.SetFace(face);
				wPortrait.SetDyes(dyes);
				wPortrait.SetFrame(frame);
				wPortrait.UpdatePortrait();
			}
		}
		else
		{
			auto wUnknown = wNewClass.GetWidgetById("unknown");
			if (wUnknown !is null)
				wUnknown.m_visible = true;
		}

		wList.AddChild(wNewClass);
	}

	void AddClassesToList(Widget@ wList)
	{
		auto wNewClasses = m_wTemplateClasses.Clone();
		wNewClasses.SetID("");
		wNewClasses.m_visible = true;

		auto characters = HwrSaves::GetCharacters();

		auto wNewList = wNewClasses.GetWidgetById("list");

		AddClassesClassToList(wNewList, "paladin", characters, vec2(0.15f, 0.0f));
		AddClassesClassToList(wNewList, "ranger", characters, vec2(0.5f, 0.0f));
		AddClassesClassToList(wNewList, "sorcerer", characters, vec2(0.85f, 0.0f));

		AddClassesClassToList(wNewList, "warlock", characters, vec2(0.15f, 0.5f));
		AddClassesClassToList(wNewList, "thief", characters, vec2(0.5f, 0.5f));
		AddClassesClassToList(wNewList, "priest", characters, vec2(0.85f, 0.5f));

		AddClassesClassToList(wNewList, "wizard", characters, vec2(0.15f, 1.0f));
		AddClassesClassToList(wNewList, "gladiator", characters, vec2(0.5f, 1.0f));
		AddClassesClassToList(wNewList, "witch_hunter", characters, vec2(0.85f, 1.0f));

		wList.AddChild(wNewClasses);
	}

	void RefreshList()
	{
		auto wList = m_widget.GetWidgetById("list");
		wList.ClearChildren();

		AddGuildToList(wList);

		m_statsBuilder.AddSeparatorToList(wList);
		AddClassesToList(wList);

		auto arrCharacters = HwrSaves::GetCharacters();
		for (uint i = 0; i < arrCharacters.length(); i++)
		{
			auto svChar = arrCharacters[i];

			bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
			bool mercenaryLocked = GetParamBool(UnitPtr(), svChar, "mercenary-locked", false);

			// Dead mercenaries are shown elsewhere in town
			if (mercenary && mercenaryLocked)
				return;

			m_statsBuilder.AddSeparatorToList(wList);
			m_statsBuilder.AddCharacterToList(wList, svChar);
		}

		Invalidate();
	}
}
