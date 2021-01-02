class LegacyShopTrailsTab : MenuTab
{
	LegacyShop@ m_shop;

	LegacyShopTrailsTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "trails";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/trails.gui"; }

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

		auto arrInstances = PlayerTrails::g_trails;
		arrInstances.sort(function(a, b) {
			return (a.m_legacyPoints < b.m_legacyPoints);
		});

		for (uint i = 0; i < arrInstances.length(); i++)
		{
			auto trail = arrInstances[i];

			Widget@ wNewItem = null;

			if (gm.m_townLocal.OwnsTrail(trail))
				@wNewItem = wTemplateOwned.Clone();
			else
			{
				auto wNewCheck = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewCheck.m_value = trail.m_id;
				wNewCheck.m_checked = (m_shop.m_selectedTrails.findByRef(trail) != -1);

				wNewCheck.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(trail.m_legacyPoints));

				@wNewItem = wNewCheck;
			}

			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_tooltipTitle = Resources::GetString(trail.m_name);
			wNewItem.m_tooltipText = Resources::GetString(trail.m_description);

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(trail.m_icon);

			wList.AddChild(wNewItem);
		}

		wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "check-trail")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			bool selected = wCheck.IsChecked();

			auto trail = PlayerTrails::GetTrail(idHash);
			if (trail is null)
				return true;

			int selectedIndex = m_shop.m_selectedTrails.findByRef(trail);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedTrails.insertLast(trail);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedTrails.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		return false;
	}
}
