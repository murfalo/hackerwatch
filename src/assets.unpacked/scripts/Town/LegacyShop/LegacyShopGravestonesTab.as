class LegacyShopGravestonesTab : MenuTab
{
	LegacyShop@ m_shop;

	LegacyShopGravestonesTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "gravestones";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/gravestones.gui"; }

	void OnCreated() override
	{
	}

	void OnShow() override
	{
		auto gm = cast<Campaign>(g_gameMode);

		auto wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		auto wTemplate = m_widget.GetWidgetById("template");
		auto wTemplateOwned = m_widget.GetWidgetById("template-owned");

		wList.PauseScrolling();
		wList.ClearChildren();

		auto arrInstances = PlayerCorpseGravestone::Instances;
		arrInstances.sort(function(a, b) {
			return (a.m_legacyPoints < b.m_legacyPoints);
		});

		for (uint i = 0; i < arrInstances.length(); i++)
		{
			auto gravestone = arrInstances[i];

			Widget@ wNewItem = null;

			if (gm.m_townLocal.OwnsGravestone(gravestone))
				@wNewItem = wTemplateOwned.Clone();
			else
			{
				auto wNewCheck = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewCheck.m_value = gravestone.m_id;
				wNewCheck.m_checked = (m_shop.m_selectedGravestones.findByRef(gravestone) != -1);

				wNewCheck.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(gravestone.m_legacyPoints));

				@wNewItem = wNewCheck;
			}

			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_tooltipTitle = Resources::GetString(gravestone.m_name);
			wNewItem.m_tooltipText = Resources::GetString(gravestone.m_description);

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(gravestone.m_icon);

			wList.AddChild(wNewItem);
		}

		wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "check-gravestone")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			bool selected = wCheck.IsChecked();

			auto gravestone = PlayerCorpseGravestone::Get(idHash);
			if (gravestone is null)
				return true;

			int selectedIndex = m_shop.m_selectedGravestones.findByRef(gravestone);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedGravestones.insertLast(gravestone);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedGravestones.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		return false;
	}
}
