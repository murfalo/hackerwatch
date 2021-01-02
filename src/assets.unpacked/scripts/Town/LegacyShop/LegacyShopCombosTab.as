class LegacyShopCombosTab : MenuTab
{
	LegacyShop@ m_shop;

	LegacyShopCombosTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "combos";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/combos.gui"; }

	void OnCreated() override
	{
	}

	void OnShow() override
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		auto wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		auto wTemplate = m_widget.GetWidgetById("template");
		auto wTemplateOwned = m_widget.GetWidgetById("template-owned");

		wList.PauseScrolling();
		wList.ClearChildren();

		auto arrInstances = PlayerComboStyle::Instances;
		arrInstances.sort(function(a, b) {
			return (a.m_legacyPoints < b.m_legacyPoints);
		});

		for (uint i = 0; i < arrInstances.length(); i++)
		{
			auto style = arrInstances[i];

			Widget@ wNewItem = null;

			if (gm.m_townLocal.OwnsComboStyle(style))
				@wNewItem = wTemplateOwned.Clone();
			else
			{
				auto wNewCheck = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewCheck.m_value = style.m_id;
				wNewCheck.m_checked = (m_shop.m_selectedComboStyles.findByRef(style) != -1);

				wNewCheck.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(style.m_legacyPoints));

				@wNewItem = wNewCheck;
			}

			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_tooltipTitle = Resources::GetString(style.m_name);
			wNewItem.m_tooltipText = Resources::GetString(style.m_description);

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(style.m_sprite);

			wList.AddChild(wNewItem);
		}

		wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "check-combo")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			bool selected = wCheck.IsChecked();

			auto style = PlayerComboStyle::Get(idHash);
			if (style is null)
				return true;

			int selectedIndex = m_shop.m_selectedComboStyles.findByRef(style);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedComboStyles.insertLast(style);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedComboStyles.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		return false;
	}
}
