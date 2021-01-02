class GuildHallBeastiaryTab : GuildHallMenuTab
{
	Sprite@ m_spriteHealth;
	Sprite@ m_spriteArmor;
	Sprite@ m_spriteResistance;

	GuildHallBeastiaryTab()
	{
		m_id = "beastiary";
	}

	void OnCreated() override
	{
		@m_spriteHealth = m_def.GetSprite("icon-health");
		@m_spriteArmor = m_def.GetSprite("icon-armor");
		@m_spriteResistance = m_def.GetSprite("icon-resistance");
	}

	void AddCategory(Widget@ wList, string name, array<BestiaryEntry@>@ units)
	{
		units.sortDesc();

		auto wTemplateHeader = m_widget.GetWidgetById("template-header");
		auto wTemplateSeparator = m_widget.GetWidgetById("template-separator");
		auto wTemplate = m_widget.GetWidgetById("template");

		auto wNewSeparator = wTemplateSeparator.Clone();
		wNewSeparator.m_visible = true;
		wNewSeparator.SetID("");
		wList.AddChild(wNewSeparator);

		auto wNewHeader = wTemplateHeader.Clone();
		wNewHeader.m_visible = true;
		wNewHeader.SetID("");

		auto wHeaderType = cast<TextWidget>(wNewHeader.GetWidgetById("type"));
		if (wHeaderType !is null)
			wHeaderType.SetText(Resources::GetString(".bestiary.type." + name));

		wList.AddChild(wNewHeader);

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < units.length(); i++)
		{
			auto unit = units[i];
			if (unit.m_kills == 0 && unit.m_killer == 0)
				continue;

			auto params = unit.m_producer.GetBehaviorParams();

			string unitName = GetParamString(UnitPtr(), params, "beastiary-name", false);
			if (unitName == "")
				continue;

			string unitDescription = GetParamString(UnitPtr(), params, "beastiary-description", false);

			string displayScene = GetParamString(UnitPtr(), params, "beastiary-scene", false, "idle-3");
			UnitScene@ scene = unit.m_producer.GetUnitScene(displayScene);
			vec2 sceneOffset = GetParamVec2(UnitPtr(), params, "beastiary-offset", false);

			// TODO: Add to tooltip..   show hp after X kills, show armor after Y kills, etc (?)
			int hp = GetParamInt(UnitPtr(), params, "hp");
			int armor = GetParamInt(UnitPtr(), params, "armor", false, 0);
			int resistance = GetParamInt(UnitPtr(), params, "resistance", false, 0);
			int expReward = GetParamInt(UnitPtr(), params, "experience-reward", false, 0);

			auto wNewItem = wTemplate.Clone();
			wNewItem.m_visible = true;
			wNewItem.SetID("");

			auto wUnit = cast<UnitWidget>(wNewItem.GetWidgetById("unit"));
			if (wUnit !is null)
			{
				auto uws = wUnit.AddUnit(scene);
				uws.m_offset = sceneOffset + vec2(1, 2);
			}

			vec4 qualityColor = GetItemQualityColor(unit.m_quality);

			auto wNameContainer = cast<RectWidget>(wNewItem.GetWidgetById("name-container"));
			if (wNameContainer !is null)
			{
				if (unit.m_quality != ActorItemQuality::Common)
					wNameContainer.m_color = desaturate(qualityColor);
			}

			auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
			if (wName !is null)
			{
				wName.SetText(Resources::GetString(unitName));
				wName.SetColor(qualityColor);

				wName.m_tooltipTitle = Resources::GetString(unitName);
				if (unitDescription != "")
					wName.m_tooltipText = Resources::GetString(unitDescription) + "\n\n";
				wName.m_tooltipText += Resources::GetString(".bestiary.expreward") + ": " + formatThousands(expReward);

				wName.AddTooltipSub(m_spriteHealth, formatThousands(hp));

				if (armor > 0)
					wName.AddTooltipSub(m_spriteArmor, formatThousands(armor));

				if (resistance > 0)
					wName.AddTooltipSub(m_spriteResistance, formatThousands(resistance));
			}

			auto wDlc = cast<SpriteWidget>(wNewItem.GetWidgetById("dlc"));
			if (wDlc !is null)
			{
				wDlc.m_visible = (unit.m_dlc != "");
				wDlc.SetSprite("icon-dlc-" + unit.m_dlc);
			}

			auto wKills = cast<TextWidget>(wNewItem.GetWidgetById("kills"));
			if (wKills !is null)
				wKills.SetText(formatThousands(unit.m_kills));

			auto wAttuneLevel = cast<TextWidget>(wNewItem.GetWidgetById("attune-level"));
			if (wAttuneLevel !is null)
			{
				auto entry = record.GetBestiaryAttunement(unit.m_producer.GetResourceHash());
				if (entry.m_attuned > 0)
				{
					wAttuneLevel.m_visible = true;
					wAttuneLevel.SetText("" + entry.m_attuned);
				}
				else
					wAttuneLevel.m_visible = false;
			}

			wList.AddChild(wNewItem);
		}
	}

	void OnShow() override
	{
		auto wList = m_widget.GetWidgetById("list");
		if (wList is null)
			return;

		wList.ClearChildren();

		auto town = cast<Campaign>(g_gameMode).m_townLocal;

		AddCategory(wList, "beast", town.GetBestiary("beast"));
		AddCategory(wList, "undead", town.GetBestiary("undead"));
		AddCategory(wList, "aberration", town.GetBestiary("aberration"));
		AddCategory(wList, "construct", town.GetBestiary("construct"));

		Invalidate();
	}
}
