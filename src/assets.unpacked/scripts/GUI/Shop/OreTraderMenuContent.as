class OreTraderMenuContent : ShopMenuContent
{
	OreTraderMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);
	}

	string GetGuiFilename() override
	{
		return "gui/shop/upgrades.gui";
	}
}
