class CustomizationCombosTab : MenuTab
{
	CharacterCustomizationBase@ m_base;

	CheckBoxGroupWidget@ m_wList;
	Widget@ m_wTemplate;

	CustomizationCombosTab(CharacterCustomizationBase@ base)
	{
		m_id = "combos";

		@m_base = base;
	}

	string GetGuiFilename() override
	{
		return "gui/customization/combos.gui";
	}

	bool ShouldShowButton() override
	{
		auto town = m_base.GetTown();
		if (town.m_comboStyles.length() > 0)
			return true;

		uint hashDefault = HashString("default");
		for (uint i = 0; i < PlayerComboStyle::Instances.length(); i++)
		{
			auto style = PlayerComboStyle::Instances[i];
			if (style.m_owned && style.m_idHash != hashDefault)
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
			@m_base.m_comboStyle = PlayerComboStyle::Get(record.currentComboStyle);
			@m_base.m_comboStyleOriginal = m_base.m_comboStyle;
		}
	}

	void AddStyle(PlayerRecord@ record, PlayerComboStyle@ style)
	{
		auto wNewItem = cast<CheckBoxWidget>(m_wTemplate.Clone());
		wNewItem.SetID("");
		wNewItem.m_visible = true;

		wNewItem.m_value = style.m_id;
		wNewItem.m_checked = (m_base.m_comboStyle is style);

		wNewItem.m_tooltipTitle = Resources::GetString(style.m_name);
		wNewItem.m_tooltipText = Resources::GetString(style.m_description);

		if (m_base.m_editing && style !is m_base.m_comboStyleOriginal)
		{
			int changeCost = m_base.GetComboStyleChangeCost(style);
			if (changeCost > 0)
				wNewItem.AddTooltipSub(m_def.GetSprite("gold"), formatThousands(changeCost));
		}

		auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(style.m_sprite);

		m_wList.AddChild(wNewItem);
	}

	void OnShow() override
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < PlayerComboStyle::Instances.length(); i++)
		{
			auto style = PlayerComboStyle::Instances[i];
			if (style.m_owned)
				AddStyle(record, style);
		}

		auto town = m_base.GetTown();
		for (uint i = 0; i < town.m_comboStyles.length(); i++)
		{
			uint idHash = town.m_comboStyles[i];
			auto style = PlayerComboStyle::Get(idHash);
			if (style is null)
			{
				PrintError("Unable to get owned combo style for ID " + idHash);
				continue;
			}

			AddStyle(record, style);
		}

		m_wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		if (name == "set-combo")
		{
			auto wCheck = cast<CheckBoxWidget>(sender);
			@m_base.m_comboStyle = PlayerComboStyle::Get(wCheck.m_value);
			m_base.UpdateCost();
		}
		return false;
	}
}
