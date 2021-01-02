class LegacyShopDyesTabCategory
{
	Materials::Category m_category;

	Widget@ m_wCategory;
	Widget@ m_wList;
}

class LegacyShopDyesTab : MenuTab
{
	LegacyShop@ m_shop;

	array<LegacyShopDyesTabCategory@> m_categories;

	DyeSpriteWidget@ m_wFace;
	array<UnitWidget@> m_previews;

	LegacyShopDyesTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "dyes";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/dyes.gui"; }

	LegacyShopDyesTabCategory@ GetCategory(Materials::Category cat)
	{
		for (uint i = 0; i < m_categories.length(); i++)
		{
			auto category = m_categories[i];
			if (category.m_category == cat)
				return category;
		}
		return null;
	}

	void OnCreated() override
	{
		@m_wFace = cast<DyeSpriteWidget>(m_widget.GetWidgetById("face"));
	}

	void OnShow() override
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		m_previews.removeRange(0, m_previews.length());
		auto wPreviews = m_widget.GetWidgetById("previews");
		if (wPreviews !is null)
		{
			for (uint i = 0; i < wPreviews.m_children.length(); i++)
			{
				auto wUnit = cast<UnitWidget>(wPreviews.m_children[i]);
				if (wUnit is null)
					continue;

				wUnit.ClearUnits();
				wUnit.AddUnit("players/" + record.charClass + ".unit", "idle-" + m_previews.length());
				wUnit.m_dyeStates = Materials::MakeDyeStates(record.colors);
				m_previews.insertLast(wUnit);
			}
		}

		auto wListCategories = cast<ScrollableWidget>(m_widget.GetWidgetById("list-categories"));
		auto wTemplateCategory = m_widget.GetWidgetById("template-category");
		auto wTemplateDye = m_widget.GetWidgetById("template-dye");

		auto faceInfo = ClassFaceInfo(record.charClass);
		m_wFace.SetSprite(faceInfo.GetSprite(record.face));
		m_wFace.m_dyeStates = Materials::MakeDyeStates(record.colors);

		m_categories.removeRange(0, m_categories.length());

		wListCategories.PauseScrolling();
		wListCategories.ClearChildren();

		auto arrAllDyes = Materials::g_dyes;
		arrAllDyes.sort(function(a, b) {
			return (a.m_legacyPoints < b.m_legacyPoints);
		});

		for (uint i = 0; i < arrAllDyes.length(); i++)
		{
			auto dye = arrAllDyes[i];
			if (dye.m_legacyPoints == 0)
				continue;

			auto category = GetCategory(dye.m_category);
			if (category is null)
			{
				@category = LegacyShopDyesTabCategory();
				category.m_category = dye.m_category;

				auto wNewCategory = wTemplateCategory.Clone();
				wNewCategory.m_visible = true;
				wNewCategory.SetID("");

				auto wName = cast<TextWidget>(wNewCategory.GetWidgetById("name"));
				if (wName !is null)
				{
					utf8string strName = Materials::GetCategoryName(dye.m_category);
					wName.SetText(strName.toUpper().plain());
				}

				@category.m_wCategory = wNewCategory;
				@category.m_wList = wNewCategory.GetWidgetById("list-dyes");

				wListCategories.AddChild(wNewCategory);

				m_categories.insertLast(category);
			}

			auto wNewDye = cast<CheckBoxWidget>(wTemplateDye.Clone());
			wNewDye.m_visible = true;
			wNewDye.SetID("");

			wNewDye.m_value = dye.m_id;
			wNewDye.m_checked = (m_shop.m_selectedDyes.findByRef(dye) != -1);
			wNewDye.m_func = "check-color " + int(dye.m_category);
			wNewDye.m_funcHover = "preview-set " + int(dye.m_category);
			wNewDye.m_funcLeave = "preview-reset";

			wNewDye.m_tooltipTitle = Resources::GetString(dye.m_name);
			wNewDye.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(dye.m_legacyPoints));

			auto wBall = cast<DyeSpriteWidget>(wNewDye.GetWidgetById("ball"));
			if (wBall !is null)
				wBall.m_dyeStates.insertLast(dye.MakeDyeState(record));

			if (gm.m_townLocal.m_dyes.findByRef(dye) != -1)
			{
				wNewDye.m_enabled = false;

				auto wOwned = wNewDye.GetWidgetById("owned");
				if (wOwned !is null)
					wOwned.m_visible = true;
			}

			category.m_wList.AddChild(wNewDye);
		}

		wListCategories.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "check-color")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			auto category = Materials::Category(parseInt(parse[1]));
			bool selected = wCheck.IsChecked();

			auto dye = Materials::GetDye(category, idHash);
			if (dye is null)
				return true;

			int selectedIndex = m_shop.m_selectedDyes.findByRef(dye);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedDyes.insertLast(dye);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedDyes.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		else if (parse[0] == "preview-set")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			auto category = Materials::Category(parseInt(parse[1]));

			auto dye = Materials::GetDye(category, idHash);
			if (dye is null)
				return true;

			auto record = GetLocalPlayerRecord();
			array<Materials::Dye@> colors;
			colors = record.colors;

			auto dyeMap = Materials::GetDyeMapping(record.charClass);
			for (uint i = 0; i < dyeMap.m_categories.length(); i++)
			{
				if (dyeMap.m_categories[i] == category)
					@colors[i] = dye;
			}

			m_wFace.m_dyeStates = Materials::MakeDyeStates(colors);

			for (uint i = 0; i < m_previews.length(); i++)
				m_previews[i].m_dyeStates = Materials::MakeDyeStates(colors);

			return true;
		}
		else if (parse[0] == "preview-reset")
		{
			auto record = GetLocalPlayerRecord();

			m_wFace.m_dyeStates = Materials::MakeDyeStates(record.colors);

			for (uint i = 0; i < m_previews.length(); i++)
				m_previews[i].m_dyeStates = Materials::MakeDyeStates(record.colors);

			return true;
		}
		return false;
	}
}
