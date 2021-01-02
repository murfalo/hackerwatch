class ColorButtonWidget : SpriteButtonWidget
{
	Materials::IDyeState@ m_dyeState;
	bool m_selected;

	ColorButtonWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		ColorButtonWidget@ w = ColorButtonWidget();
		CloneInto(w);
		return w;
	}

	Sprite@ GetCurrentSprite() override
	{
		if (m_selected)
			return m_spriteDown;
		else
			return SpriteButtonWidget::GetCurrentSprite();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		SpriteButtonWidget::Load(ctx);
	}

	void Update(int dt) override
	{
		if (m_dyeState !is null)
			m_dyeState.Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		SpriteButtonWidget::DoDraw(sb, pos);

		if (m_dyeState is null)
			return;

		vec4 rectShade = vec4(pos.x + 4, pos.y + 4, 25, 12);

		auto shades = m_dyeState.GetShades(m_host.m_idt);

		for (uint i = 0; i < 3; i++)
		{
			vec4 rect = rectShade;
			rect.x += 25 * i;
			sb.FillRectangle(rect, shades[2 - i]);
		}
	}
}

ref@ LoadColorButtonWidget(WidgetLoadingContext &ctx)
{
	ColorButtonWidget@ w = ColorButtonWidget();
	w.Load(ctx);
	return w;
}
