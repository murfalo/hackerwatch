class ScrollableRectWidget : ScrollableWidget
{
	vec4 m_color;

	vec4 m_borderColor;
	int m_borderWidth;
	BorderType m_borderType;

	vec4 m_shadowColor;
	int m_shadowSize;

	SpriteRect@ m_spriteRect;

	ScrollableRectWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		ScrollableRectWidget@ w = ScrollableRectWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx);

		m_color = ctx.GetColorRGBA("color", false, vec4(0, 0, 0, 0));

		m_borderColor = ctx.GetColorRGBA("border", false, vec4(0, 0, 0, 0));
		m_borderWidth = ctx.GetInteger("borderwidth", false, 1);
		string borderType = ctx.GetString("bordertype", false, "inner");
		     if (borderType == "middle") m_borderType = BorderType::Middle;
		else if (borderType == "outer") m_borderType = BorderType::Outer;

		m_shadowColor = ctx.GetColorRGBA("shadow", false, vec4(0, 0, 0, 0.5f));
		m_shadowSize = ctx.GetInteger("shadowsize", false, 0);

		string spriteset = ctx.GetString("spriteset", false, "");
		if (spriteset != "")
			@m_spriteRect = SpriteRect(spriteset);

		ScrollableWidget::Load(ctx);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		ScrollableWidget::DoDraw(sb, pos);

		vec4 p = vec4(pos.x, pos.y, m_width, m_height);
		sb.DrawSprite(null, p, p, m_color);

		if (m_shadowSize > 0 && m_shadowColor.a > 0)
		{
			vec4 sp;
			sp = vec4(pos.x, pos.y, m_width, m_shadowSize); sb.DrawSprite(null, sp, sp, m_shadowColor);
			sp = vec4(pos.x, pos.y + m_shadowSize, m_shadowSize, m_height - m_shadowSize); sb.DrawSprite(null, sp, sp, m_shadowColor);
		}

		DrawBorder(sb, pos, vec2(m_width, m_height), m_borderWidth, m_borderColor, m_borderType);

		if (m_spriteRect !is null)
			m_spriteRect.Draw(sb, pos, m_width, m_height);
	}

	void AnimateSet(string key, vec4 v) override
	{
		if (key == "color")
			m_color = v;
		else if (key == "border")
			m_borderColor = v;
		ScrollableWidget::AnimateSet(key, v);
	}
}

ref@ LoadScrollableRectWidget(WidgetLoadingContext &ctx)
{
	ScrollableRectWidget@ w = ScrollableRectWidget();
	w.Load(ctx);
	return w;
}
