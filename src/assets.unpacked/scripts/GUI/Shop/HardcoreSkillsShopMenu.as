class HardcoreSkillsShopMenuContent : ShopMenuContent
{
	Widget@ m_wListActive;
	ScrollableWidget@ m_wListAvailable;

	Widget@ m_wTemplateHeader;
	Widget@ m_wTemplateSeparator;
	Widget@ m_wTemplateActive;
	Widget@ m_wTemplateAvailable;

	Sprite@ m_spriteMana;

	int m_placeSlot = -1;

	SoundEvent@ m_sndBuySkill;

	HardcoreSkillsShopMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);

		@m_sndBuySkill = Resources::GetSoundEvent("event:/ui/buy_skill");
	}

	void OnShow() override
	{
		@m_wListActive = m_widget.GetWidgetById("list-active");
		@m_wListAvailable = cast<ScrollableWidget>(m_widget.GetWidgetById("list-available"));

		@m_wTemplateHeader = m_widget.GetWidgetById("template-header");
		@m_wTemplateSeparator = m_widget.GetWidgetById("template-separator");
		@m_wTemplateActive = m_widget.GetWidgetById("template-active");
		@m_wTemplateAvailable = m_widget.GetWidgetById("template-available");

		@m_spriteMana = m_def.GetSprite("icon-mana");

		ReloadList();
	}

	dictionary GetTownClassLevels()
	{
		dictionary ret;

		auto arrCharacters = HwrSaves::GetCharacters();
		for (uint i = 0; i < arrCharacters.length(); i++)
		{
			auto svChar = arrCharacters[i];
			string charClass = GetParamString(UnitPtr(), svChar, "class");
			int level = GetParamInt(UnitPtr(), svChar, "level");

			int maxLevel;
			if (!ret.get(charClass, maxLevel) || level > maxLevel)
				ret.set(charClass, level);
		}

		return ret;
	}

	bool IsPassive(int index)
	{
		return index >= 3;
	}

	void ShowAvailable()
	{
		bool passive = IsPassive(m_placeSlot);
		auto townClassLevels = GetTownClassLevels();

		m_wListAvailable.ClearChildren();

		auto record = GetLocalPlayerRecord();

		array<HardcoreSkill@> arrSkills;
		for (uint i = 0; i < g_hardcoreSkills.length(); i++)
		{
			auto hardcoreSkill = g_hardcoreSkills[i];
			if (hardcoreSkill.m_passive != passive)
				continue;

			if (record.hardcoreSkills.findByRef(hardcoreSkill) != -1)
				continue;

			arrSkills.insertLast(hardcoreSkill);
		}

		arrSkills.sort(function(a, b) {
			return a.m_cost < b.m_cost;
		});

		for (uint i = 0; i < arrSkills.length(); i++)
		{
			auto hardcoreSkill = arrSkills[i];

			int manaCost = 0;
			if (hardcoreSkill.m_data !is null)
				manaCost = GetParamInt(UnitPtr(), hardcoreSkill.m_data, "mana-cost", false);

			auto wNewItem = cast<ShopButtonWidget>(m_wTemplateAvailable.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			string strClassName;
			if (hardcoreSkill.m_charClass != "")
				strClassName = Resources::GetString(".class." + hardcoreSkill.m_charClass);
			else
				strClassName = Resources::GetString(".class.mercenary");

			wNewItem.m_tooltipTitle = Resources::GetString(hardcoreSkill.m_name);
			wNewItem.AddTooltipSub(null, "\\caaaaaa" + Resources::GetString(".shop.hardcoreskills.fromclass", {
				{ "class", strClassName }
			}));
			wNewItem.m_tooltipText = Resources::GetString(hardcoreSkill.m_description);

			int maxClassLevel = 0;
			if (!townClassLevels.get(hardcoreSkill.m_charClass, maxClassLevel))
				maxClassLevel = 0;

			if (!GetVarBool("g_merc_all_skills") && maxClassLevel < 20 && !hardcoreSkill.m_default)
			{
				wNewItem.m_shopRestricted = true;
				wNewItem.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.hardcoreskills.levelrestriction", {
					{ "class", strClassName }
				});
			}

			wNewItem.m_func = "buy " + hardcoreSkill.m_idHash;
			wNewItem.SetText(Resources::GetString(hardcoreSkill.m_name));
			wNewItem.SetIcon(hardcoreSkill.m_icon);
			wNewItem.SetPriceSkillPoints(hardcoreSkill.m_cost);
			wNewItem.UpdateEnabled();

			if (manaCost > 0)
				wNewItem.AddTooltipSub(m_spriteMana, formatThousands(manaCost));

			m_wListAvailable.AddChild(wNewItem);
		}
	}

	void AddHeaderToList(const string &in text)
	{
		auto wNewHeader = m_wTemplateHeader.Clone();
		wNewHeader.m_visible = true;
		wNewHeader.SetID("");

		auto wText = cast<TextWidget>(wNewHeader.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(text);

		m_wListActive.AddChild(wNewHeader);
	}

	void AddSeparatorToList()
	{
		auto wNewSeparator = m_wTemplateSeparator.Clone();
		wNewSeparator.m_visible = true;
		wNewSeparator.SetID("");
		m_wListActive.AddChild(wNewSeparator);
	}

	void ReloadList() override
	{
		m_wListActive.ClearChildren();
		m_wListAvailable.ClearChildren();

		auto record = GetLocalPlayerRecord();

		AddHeaderToList(Resources::GetString(".shop.hardcoreskills.header.active"));

		for (uint i = 0; i < record.hardcoreSkills.length(); i++)
		{
			if (i > 0 && IsPassive(i) && !IsPassive(i - 1))
			{
				AddSeparatorToList();
				AddHeaderToList(Resources::GetString(".shop.hardcoreskills.header.passive"));
			}

			auto hardcoreSkill = record.hardcoreSkills[i];

			auto wNewItem = m_wTemplateActive.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
			if (wName !is null)
			{
				if (hardcoreSkill !is null)
					wName.SetText(Resources::GetString(hardcoreSkill.m_name));
			}

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
			{
				if (hardcoreSkill !is null)
				{
					int manaCost = 0;
					if (hardcoreSkill.m_data !is null)
						manaCost = GetParamInt(UnitPtr(), hardcoreSkill.m_data, "mana-cost", false);

					wIcon.SetSprite(hardcoreSkill.m_icon);

					wIcon.m_tooltipTitle = Resources::GetString(hardcoreSkill.m_name);
					wIcon.m_tooltipText = Resources::GetString(hardcoreSkill.m_description);

					if (manaCost > 0)
						wIcon.AddTooltipSub(m_spriteMana, formatThousands(manaCost));
				}
			}

			auto wSwitch = cast<SpriteButtonWidget>(wNewItem.GetWidgetById("switch"));
			if (wSwitch !is null)
			{
				auto wSwitchIcon = cast<SpriteWidget>(wSwitch.GetWidgetById("icon"));
				if (wSwitchIcon !is null)
				{
					if (hardcoreSkill is null)
						wSwitchIcon.SetSprite("icon-set");
					else
						wSwitchIcon.SetSprite("icon-clear");
				}

				wSwitch.m_func = "switch " + i;
			}

			m_wListActive.AddChild(wNewItem);
		}

		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "switch")
		{
			int index = parseInt(parse[1]);

			auto player = GetLocalPlayer();
			if (player.m_record.hardcoreSkills[index] is null)
			{
				m_placeSlot = index;
				ShowAvailable();
			}
			else
			{
				@player.m_record.hardcoreSkills[index] = null;

				player.RefreshSkills();
				player.RefreshModifiers();

				(Network::Message("PlayerUpdateHardcoreSkill") << m_placeSlot << 0).SendToAll();

				ReloadList();
			}
		}
		else if (parse[0] == "buy")
		{
			uint idHash = parseUInt(parse[1]);

			if (m_placeSlot == -1)
			{
				PrintError("Place slot is -1, this shouldn't happen!");
				return;
			}

			auto hardcoreSkill = GetHardcoreSkill(idHash);
			if (hardcoreSkill is null)
			{
				PrintError("Couldn't find hardcore skill with hash " + idHash);
				return;
			}

			auto player = GetLocalPlayer();
			@player.m_record.hardcoreSkills[m_placeSlot] = hardcoreSkill;

			player.RefreshSkills();
			player.RefreshModifiers();

			PlaySound2D(m_sndBuySkill);

			(Network::Message("PlayerUpdateHardcoreSkill") << m_placeSlot << int(idHash)).SendToAll();

			m_placeSlot = -1;
			ReloadList();
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.hardcoreskills");
	}

	string GetGuiFilename() override
	{
		return "gui/shop/hardcoreskills.gui";
	}
}
