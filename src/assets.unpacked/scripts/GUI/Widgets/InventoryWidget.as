class InventoryWidget : ScrollableRectWidget
{
	InventoryItemWidget@ m_itemTemplate;

	bool m_local;

	InventoryWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		ScrollableRectWidget::Load(ctx);
	}

	void UpdateFromRecord(PlayerRecord@ record)
	{
		ClearChildren();
		for (uint j = 0; j < record.items.length(); j++)
			AddItem(record, g_items.GetItem(record.items[j]));
	}

	void AddItem(PlayerRecord@ record, ActorItem@ item)
	{
		auto wNewItem = cast<InventoryItemWidget>(m_itemTemplate.Clone());
		if (wNewItem is null)
			return;

		wNewItem.Set(record, item);
		wNewItem.SetID("");
		wNewItem.m_visible = true;

		AddChild(wNewItem);
	}
}

ref@ LoadInventoryWidget(WidgetLoadingContext &ctx)
{
	InventoryWidget@ w = InventoryWidget();
	w.Load(ctx);
	return w;
}
