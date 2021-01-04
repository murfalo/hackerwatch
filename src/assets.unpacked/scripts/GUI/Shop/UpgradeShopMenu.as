class UpgradeShopMenuContent : ShopMenuContent
{
	Widget@ m_wItemTemplate;
	Widget@ m_wItemTemplateSmall;
	Widget@ m_wItemList;
	Widget@ m_wItemListSmallContainer;
	Widget@ m_wItemListSmall;

	Widget@ m_wSoldOut;

	Upgrades::Shop@ m_currentShop;

	UpgradeShopMenuContent(ShopMenu@ shopMenu, string id)
	{
		super(shopMenu);

		@m_currentShop = Upgrades::GetShop(id);
		if (m_currentShop is null)
			PrintError("Shop \"" + id + "\" is not loaded!");
	}

	string GetTitle() override
	{
		return Resources::GetString(m_currentShop.m_name);
	}

	void OnShow() override
	{
		@m_wItemTemplate = m_widget.GetWidgetById("buy-template");
		@m_wItemTemplateSmall = m_widget.GetWidgetById("buy-template-small");
		@m_wItemList = m_widget.GetWidgetById("buy-list");
		@m_wItemListSmallContainer = m_widget.GetWidgetById("small-buy-list-container");
		@m_wItemListSmall = m_widget.GetWidgetById("small-buy-list");

		@m_wSoldOut = m_widget.GetWidgetById("sold-out");

		ReloadList();
	}

	string GetGuiFilename() override
	{
		return "gui/shop/upgrades.gui";
	}

	Widget@ AddItem(Widget@ template, Widget@ list, Upgrades::Upgrade@ upgrade)
	{
		auto wNewItem = template.Clone();
		wNewItem.SetID("");
		wNewItem.m_visible = true;

		auto btn = cast<UpgradeShopButtonWidget>(wNewItem.GetWidgetById("button"));
		if (btn is null)
			@btn = cast<UpgradeShopButtonWidget>(wNewItem);

		btn.Set(this, upgrade);

		list.AddChild(wNewItem);
		return wNewItem;
	}

	void ClearList(Widget@ list)
	{
		for (int i = list.m_children.length() - 1; i >= 0; i--)
		{
			auto w = list.m_children[i];
			if (w.m_id == "")
				w.RemoveFromParent();
		}
	}

	void ReloadList() override
	{
		ClearList(m_wItemList);
		ClearList(m_wItemListSmall);

		m_shopMenu.CloseTooltip();

		m_wItemListSmallContainer.m_visible = false;

		if (m_currentShop is null)
			return;

		auto record = GetLocalPlayerRecord();

		m_currentShop.OnOpenMenu(m_shopMenu.m_currentShopLevel, record);

		int numItems = 0;
		for (auto iter = m_currentShop.Iterate(m_shopMenu.m_currentShopLevel, record); !iter.AtEnd(); iter.Next())
		{
			Widget@ btn = null;

			auto upgrade = iter.Current();
			if (upgrade.m_small)
			{
				@btn = AddItem(m_wItemTemplateSmall, m_wItemListSmall, upgrade);
				m_wItemListSmallContainer.m_visible = true;
			}
			else
				@btn = AddItem(m_wItemTemplate, m_wItemList, upgrade);

			if (btn.m_visible)
				numItems++;
		}

		m_wSoldOut.m_visible = (numItems == 0);

		m_shopMenu.DoLayout();
		m_shopMenu.DoLayout();

		m_shopMenu.m_forceFocus = true;
	}
}
