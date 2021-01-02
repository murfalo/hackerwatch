class CustomizationFramesTab : MenuTab
{
	CharacterCustomizationBase@ m_base;

	CheckBoxGroupWidget@ m_wList;
	Widget@ m_wTemplate;

	CustomizationFramesTab(CharacterCustomizationBase@ base)
	{
		m_id = "frames";

		@m_base = base;
	}

	string GetGuiFilename() override
	{
		return "gui/customization/frames.gui";
	}

	bool ShouldShowButton() override
	{
		auto town = m_base.GetTown();
		if (town.m_frames.length() > 0)
			return true;

		uint hashDefault = HashString("default");
		for (uint i = 0; i < PlayerFrame::Instances.length(); i++)
		{
			auto frame = PlayerFrame::Instances[i];
			if (frame.m_owned && frame.m_idHash != hashDefault)
				return true;
		}

		return false;
	}

	void OnCreated() override
	{
		@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
		@m_wTemplate = m_widget.GetWidgetById("template");

		auto record = GetLocalPlayerRecord();
		if (record !is null)
		{
			@m_base.m_frame = PlayerFrame::Get(record.currentFrame);
			@m_base.m_frameOriginal = m_base.m_frame;
		}
	}

	void AddFrame(PlayerRecord@ record, PlayerFrame@ frame)
	{
		auto wNewItem = cast<CheckBoxWidget>(m_wTemplate.Clone());
		wNewItem.SetID("");
		wNewItem.m_visible = true;

		wNewItem.m_value = frame.m_id;
		wNewItem.m_checked = (m_base.m_frame is frame);

		wNewItem.m_tooltipTitle = Resources::GetString(frame.m_name);
		wNewItem.m_tooltipText = Resources::GetString(frame.m_description);

		if (m_base.m_editing && frame !is m_base.m_frameOriginal)
		{
			int changeCost = m_base.GetFrameChangeCost(frame);
			if (changeCost > 0)
				wNewItem.AddTooltipSub(m_def.GetSprite("gold"), formatThousands(changeCost));
		}

		auto wPortrait = cast<PortraitWidget>(wNewItem.GetWidgetById("portrait"));
		if (wPortrait !is null)
		{
			wPortrait.CopyFrom(m_base.m_wPortrait);
			wPortrait.SetFrame(frame);
		}

		m_wList.AddChild(wNewItem);
	}

	void OnShow() override
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < PlayerFrame::Instances.length(); i++)
		{
			auto frame = PlayerFrame::Instances[i];
			if (frame.m_owned)
				AddFrame(record, frame);
		}

		auto town = m_base.GetTown();
		for (uint i = 0; i < town.m_frames.length(); i++)
			AddFrame(record, town.m_frames[i]);

		m_wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "set-frame")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);
			@m_base.m_frame = PlayerFrame::Get(wCheck.m_value);
			m_base.m_wPortrait.SetFrame(m_base.m_frame);
			m_base.UpdateCost();
		}
		return false;
	}
}
