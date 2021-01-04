void SetActorItemOnGui(PlayerRecord@ record, Widget@ wItem, ActorItem@ item)
{
	wItem.m_tooltipTitle = "\\c" + GetItemQualityColorString(item.quality) + utf8string(Resources::GetString(item.name)).toUpper().plain();
	wItem.m_tooltipText = Resources::GetString(item.desc);

	if (item.set !is null)
	{
		wItem.m_tooltipText += "\n\n";
		wItem.m_tooltipText += GetItemSetColorString(record, item);
	}

	auto wItemIcon = cast<SpriteWidget>(wItem.GetWidgetById("item-icon"));
	if (wItemIcon !is null)
		wItemIcon.SetSprite(item.icon);

	auto wItemAttuned = wItem.GetWidgetById("item-attuned");
	if (wItemAttuned !is null && record.itemForgeAttuned.find(item.idHash) != -1)
		wItemAttuned.m_visible = true;

	auto wItemSet = cast<SpriteWidget>(wItem.GetWidgetById("item-set"));
	if (wItemSet !is null && item.set !is null)
	{
		wItemSet.m_visible = true;
		wItemSet.m_color = ParseColorRGBA("#" + SetItemColorString + "FF");
	}

	auto wItemQuality = cast<SpriteWidget>(wItem.GetWidgetById("item-quality"));
	if (wItemQuality !is null && item.quality != ActorItemQuality::Common)
	{
		wItemQuality.m_visible = true;
		wItemQuality.m_color = GetItemQualityColor(item.quality);
	}
}

Widget@ AddActorItemToGuiList(PlayerRecord@ record, Widget@ wList, Widget@ wTemplate, ActorItem@ item)
{
	auto wNewItem = wTemplate.Clone();
	wNewItem.SetID("");
	wNewItem.m_visible = true;

	auto wCheck = cast<CheckBoxWidget>(wNewItem);
	if (wCheck !is null)
		wCheck.m_value = item.id;

	SetActorItemOnGui(record, wNewItem, item);

	wList.AddChild(wNewItem);

	return wNewItem;
}
