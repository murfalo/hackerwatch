class CustomizationDyesTab : MenuTab
{
	CharacterCustomizationBase@ m_base;

	CheckBoxGroupWidget@ m_wListMaterial;
	Widget@ m_wTemplateMaterial;

	ScrollableWidget@ m_wListColors;
	Widget@ m_wTemplateColor;

	TextWidget@ m_wDyeCount;

	array<UnitWidget@> m_previews;

	int m_dyeSelecting;
	Materials::Category m_dyeCategory;

	CustomizationDyesTab(CharacterCustomizationBase@ base)
	{
		m_id = "dyes";

		@m_base = base;
	}

	string GetGuiFilename() override
	{
		return "gui/customization/dyes.gui";
	}

	void OnCreated() override
	{
		@m_wListMaterial = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list-material"));
		@m_wTemplateMaterial = m_widget.GetWidgetById("template-material");

		@m_wListColors = cast<ScrollableWidget>(m_widget.GetWidgetById("list-colors"));
		@m_wTemplateColor = m_widget.GetWidgetById("template-color");

		@m_wDyeCount = cast<TextWidget>(m_widget.GetWidgetById("dye-count"));

		auto wPreviews = m_widget.GetWidgetById("previews");
		if (wPreviews !is null)
		{
			for (uint i = 0; i < wPreviews.m_children.length(); i++)
			{
				auto wUnit = cast<UnitWidget>(wPreviews.m_children[i]);
				if (wUnit is null)
					continue;

				wUnit.AddUnit("players/" + m_base.m_charClass + ".unit", "idle-" + m_previews.length());
				m_previews.insertLast(wUnit);
			}
		}

		auto record = GetLocalPlayerRecord();
		if (record !is null)
		{
			m_base.m_dyes = record.colors;
			m_base.m_dyesOriginal = m_base.m_dyes;
		}
		else
		{
			auto town = m_base.GetTown();
			auto dyeMap = Materials::GetDyeMapping(m_base.m_charClass);

			for (uint i = 0; i < dyeMap.m_categories.length(); i++)
			{
				auto category = dyeMap.m_categories[i];

				auto ownedDyes = town.GetOwnedDyes(category);
				if (ownedDyes.length() == 0)
				{
					PrintError("No owned dyes for category " + int(category) + "!");
					continue;
				}

				m_base.m_dyes.insertLast(ownedDyes[randi(ownedDyes.length())]);
			}
		}
	}

	void OnShow() override
	{
		auto dyeMap = Materials::GetDyeMapping(m_base.m_charClass);

		// Load material list
		m_wListMaterial.PauseScrolling();
		m_wListMaterial.ClearChildren();
		for (uint i = 0; i < dyeMap.m_categories.length(); i++)
		{
			auto wNewMaterial = cast<CheckBoxWidget>(m_wTemplateMaterial.Clone());
			wNewMaterial.SetID("");
			wNewMaterial.m_visible = true;

			wNewMaterial.m_value = "" + i;

			auto wTexture = cast<SpriteWidget>(wNewMaterial.GetWidgetById("texture"));
			if (wTexture !is null)
				wTexture.SetSprite("material-" + int(dyeMap.m_categories[i]));

			auto wName = cast<TextWidget>(wNewMaterial.GetWidgetById("name"));
			if (wName !is null)
				wName.SetText(Resources::GetString(dyeMap.m_names[i]));

			auto wShades = cast<DyeShadesWidget>(wNewMaterial.GetWidgetById("shades"));
			if (wShades !is null)
				@wShades.m_dyeState = m_base.m_dyes[i].MakeDyeState();

			if (m_base.m_editing && m_base.m_dyes[i] !is m_base.m_dyesOriginal[i])
			{
				int changeCost = m_base.GetDyeChangeCost(m_base.m_dyes[i]);
				if (changeCost > 0)
				{
					auto wCost = wNewMaterial.GetWidgetById("cost");
					if (wCost !is null)
					{
						wCost.m_visible = true;

						auto wCostText = cast<TextWidget>(wCost.GetWidgetById("amount"));
						if (wCostText !is null)
							wCostText.SetText(formatThousands(changeCost));
					}
				}
			}

			m_wListMaterial.AddChild(wNewMaterial);
		}
		m_wListMaterial.ResumeScrolling();
		m_wListMaterial.SetChecked(m_dyeSelecting);

		// Set preview units
		for (uint i = 0; i < m_previews.length(); i++)
			m_previews[i].m_dyeStates = Materials::MakeDyeStates(m_base.m_dyes);

		// Show selection from current category
		m_dyeCategory = dyeMap.m_categories[m_dyeSelecting];

		auto town = m_base.GetTown();
		auto ownedDyes = town.GetOwnedDyes(m_dyeCategory);

		// Show owned dye count
		if (m_wDyeCount !is null)
		{
			uint numOwnedDyes = ownedDyes.length();
			uint numTotalDyes = Materials::GetDyeCount(m_dyeCategory);
			m_wDyeCount.SetText(numOwnedDyes + " / " + numTotalDyes);
		}

		// Load owned dyes list
		m_wListColors.PauseScrolling();
		m_wListColors.ClearChildren();
		for (uint i = 0; i < ownedDyes.length(); i++)
		{
			auto dye = ownedDyes[i];

			auto wNewColor = cast<CheckBoxWidget>(m_wTemplateColor.Clone());
			wNewColor.SetID("");
			wNewColor.m_visible = true;

			if (dye.m_legacyPoints > 0)
				wNewColor.SetSpriteset("color-star-button");

			auto wBall = cast<DyeSpriteWidget>(wNewColor.GetWidgetById("ball"));
			if (wBall !is null)
			{
				if (dye.m_legacyPoints > 0)
					wBall.SetSprite("color-star");

				wBall.m_dyeStates.insertLast(dye.MakeDyeState());
			}

			wNewColor.m_checked = (m_base.m_dyes[m_dyeSelecting] is dye);
			wNewColor.m_func = "select-color " + dye.m_idHash;

			wNewColor.m_tooltipTitle = Resources::GetString(dye.m_name);

			if (m_base.m_editing && dye !is m_base.m_dyesOriginal[m_dyeSelecting])
			{
				int changeCost = m_base.GetDyeChangeCost(dye);
				if (changeCost > 0)
					wNewColor.AddTooltipSub(m_def.GetSprite("gold"), formatThousands(changeCost));
			}

			m_wListColors.AddChild(wNewColor);
		}
		m_wListColors.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "change-material")
		{
			auto checked = m_wListMaterial.GetChecked();
			if (checked is null)
				return true;

			m_dyeSelecting = parseInt(checked.GetValue());
			OnShow();
			return true;
		}
		else if (parse[0] == "select-color")
		{
			uint id = parseUInt(parse[1]);

			auto dye = Materials::GetDye(m_dyeCategory, id);
			if (dye is null)
			{
				PrintError("Couldn't find dye with category " + int(m_dyeCategory) + " with ID " + id);
				return true;
			}

			@m_base.m_dyes[m_dyeSelecting] = dye;

			m_base.FaceChanged();
			m_base.UpdateCost();

			OnShow();
			return true;
		}
		return false;
	}
}
