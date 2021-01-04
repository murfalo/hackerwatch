class ColorCheckBoxWidget : CheckBoxWidget
{
	vec4 m_fillColor;

	ColorCheckBoxWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		CheckBoxWidget::Load(ctx);

		m_fillColor = ctx.GetColorRGBA("fill-color", false, vec4(0, 0, 0, 1));
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		sb.FillRectangle(vec4(
			pos.x, pos.y,
			m_width, m_height
		), m_fillColor);

		CheckBoxWidget::DoDraw(sb, pos);
	}
}

ref@ LoadColorCheckboxWidget(WidgetLoadingContext &ctx)
{
	ColorCheckBoxWidget@ w = ColorCheckBoxWidget();
	w.Load(ctx);
	return w;
}
