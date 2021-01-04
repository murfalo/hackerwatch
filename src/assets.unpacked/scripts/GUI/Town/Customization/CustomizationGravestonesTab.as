class CustomizationGravestonesTab : MenuTab
{
	CharacterCustomizationBase@ m_base;

	CheckBoxGroupWidget@ m_wList;
	Widget@ m_wTemplate;
	Widget@ m_wTemplateNone;

	CustomizationGravestonesTab(CharacterCustomizationBase@ base)
	{
		m_id = "gravestones";

		@m_base = base;
	}

	string GetGuiFilename() override
	{
		return "gui/customization/gravestones.gui";
	}

	bool ShouldShowButton() override
	{
		auto town = m_base.GetTown();
		return (town.m_gravestones.length() > 0);
	}

	void OnCreated() override
	{
		@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
		@m_wTemplate = m_widget.GetWidgetById("template");
		@m_wTemplateNone = m_widget.GetWidgetById("template-none");

		auto record = GetLocalPlayerRecord();
		if (record !is null)
		{
			@m_base.m_gravestone = PlayerCorpseGravestone::Get(record.currentCorpse);
			@m_base.m_gravestoneOriginal = m_base.m_gravestone;
		}
	}

	void OnShow() override
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		auto wItemNone = cast<CheckBoxWidget>(m_wTemplateNone.Clone());
		wItemNone.SetID("");
		wItemNone.m_visible = true;
		wItemNone.m_checked = (m_base.m_gravestone is null);
		m_wList.AddChild(wItemNone);

		auto town = m_base.GetTown();
		for (uint i = 0; i < town.m_gravestones.length(); i++)
		{
			uint idHash = town.m_gravestones[i];
			auto gravestone = PlayerCorpseGravestone::Get(idHash);
			if (gravestone is null)
			{
				PrintError("Couldn't find gravestone with ID " + idHash);
				continue;
			}

			auto wNewItem = cast<CheckBoxWidget>(m_wTemplate.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.m_value = gravestone.m_id;
			wNewItem.m_checked = (m_base.m_gravestone is gravestone);

			wNewItem.m_tooltipTitle = Resources::GetString(gravestone.m_name);
			wNewItem.m_tooltipText = Resources::GetString(gravestone.m_description);

			if (m_base.m_editing && gravestone !is m_base.m_gravestoneOriginal)
			{
				int changeCost = m_base.GetGravestoneChangeCost(gravestone);
				if (changeCost > 0)
					wNewItem.AddTooltipSub(m_def.GetSprite("gold"), formatThousands(changeCost));
			}

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(gravestone.m_icon);

			m_wList.AddChild(wNewItem);
		}

		m_wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "set-gravestone")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);
			@m_base.m_gravestone = PlayerCorpseGravestone::Get(wCheck.m_value);
			m_base.UpdateCost();
		}
		else if (name == "clear-gravestone")
		{
			@m_base.m_gravestone = null;
			m_base.UpdateCost();
		}
		return false;
	}
}
