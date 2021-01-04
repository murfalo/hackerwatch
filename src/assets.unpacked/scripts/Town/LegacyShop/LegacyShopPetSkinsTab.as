class LegacyShopPetSkinsTab : MenuTab
{
	LegacyShop@ m_shop;

	LegacyShopPetSkinsTab(LegacyShop@ shop)
	{
		@m_shop = shop;
		m_id = "petskins";
	}

	string GetGuiFilename() override { return "gui/town/legacyshop/petskins.gui"; }

	void OnCreated() override
	{
	}

	void OnShow() override
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		auto wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		auto wTemplateHeader = m_widget.GetWidgetById("template-header");
		auto wTemplateDlcIcon = m_widget.GetWidgetById("template-dlc");
		auto wTemplateContainer = m_widget.GetWidgetById("template-container");
		auto wTemplateItem = m_widget.GetWidgetById("template-item");
		auto wTemplateOwned = m_widget.GetWidgetById("template-owned");

		wList.PauseScrolling();
		wList.ClearChildren();

		for (uint i = 0; i < Pets::g_defs.length(); i++)
		{
			auto petDef = Pets::g_defs[i];
			if (!petDef.HasLegacySkins())
				continue;

			auto wNewHeader = wTemplateHeader.Clone();
			wNewHeader.SetID("");
			wNewHeader.m_visible = true;

			auto wText = cast<TextWidget>(wNewHeader.GetWidgetById("text"));
			if (wText !is null)
				wText.SetText(utf8string(Resources::GetString(petDef.m_name)).toUpper().plain());

			bool missingDLC = false;

			auto wHeaderGroup = wNewHeader.m_children[0];
			for (uint j = 0; j < petDef.m_requiredDlcs.length(); j++)
			{
				string dlc = petDef.m_requiredDlcs[j];

				if (!Platform::HasDLC(dlc))
					missingDLC = true;

				auto wNewDlcIcon = cast<SpriteWidget>(wTemplateDlcIcon.Clone());
				wNewDlcIcon.SetID("");
				wNewDlcIcon.m_visible = true;
				wNewDlcIcon.SetSprite("icon-dlc-" + dlc);
				wHeaderGroup.AddChild(wNewDlcIcon);
			}

			auto wNewContainer = wTemplateContainer.Clone();
			wNewContainer.SetID("");
			wNewContainer.m_visible = true;

			auto arrSkins = petDef.m_skins;
			arrSkins.sort(function(a, b) {
				return (a.m_legacyPoints < b.m_legacyPoints);
			});

			for (uint j = 0; j < arrSkins.length(); j++)
			{
				auto petSkin = arrSkins[j];
				if (petSkin.m_legacyPoints == 0)
					continue;

				Widget@ wNewItem = null;

				if (gm.m_townLocal.m_petSkins.find(petSkin.m_idHash) == -1)
				{
					@wNewItem = wTemplateItem.Clone();

					auto wCheck = cast<CheckBoxWidget>(wNewItem);
					wCheck.m_value = "" + j;
					wCheck.m_func = "check-skin " + petDef.m_id;
					wCheck.m_checked = (m_shop.m_selectedPetSkins.findByRef(petSkin) != -1);

					wCheck.AddTooltipSub(m_def.GetSprite("icon-legacy"), formatThousands(petSkin.m_legacyPoints));
				}
				else
					@wNewItem = wTemplateOwned.Clone();

				wNewItem.SetID("");
				wNewItem.m_visible = true;

				wNewItem.m_tooltipTitle = Resources::GetString(petSkin.m_name);
				wNewItem.m_tooltipText = Resources::GetString(petSkin.m_description);

				auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
				if (wIcon !is null)
					wIcon.SetSprite(petSkin.m_icon);

				wNewContainer.AddChild(wNewItem);
			}

			wList.AddChild(wNewHeader);
			wList.AddChild(wNewContainer);
		}

		wList.ResumeScrolling();
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "check-skin")
		{
			auto petDef = Pets::GetDef(parse[1]);
			if (petDef is null)
				return true;

			auto wCheck = cast<CheckBoxWidget>(sender);

			uint index = parseUInt(wCheck.m_value);
			bool selected = wCheck.IsChecked();

			auto arrSkins = petDef.m_skins;
			arrSkins.sort(function(a, b) {
				return (a.m_legacyPoints < b.m_legacyPoints);
			});

			auto skin = arrSkins[index];
			if (skin is null)
				return true;

			int selectedIndex = m_shop.m_selectedPetSkins.findByRef(skin);
			if (selected && selectedIndex == -1)
				m_shop.m_selectedPetSkins.insertLast(skin);
			else if (!selected && selectedIndex != -1)
				m_shop.m_selectedPetSkins.removeAt(selectedIndex);
			else
				PrintError("Something is wrong!");

			m_shop.UpdateInfo();
			return true;
		}
		return false;
	}
}
