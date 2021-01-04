class SortableItemiaryEntry
{
	ItemiaryEntry@ m_entry;

	SortableItemiaryEntry(ItemiaryEntry@ entry)
	{
		@m_entry = entry;
	}

	int opCmp(const SortableItemiaryEntry &in other) const
	{
		if (m_entry.m_item.quality > other.m_entry.m_item.quality)
			return 1;
		else if (m_entry.m_item.quality < other.m_entry.m_item.quality)
			return -1;

		string nameSelf = Resources::GetString(m_entry.m_item.name);
		string nameOther = Resources::GetString(other.m_entry.m_item.name);
		return nameSelf.opCmp(nameOther);
	}
}

class GuildHallItemiaryTab : GuildHallMenuTab
{
	Widget@ m_wListItems;
	Widget@ m_wListDrinks;

	Widget@ m_wTemplateItem;
	Widget@ m_wTemplateItemNothing;

	Widget@ m_wTemplateDrink;

	GuildHallItemiaryTab()
	{
		m_id = "itemiary";
	}

	void OnShow() override
	{
		@m_wListItems = m_widget.GetWidgetById("list-items");
		@m_wListDrinks = m_widget.GetWidgetById("list-drinks");

		@m_wTemplateItem = m_widget.GetWidgetById("template-item");
		@m_wTemplateItemNothing = m_widget.GetWidgetById("template-item-nothing");

		@m_wTemplateDrink = m_widget.GetWidgetById("template-drink");

		ReloadList();
	}

	void ReloadList()
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		array<SortableItemiaryEntry@> items;
		for (uint i = 0; i < town.m_itemiary.length(); i++)
			items.insertLast(SortableItemiaryEntry(town.m_itemiary[i]));
		items.sortDesc();

		m_wListItems.ClearChildren();
		m_wListItems.m_height = int(ceil(items.length() / 2.0f)) * 22;

		for (uint i = 0; i < items.length(); i++)
			AddItem(items[i].m_entry);

		if (town.m_itemiary.length() % 2 == 1)
			AddItemNothing();

		m_wListDrinks.ClearChildren();

		int numDrinks = 0;
		for (uint i = 0; i < g_tavernDrinks.length(); i++)
		{
			auto drink = g_tavernDrinks[i];
			if (drink.localCount == -1)
				continue;

			AddDrink(drink);
			numDrinks++;
		}

		m_wListDrinks.m_height = 5 + int(ceil(numDrinks / 11.0f)) * (m_wTemplateDrink.m_height + 2) + 5;

		Invalidate();
	}

	void AddItem(ItemiaryEntry@ entry)
	{
		ActorItem@ item = entry.m_item;

		auto wNewItem = m_wTemplateItem.Clone();
		wNewItem.SetID("");
		wNewItem.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(item.icon);

		vec4 qualityColor = GetItemQualityColor(item.quality);

		auto wNameContainer = cast<RectWidget>(wNewItem.GetWidgetById("name-container"));
		if (wNameContainer !is null)
		{
			if (item.quality != ActorItemQuality::Common)
				wNameContainer.m_color = desaturate(qualityColor);

			auto wName = cast<TextWidget>(wNameContainer.GetWidgetById("name"));
			if (wName !is null)
			{
				wName.SetText(Resources::GetString(item.name));
				if (item.quality != ActorItemQuality::Common)
					wName.SetColor(qualityColor);

				wName.m_tooltipTitle = "\\c" + GetItemQualityColorString(item.quality) + utf8string(Resources::GetString(item.name)).toUpper().plain();
				wName.m_tooltipText = Resources::GetString(item.desc);

				if (item.set !is null)
				{
					wName.m_tooltipText += "\n\n";
					wName.m_tooltipText += GetItemSetColorString(GetLocalPlayerRecord(), item);
				}

				wName.m_tooltipText += "\n\n" + Resources::GetString(".itemiary.itemcount") + ": " + formatThousands(entry.m_count);
			}
		}

		m_wListItems.AddChild(wNewItem);
	}

	void AddItemNothing()
	{
		auto wNewNothing = m_wTemplateItemNothing.Clone();
		wNewNothing.SetID("");
		wNewNothing.m_visible = true;
		m_wListItems.AddChild(wNewNothing);
	}

	void AddDrink(TavernDrink@ drink)
	{
		auto wNewDrink = m_wTemplateDrink.Clone();
		wNewDrink.SetID("");
		wNewDrink.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wNewDrink.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(drink.icon);

		wNewDrink.m_tooltipTitle = "\\c" + GetItemQualityColorString(drink.quality) + utf8string(Resources::GetString(drink.name)).toUpper().plain();
		wNewDrink.m_tooltipText = Resources::GetString(drink.desc);

		m_wListDrinks.AddChild(wNewDrink);
	}
}
