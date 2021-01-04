class DesertStoreMenuContent : DungeonStoreMenuContent
{
	DesertStoreMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu, "desertstore");
	}

	Widget@ AddItem(Widget@ template, Widget@ list, Upgrades::Upgrade@ upgrade) override
	{
		float costScale = 1.0f;

		auto shop = cast<Upgrades::ItemShop>(m_currentShop);
		if (shop !is null)
			costScale = shop.GetCostScale();

		auto mapUpgrade = cast<Upgrades::DesertMapUpgrade>(upgrade);
		if (mapUpgrade !is null)
			cast<Upgrades::DesertMapUpgradeStep>(mapUpgrade.m_step).UpdateCost(costScale);

		return DungeonStoreMenuContent::AddItem(template, list, upgrade);
	}
}
