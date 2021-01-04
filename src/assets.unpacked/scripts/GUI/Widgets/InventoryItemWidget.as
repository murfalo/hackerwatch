class InventoryItemWidget : Widget
{
	PlayerRecord@ m_record;
	ActorItem@ m_item;

	Sprite@ m_spriteDot;
	Sprite@ m_spritePlus;

	vec4 m_colorItem;
	vec4 m_colorSet;

	bool m_hasBonus;
	bool m_isAttuned;

	InventoryItemWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		InventoryItemWidget@ w = InventoryItemWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		LoadWidthHeight(ctx);

		auto def = ctx.GetGUIDef();
		@m_spriteDot = def.GetSprite("inventory-item-dot");
		@m_spritePlus = def.GetSprite("inventory-item-plus");

		m_canFocus = true;
	}

	void Set(PlayerRecord@ record, ActorItem@ item)
	{
		@m_record = record;
		@m_item = item;

		m_tooltipTitle = "\\c" + GetItemQualityColorString(item.quality) + utf8string(Resources::GetString(item.name)).toUpper().plain();
		m_tooltipText = Resources::GetString(item.desc);

		if (item.set !is null)
		{
			m_tooltipText += "\n\n";
			m_tooltipText += GetItemSetColorString(record, item);

			auto ownedSet = record.GetOwnedItemSet(item.set);
			if (ownedSet !is null)
				m_hasBonus = true;
				//m_hasBonus = (ownedSet.m_count > 1);
				//m_hasBonus = ownedSet.IsAnyBonusActive();
		}

		m_colorItem = GetItemQualityColor(item.quality);
		m_colorSet = ParseColorRGBA("#" + SetItemColorString + "FF");

		m_isAttuned = (record.itemForgeAttuned.find(item.idHash) != -1);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		m_item.icon.Draw(sb, pos + vec2(2, 2), g_menuTime);

		int dotX = m_width - m_spriteDot.GetWidth() - 2;
		int dotY = m_height - m_spriteDot.GetHeight() - 2;

		if (m_item.quality != ActorItemQuality::Common)
		{
			vec2 dotPos = pos + vec2(dotX, dotY);
			sb.DrawSprite(dotPos, m_spriteDot, g_menuTime, m_colorItem);
			dotX -= m_spriteDot.GetWidth() - 1;
		}

		if (m_hasBonus)
		{
			vec2 dotPos = pos + vec2(dotX, dotY);
			sb.DrawSprite(dotPos, m_spriteDot, g_menuTime, m_colorSet);
			dotX -= m_spriteDot.GetWidth() - 1;
		}

		if (m_isAttuned)
			sb.DrawSprite(pos + vec2(2, 2), m_spritePlus, g_menuTime);
	}
}

ref@ LoadInventoryItemWidget(WidgetLoadingContext &ctx)
{
	InventoryItemWidget@ w = InventoryItemWidget();
	w.Load(ctx);
	return w;
}
