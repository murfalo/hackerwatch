class LegacyShopFramesTab : MenuTab
{
	LegacyShop@ m_shop;

	LegacyShopFramesTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "frames";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/frames.gui"; }

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

		auto arrInstances = PlayerFrame::Instances;
		arrInstances.sort(function(a, b) {
			return (a.m_legacyPoints < b.m_legacyPoints);
		});

		for (uint i = 0; i < arrInstances.length(); i++)
		{
			auto frame = arrInstances[i];

			if (frame.m_owned)
				continue;

			Widget@ wNewItem = null;

			if (gm.m_townLocal.OwnsFrame(frame))
				@wNewItem = wTemplateOwned.Clone();
			else
			{
				auto wNewCheck = cast<CheckBoxWidget>(wTemplate.Clone());
				wNewCheck.m_value = frame.m_id;
				wNewCheck.m_checked = (m_shop.m_selectedFrames.findByRef(frame) != -1);

				wNewCheck.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(frame.m_legacyPoints));

				@wNewItem = wNewCheck;
			}

			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_tooltipTitle = Resources::GetString(frame.m_name);
			wNewItem.m_tooltipText = Resources::GetString(frame.m_description);

			auto wPortrait = cast<PortraitWidget>(wNewItem.GetWidgetById("portrait"));
			if (wPortrait !is null)
			{
				wPortrait.SetRecord(record);
				wPortrait.SetFrame(frame);
				wPortrait.UpdatePortrait();
			}

			wList.AddChild(wNewItem);
		}

		wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "check-frame")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);

			auto idHash = HashString(wCheck.m_value);
			bool selected = wCheck.IsChecked();

			auto frame = PlayerFrame::Get(idHash);
			if (frame is null)
				return true;

			int selectedIndex = m_shop.m_selectedFrames.findByRef(frame);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedFrames.insertLast(frame);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedFrames.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		return false;
	}
}
