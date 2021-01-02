class ChapelShopMenuContent : ShopMenuContent
{
	Widget@ m_wRowList;
	Widget@ m_wTemplateRow;

	Widget@ m_wTemplateItemContainer;
	UpgradeShopButtonWidget@ m_wTemplateItem;
	Widget@ m_wTemplateUnknown;
	Widget@ m_wTemplateOwned;
	Widget@ m_wTemplateLocked;
	Widget@ m_wTemplateUnlocked;

	Sprite@ m_spriteGold;

	Upgrades::ChapelShop@ m_shop;

	array<array<RectWidget@>@> m_itemContainers;

	ChapelShopMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);

		@m_shop = cast<Upgrades::ChapelShop>(Upgrades::GetShop("chapel"));
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.chapel");
	}

	void OnShow() override
	{
		@m_wRowList = m_widget.GetWidgetById("row-list");
		@m_wTemplateRow = m_widget.GetWidgetById("row-template");

		@m_wTemplateItemContainer = m_widget.GetWidgetById("item-container-template");
		@m_wTemplateItem = cast<UpgradeShopButtonWidget>(m_widget.GetWidgetById("item-template"));
		@m_wTemplateUnknown = m_widget.GetWidgetById("item-template-unknown");
		@m_wTemplateOwned = m_widget.GetWidgetById("item-template-owned");
		@m_wTemplateLocked = m_widget.GetWidgetById("item-template-locked");
		@m_wTemplateUnlocked = m_widget.GetWidgetById("item-template-unlocked");

		@m_spriteGold = m_def.GetSprite("icon-gold");

		ReloadList();
	}

	// Return -1 for locked item if not owned
	// Return 0 for unknown item
	// Return 1 to enable
	int ShouldEnableButton(uint rowIndex, uint columnIndex)
	{
		if (int(rowIndex) >= m_shopMenu.m_currentShopLevel)
			return 0;

		auto record = GetLocalPlayerRecord();
		auto row = m_shop.m_rows[rowIndex];

		for (uint i = 0; i < row.length(); i++)
		{
			if (row[i].IsOwned(record))
				return -1;
		}

		if (rowIndex == 0)
			return 1;

		auto rowAbove = m_shop.m_rows[rowIndex - 1];

		bool anyOwnedAbove = false;
		for (uint i = 0; i < rowAbove.length(); i++)
		{
			if (rowAbove[i].IsOwned(record))
			{
				anyOwnedAbove = true;
				break;
			}
		}

		if (anyOwnedAbove)
			return 1;
		else
			return -1;
	}

	void ReloadList() override
	{
		//TODO: We have to hide the tooltip here

		m_itemContainers.removeRange(0, m_itemContainers.length());

		m_wRowList.ClearChildren();

		auto record = GetLocalPlayerRecord();

		// For each row
		for (uint i = 0; i < m_shop.m_rows.length(); i++)
		{
			auto wRowContainer = m_wTemplateRow.Clone();
			wRowContainer.SetID("");
			wRowContainer.m_visible = true;
			m_wRowList.AddChild(wRowContainer);

			auto wRowItems = wRowContainer.GetWidgetById("items");

			Widget@ wNewItem = null;

			array<RectWidget@>@ arrContainers = array<RectWidget@>();
			m_itemContainers.insertLast(arrContainers);

			auto row = m_shop.m_rows[i];

			// For each item in the row
			for (uint j = 0; j < row.length(); j++)
			{
				auto upgrade = row[j];
				auto step = upgrade.GetStep(1);

				int shouldEnable = ShouldEnableButton(i, j);
				bool unlocked = (record.chapelUpgradesPurchased.find(upgrade.m_id) != -1);

				Titles::Title@ missingRequiredTitle = null;
				if (step.m_restrictPlayerTitleMin != -1)
				{
					if (step.m_restrictPlayerTitleMin > record.GetTitleIndex())
					{
						shouldEnable = -1;
						auto titleList = record.GetTitleList();
						@missingRequiredTitle = titleList.GetTitle(step.m_restrictPlayerTitleMin);
					}
				}

				if (shouldEnable == 0)
				{
					Widget@ newItem = null;
					if (int(i) >= m_shopMenu.m_currentShopLevel)
						@newItem = m_wTemplateUnknown.Clone();
					else
						@newItem = m_wTemplateUnlocked.Clone();

					newItem.SetID("");
					newItem.m_visible = true;

					newItem.m_tooltipTitle = step.GetTooltipTitle();
					newItem.m_tooltipText = step.GetTooltipDescription();
					if (!unlocked)
						newItem.AddTooltipSub(m_spriteGold, formatThousands(step.m_costGold));

					auto wIcon = cast<SpriteWidget>(newItem.GetWidgetById("icon"));
					if (wIcon !is null)
						wIcon.SetSprite(step.GetSprite());

					@wNewItem = newItem;
				}
				else if (shouldEnable == -1 && !step.IsOwned(record))
				{
					Widget@ newItem = null;
					if (unlocked)
						@newItem = m_wTemplateUnlocked.Clone();
					else
						@newItem = m_wTemplateLocked.Clone();
					newItem.SetID("");
					newItem.m_visible = true;

					newItem.m_tooltipTitle = step.GetTooltipTitle();
					newItem.m_tooltipText = step.GetTooltipDescription();
					if (!unlocked)
						newItem.AddTooltipSub(m_spriteGold, formatThousands(step.m_costGold));

					auto wIcon = cast<SpriteWidget>(newItem.GetWidgetById("icon"));
					if (wIcon !is null)
					{
						wIcon.m_colorize = (missingRequiredTitle !is null || !step.CanAfford(record));
						wIcon.SetSprite(step.GetSprite());
					}

					if (missingRequiredTitle !is null)
					{
						newItem.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.menu.restriction.player-title", {
							{ "title", Resources::GetString(missingRequiredTitle.m_name) }
						});
					}

					@wNewItem = newItem;
				}
				else if (step.IsOwned(record))
				{
					auto newItem = m_wTemplateOwned.Clone();
					newItem.SetID("");
					newItem.m_visible = true;

					newItem.m_tooltipTitle = step.GetTooltipTitle();
					newItem.m_tooltipText = step.GetTooltipDescription();

					auto wIcon = cast<SpriteWidget>(newItem.GetWidgetById("icon"));
					if (wIcon !is null)
						wIcon.SetSprite(step.GetSprite());

					@wNewItem = newItem;
				}
				else
				{
					auto newButton = cast<UpgradeShopButtonWidget>(m_wTemplateItem.Clone());
					newButton.SetID("");
					newButton.m_visible = true;

					newButton.Set(this, upgrade, step);
					newButton.m_enabled = (newButton.m_enabled && shouldEnable == 1);

					//@newButton.m_scriptSpriteIcon = step.m_icon;

					if (!unlocked)
						newButton.AddTooltipSub(m_spriteGold, formatThousands(step.m_costGold));

					auto wIconUnlock = newButton.GetWidgetById("icon-unlock");
					if (wIconUnlock !is null)
						wIconUnlock.m_visible = unlocked;

					@wNewItem = newButton;
				}

				if (wNewItem !is null)
				{
					auto wNewContainer = cast<RectWidget>(m_wTemplateItemContainer.Clone());
					wNewContainer.SetID("");
					wNewContainer.m_visible = true;
					wNewContainer.m_borderColor.w = 0.0f;
					wNewContainer.AddChild(wNewItem);
					wRowItems.AddChild(wNewContainer);

					arrContainers.insertLast(wNewContainer);
				}
			}
		}

		m_shopMenu.DoLayout();
	}

	bool BuyItem(Upgrades::Upgrade@ upgrade, Upgrades::UpgradeStep@ step) override
	{
		auto record = GetLocalPlayerRecord();
		bool unlocked = (record.chapelUpgradesPurchased.find(upgrade.m_id) != -1);

		if (!ShopMenuContent::BuyItem(upgrade, step))
			return false;

		if (!unlocked)
			Stats::Add("blessings-purchased", 1, GetLocalPlayerRecord());

		return true;
	}

	string GetGuiFilename() override
	{
		return "gui/shop/chapel.gui";
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "convert")
		{
			auto record = GetLocalPlayerRecord();

			for (uint i = 0; i < m_shop.m_rows.length(); i++)
			{
				auto row = m_shop.m_rows[i];
				for (uint x = 0; x < row.length(); x++)
				{
					auto upgr = row[x];
					if (!upgr.IsOwned(record))
						continue;

					for (uint j = 0; j < record.upgrades.length(); j++)
					{
						auto ownedUpgrade = record.upgrades[j];
						if (ownedUpgrade.m_id == upgr.m_id)
						{
							record.upgrades.removeAt(j);
							break;
						}
					}
				}
			}

			//TODO: Netsync?

			GetLocalPlayer().RefreshModifiers();

			ReloadList();
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}
}
