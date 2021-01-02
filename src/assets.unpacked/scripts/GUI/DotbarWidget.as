class DotbarWidget : Widget
{
	int m_max;
	int m_value;

	vec4 m_color;
	vec4 m_colorSet;
	vec4 m_colorUnset;

	int m_borderOffset;

	DotbarWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx, false);

		m_color = ParseColorRGBA("#000000FF");
		m_colorSet = ParseColorRGBA("#42FF00FF");
		m_colorUnset = ParseColorRGBA("#3B662CFF");

		m_borderOffset = 1;

		Widget::Load(ctx);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_max == 0)
			return;

		float dotWidth = m_width / float(m_max);

		for (int i = 0; i < m_max; i++)
		{
			vec4 rect;
			rect.x = pos.x + dotWidth * i;
			rect.y = pos.y;
			rect.z = dotWidth;
			rect.w = m_height;
			sb.FillRectangle(rect, m_color);

			vec4 color = m_colorSet;
			if (i >= m_value)
				color = m_colorUnset;

			rect.x += m_borderOffset;
			rect.y += m_borderOffset;
			rect.z -= m_borderOffset * 2;
			rect.w -= m_borderOffset * 2;
			sb.FillRectangle(rect, color);
		}
	}
}

ref@ LoadDotbarWidget(WidgetLoadingContext &ctx)
{
	DotbarWidget@ w = DotbarWidget();
	w.Load(ctx);
	return w;
}
