class UpgradeIconWidget : Widget
{
	Sprite@ m_itemDot;
	Sprite@ m_itemPlus;

	Upgrades::UpgradeStep@ m_upgradeStep;

	Widget@ Clone() override
	{
		UpgradeIconWidget@ w = UpgradeIconWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		LoadWidthHeight(ctx, true);

		auto def = ctx.GetGUIDef();

		@m_itemDot = def.GetSprite("item-dot");
		@m_itemPlus = def.GetSprite("item-plus");
	}

	void Set(Upgrades::UpgradeStep@ step)
	{
		@m_upgradeStep = step;
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_upgradeStep is null)
			return;

		m_upgradeStep.DrawShopIcon(this, sb, pos, vec2(m_width, m_height), vec4(1, 1, 1, 1));
	}
}

ref@ LoadUpgradeIconWidget(WidgetLoadingContext &ctx)
{
	UpgradeIconWidget@ w = UpgradeIconWidget();
	w.Load(ctx);
	return w;
}
