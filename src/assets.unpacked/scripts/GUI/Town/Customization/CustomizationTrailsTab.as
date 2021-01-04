class CustomizationTrailsTab : MenuTab
{
	CharacterCustomizationBase@ m_base;

	CheckBoxGroupWidget@ m_wList;
	Widget@ m_wTemplate;
	Widget@ m_wTemplateNone;

	CustomizationTrailsTab(CharacterCustomizationBase@ base)
	{
		m_id = "trails";

		@m_base = base;
	}

	string GetGuiFilename() override
	{
		return "gui/customization/trails.gui";
	}

	bool ShouldShowButton() override
	{
		auto town = m_base.GetTown();
		return (town.m_trails.length() > 0);
	}

	void OnCreated() override
	{
		@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
		@m_wTemplate = m_widget.GetWidgetById("template");
		@m_wTemplateNone = m_widget.GetWidgetById("template-none");

		auto record = GetLocalPlayerRecord();
		if (record !is null)
		{
			@m_base.m_trail = PlayerTrails::GetTrail(record.currentTrail);
			@m_base.m_trailOriginal = m_base.m_trail;
		}
	}

	void OnShow() override
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		auto wItemNone = cast<CheckBoxWidget>(m_wTemplateNone.Clone());
		wItemNone.SetID("");
		wItemNone.m_visible = true;
		wItemNone.m_checked = (m_base.m_trail is null);
		m_wList.AddChild(wItemNone);

		auto town = m_base.GetTown();
		for (uint i = 0; i < town.m_trails.length(); i++)
		{
			auto trail = town.m_trails[i];

			auto wNewItem = cast<CheckBoxWidget>(m_wTemplate.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_value = trail.m_id;
			wNewItem.m_checked = (m_base.m_trail is trail);

			wNewItem.m_tooltipTitle = Resources::GetString(trail.m_name);
			wNewItem.m_tooltipText = Resources::GetString(trail.m_description);

			if (m_base.m_editing && trail !is m_base.m_trailOriginal)
			{
				int changeCost = m_base.GetTrailChangeCost(trail);
				if (changeCost > 0)
					wNewItem.AddTooltipSub(m_def.GetSprite("gold"), formatThousands(changeCost));
			}

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(trail.m_icon);

			m_wList.AddChild(wNewItem);
		}

		m_wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "set-trail")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);
			@m_base.m_trail = PlayerTrails::GetTrail(wCheck.m_value);
			m_base.UpdateCost();
		}
		else if (name == "clear-trail")
		{
			@m_base.m_trail = null;
			m_base.UpdateCost();
		}
		return false;
	}
}
