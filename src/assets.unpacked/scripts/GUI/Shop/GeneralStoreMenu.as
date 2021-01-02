class GeneralStoreMenuContent : UpgradeShopMenuContent
{
	Widget@ m_wRerollTemplate;
	Widget@ m_wReroll;

	Upgrades::ItemShop@ m_itemShop;

	GeneralStoreMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu, "generalstore");

		@m_itemShop = cast<Upgrades::ItemShop>(m_currentShop);
		if (m_itemShop is null)
			PrintError("\"generalstore\" is not an item shop!");
	}

	int GetRerollCost()
	{
		return 100;
	}

	string GetGuiFilename() override
	{
		return "gui/shop/generalstore.gui";
	}

	void OnShow() override
	{
		@m_wRerollTemplate = m_widget.GetWidgetById("reroll");

		UpgradeShopMenuContent::OnShow();
	}

	Widget@ AddItem(Widget@ template, Widget@ list, Upgrades::Upgrade@ upgrade) override
	{
		auto wNewItem = UpgradeShopMenuContent::AddItem(template, list, upgrade);

		auto itemUpgrade = cast<Upgrades::ItemUpgrade>(upgrade);
		if (itemUpgrade !is null)
		{
			auto wIconContainer = cast<RectWidget>(wNewItem.GetWidgetById("icon-container"));
			if (wIconContainer !is null && itemUpgrade.m_item.quality != ActorItemQuality::Common)
				wIconContainer.m_color = GetItemQualityBackgroundColor(itemUpgrade.m_item.quality);

			auto wIcon = cast<UpgradeIconWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.Set(itemUpgrade.m_step);
		}

		return wNewItem;
	}

	void ReloadList() override
	{
		if (m_wReroll !is null)
			m_wReroll.RemoveFromParent();

		UpgradeShopMenuContent::ReloadList();

		if (!m_wSoldOut.m_visible)
		{
			@m_wReroll = m_wRerollTemplate.Clone();
			m_wReroll.SetID("");
			m_wReroll.m_visible = true;

			auto wRerollButton = cast<ScalableSpriteIconButtonWidget>(m_wReroll.GetWidgetById("button"));
			if (wRerollButton !is null)
			{
				int cost = GetRerollCost();

				int numItemsNow = int(GetLocalPlayerRecord().generalStoreItems.length());
				int numItemsOriginal = m_itemShop.ItemsForLevel(m_shopMenu.m_currentShopLevel);

				wRerollButton.m_enabled = (Currency::CanAfford(cost) && numItemsNow == numItemsOriginal);
				if (wRerollButton.m_enabled)
					wRerollButton.SetText(Resources::GetString(".shop.generalstore.reroll", { { "cost", cost } }));
				else
					wRerollButton.SetText(Resources::GetString(".shop.generalstore.rerolldisabled"));
			}

			m_wItemList.AddChild(m_wReroll);
		}

		// Ughhhhh
		m_shopMenu.DoLayout();
		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "reroll")
		{
			int cost = GetRerollCost();

			if (!Currency::CanAfford(cost))
			{
				PrintError("Not enough gold to reroll general store!");
				return;
			}

			Currency::Spend(cost);

			auto player = GetLocalPlayerRecord();

			auto itemShop = cast<Upgrades::ItemShop>(m_currentShop);
			itemShop.RerollItems(m_shopMenu.m_currentShopLevel, player);

			ReloadList();
		}
		else
			UpgradeShopMenuContent::OnFunc(sender, name);
	}
}
