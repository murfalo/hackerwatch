class TownhallMenuContent : ShopMenuContent
{
	Widget@ m_wSpecialSeparator;

	Widget@ m_wRowList;
	Widget@ m_wTemplateRow;
	Widget@ m_wTemplateRowUnavailable;

	Widget@ m_wTemplateBuilding;
	Widget@ m_wTemplateBuildingOwned;
	Widget@ m_wTemplateBuildingUnavailable;
	Widget@ m_wTemplateBuildingEmpty;
	Widget@ m_wTemplateBuildingUnknown;

	Sprite@ m_spriteOre;

	Upgrades::UpgradeShop@ m_shop;
	array<Upgrades::BuildingUpgradeStep@> m_tiersTownhall;
	array<array<Upgrades::BuildingUpgradeStep@>> m_tiers;

	int m_numTiers = 6;
	int m_numUpgrades = 10;

	TownhallMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);

		@m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("townhall"));

		for (int i = 0; i < m_numTiers; i++)
			m_tiers.insertLast(array<Upgrades::BuildingUpgradeStep@>());

		for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
		{
			auto upgrade = m_shop.m_upgrades[i];

			int stepLevel = 1;
			for (int j = 0; j < m_numTiers; j++)
			{
				auto step = cast<Upgrades::BuildingUpgradeStep>(upgrade.GetStep(stepLevel));

				if (upgrade.m_id == "townhall")
				{
					m_tiersTownhall.insertLast(step);
					stepLevel++;
				}
				else
				{
					if (step !is null && j + 1 >= step.m_restrictShopLevelMin)
					{
						m_tiers[j].insertLast(step);
						stepLevel++;
					}
					else
						m_tiers[j].insertLast(null);
				}
			}
		}

		/*
		print("Building upgrades: " + m_tiers.length());
		for (uint i = 0; i < m_tiers.length(); i++)
		{
			print("  " + m_tiers[i].length() + " steps");
			for (uint j = 0; j < m_tiers[i].length(); j++)
				print("    " + j + ": " + (m_tiers[i][j] is null ? "null" : "OK"));
		}
		*/
	}

	void OnShow() override
	{
		@m_wSpecialSeparator = m_widget.GetWidgetById("special-separator");

		@m_wRowList = m_widget.GetWidgetById("row-list");
		@m_wTemplateRow = m_widget.GetWidgetById("row-template");
		@m_wTemplateRowUnavailable = m_widget.GetWidgetById("row-template-unavailable");

		@m_wTemplateBuilding = m_widget.GetWidgetById("building-template");
		@m_wTemplateBuildingOwned = m_widget.GetWidgetById("building-owned-template");
		@m_wTemplateBuildingUnavailable = m_widget.GetWidgetById("building-unavailable-template");
		@m_wTemplateBuildingEmpty = m_widget.GetWidgetById("building-empty-template");
		@m_wTemplateBuildingUnknown = m_widget.GetWidgetById("building-unknown-template");

		@m_spriteOre = m_def.GetSprite("ore");

		ReloadList();
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.townhall");
	}

	void AddButton(Widget@ wList, Upgrades::BuildingUpgrade@ upgrade, Upgrades::BuildingUpgradeStep@ step, Upgrades::BuildingUpgradeStep@ stepAbove, bool addSpacing)
	{
		auto record = GetLocalPlayerRecord();
		auto gm = cast<Town>(g_gameMode);

		string tooltipTitle;
		string tooltipSub;
		string tooltipText;

		TownBuilding@ building = null;

		if (step !is null && upgrade !is null)
		{
			@building = gm.m_town.GetBuilding(upgrade.m_id);

			tooltipTitle = step.GetTooltipTitle();
			tooltipSub = ("" + step.m_costOre);
			tooltipText = step.GetTooltipDescription();
		}

		vec2 offset;
		if (addSpacing)
			offset.x = 6;

		if (step is null || upgrade is null)
		{
			// There's no step
			auto wNewButton = m_wTemplateBuildingEmpty.Clone();
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.m_offset = offset;
			wList.AddChild(wNewButton);
		}
		else if (step.m_restrictFlag != "" && !g_flags.IsSet(step.m_restrictFlag))
		{
			// Step is not unlocked yet
			auto wNewButton = m_wTemplateBuildingUnknown.Clone();
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.m_offset = offset;
			wList.AddChild(wNewButton);
		}
		else if (step.IsOwned(record))
		{
			// Step is owned
			auto wNewButton = m_wTemplateBuildingOwned.Clone();
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.m_offset = offset;
			wNewButton.m_tooltipTitle = tooltipTitle;
			wNewButton.m_tooltipText = tooltipText;

			auto wIcon = cast<SpriteWidget>(wNewButton.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(step.GetSprite());

			wList.AddChild(wNewButton);
		}
		else if (m_shopMenu.m_currentShopLevel < step.m_restrictShopLevelMin || (stepAbove !is null && !stepAbove.IsOwned(record)))
		{
			// Shop level is not high enough for this step or the step above is not owned
			auto wNewButton = m_wTemplateBuildingUnavailable.Clone();
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.m_offset = offset;
			wNewButton.m_tooltipTitle = tooltipTitle;
			wNewButton.AddTooltipSub(m_spriteOre, tooltipSub);
			wNewButton.m_tooltipText = tooltipText;

			auto wIcon = cast<SpriteWidget>(wNewButton.GetWidgetById("icon"));
			if (wIcon !is null)
			{
				wIcon.m_colorize = true;
				wIcon.SetSprite(step.GetSprite());
			}

			wList.AddChild(wNewButton);
		}
		else if (m_shopMenu.m_currentShopLevel >= step.m_restrictShopLevelMin)
		{
			// Shop level is high enough to buy it
			auto wNewButton = m_wTemplateBuilding.Clone();
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.m_offset = offset;

			auto wButton = cast<UpgradeShopButtonWidget>(wNewButton.GetWidgetById("button"));
			wButton.Set(this, upgrade, step);
			wButton.m_tooltipTitle = tooltipTitle;
			wButton.AddTooltipSub(m_spriteOre, tooltipSub);
			wButton.m_tooltipText = tooltipText;
			
			if (!Network::IsServer())
				wButton.m_enabled = false;

			wList.AddChild(wNewButton);
		}
	}

	void ReloadList() override
	{
		m_wRowList.ClearChildren();

		auto player = GetLocalPlayer();
		if (player is null)
			return;

		for (int i = 0; i < m_numTiers; i++)
		{
			Upgrades::BuildingUpgrade@ townhallUpgrade = cast<Upgrades::BuildingUpgrade>(m_shop.m_upgrades[0]);
			Upgrades::BuildingUpgradeStep@ townhallStep = m_tiersTownhall[i];

			Widget@ wNewRow = null;
			if (i >= m_shopMenu.m_currentShopLevel)
			{
				@wNewRow = m_wTemplateRowUnavailable.Clone();

				auto wButton = cast<UpgradeShopButtonWidget>(wNewRow.GetWidgetById("button"));
				if (wButton !is null)
				{
					wButton.Set(this, townhallUpgrade, townhallStep);
					if (!Network::IsServer())
						wButton.m_enabled = false;
				}
			}
			else
			{
				@wNewRow = m_wTemplateRow.Clone();

				auto wIcon = cast<SpriteWidget>(wNewRow.GetWidgetById("icon"));
				if (wIcon !is null)
					wIcon.SetSprite(townhallStep.GetSprite());
			}

			wNewRow.SetID("");
			wNewRow.m_visible = true;

			auto wLevelIcon = cast<SpriteWidget>(wNewRow.GetWidgetById("icon-level"));
			if (wLevelIcon !is null)
				wLevelIcon.SetSprite("shop-level-" + (i + 1));

			m_wRowList.AddChild(wNewRow);

			auto wBuildingList = wNewRow.GetWidgetById("building-list");
			if (wBuildingList is null)
				break;

			for (uint j = 0; j < uint(m_numUpgrades); j++)
			{
				Upgrades::BuildingUpgrade@ listedUpgrade;
				Upgrades::BuildingUpgradeStep@ listedStep;
				Upgrades::BuildingUpgradeStep@ listedStepAbove;

				if (j + 1 < m_shop.m_upgrades.length())
					@listedUpgrade = cast<Upgrades::BuildingUpgrade>(m_shop.m_upgrades[j + 1]);
				if (j < m_tiers[i].length())
				{
					@listedStep = m_tiers[i][j];
					if (i > 0)
					{
						for (int k = 0; k < i; k++)
						{
							@listedStepAbove = m_tiers[i - k - 1][j];
							if (listedStepAbove !is null)
								break;
						}
					}
				}

				AddButton(wBuildingList, listedUpgrade, listedStep, listedStepAbove, j == 7);
			}
		}

		m_shopMenu.DoLayout();

		m_wSpecialSeparator.m_height = m_wRowList.m_height;
	}

	bool BuyItem(Upgrades::Upgrade@ upgrade, Upgrades::UpgradeStep@ step) override
	{
		if (!ShopMenuContent::BuyItem(upgrade, step))
			return false;

		Stats::Add("buildings-purchased", 1, GetLocalPlayerRecord());
		return true;
	}

	string GetGuiFilename() override
	{
		return "gui/shop/townhall.gui";
	}
}
