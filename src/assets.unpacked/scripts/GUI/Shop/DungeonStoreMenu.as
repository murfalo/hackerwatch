class DungeonStoreMenuContent : UpgradeShopMenuContent
{
	Upgrades::DungeonShop@ m_itemShop;

	DungeonStoreMenuContent(ShopMenu@ shopMenu, string id = "dungeonstore")
	{
		super(shopMenu, id);

		@m_itemShop = cast<Upgrades::DungeonShop>(m_currentShop);
		if (m_itemShop is null)
			PrintError("\"" + id + "\" is not a dungeon shop!");
	}

	string GetGuiFilename() override
	{
		return "gui/shop/dungeonstore.gui";
	}

	bool ShouldShowStars() override
	{
		return false;
	}

	bool BuyItem(Upgrades::Upgrade@ upgrade, Upgrades::UpgradeStep@ step) override
	{
		if (UpgradeShopMenuContent::BuyItem(upgrade, step))
		{
			auto record = GetLocalPlayerRecord();
			if (cast<Upgrades::ItemUpgrade>(upgrade) !is null)
				record.generalStoreItemsBought++;
			return true;
		}
		return false;
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

			auto wButton = cast<UpgradeShopButtonWidget>(wNewItem.GetWidgetById("button"));
			if (wButton !is null && wButton.m_enabled)
			{
				auto record = GetLocalPlayerRecord();
				wButton.m_enabled = wButton.m_enabled && (record.generalStoreItemsBought < m_itemShop.GetMaxItems());
			}
		}
		else
		{
			auto wButton = cast<UpgradeShopButtonWidget>(wNewItem);
			if (wButton !is null)
				wButton.m_enabled = wButton.m_enabled && !upgrade.IsOwned(GetLocalPlayerRecord());
		}

		return wNewItem;
	}

	void ReloadList() override
	{
		UpgradeShopMenuContent::ReloadList();

		auto wTemplateBuysLeft = m_widget.GetWidgetById("buys-left");
		auto wList = m_widget.GetWidgetById("buy-list");

		int maxItems = m_itemShop.GetMaxItems();

		if (!m_wSoldOut.m_visible)
		{
			auto record = GetLocalPlayerRecord();

			auto wBuysLeft = wTemplateBuysLeft.Clone();
			wBuysLeft.SetID("");
			wBuysLeft.m_visible = true;

			auto wLimit = cast<TextWidget>(wBuysLeft.GetWidgetById("limit"));
			if (wLimit !is null)
			{
				wLimit.SetText(record.generalStoreItemsBought + " / " + maxItems);

				if (record.generalStoreItemsBought >= maxItems)
					wLimit.SetColor(vec4(1, 0, 0, 1));
			}

			wList.AddChild(wBuysLeft);
		}

		// Ughhhhh
		m_shopMenu.DoLayout();
		m_shopMenu.DoLayout();
	}
}
