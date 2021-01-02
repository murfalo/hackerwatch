class ClipWidget : Widget
{
	bool m_clipping = true;
	vec4 m_clipPadding;

	ClipWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		ClipWidget@ w = ClipWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext& ctx) override
	{
		m_clipping = ctx.GetBoolean("clipping", false, m_clipping);
		m_clipPadding = ctx.GetVector4("clippadding", false);

		LoadWidthHeight(ctx, false);

		Widget::Load(ctx);
	}

	void Draw(SpriteBatch& sb, bool debugDraw = false) override
	{
		if (m_clipping)
		{
			sb.PushClipping(vec4(
				m_origin.x, m_origin.y,
				m_width, m_height
			));
		}

		Widget::Draw(sb, debugDraw);

		if (m_clipping)
			sb.PopClipping();
	}

	void DrawChildren(SpriteBatch& sb, bool debugDraw = false) override
	{
		bool useDoubleClipping = (m_clipping && lengthsq(m_clipPadding) > 0 && m_children.length() > 0);
		if (useDoubleClipping)
		{
			sb.PushClipping(vec4(
				m_origin.x + m_clipPadding.x,
				m_origin.y + m_clipPadding.y,
				m_width - m_clipPadding.x - m_clipPadding.z,
				m_height - m_clipPadding.y - m_clipPadding.w
			));
		}

		Widget::DrawChildren(sb, debugDraw);

		if (useDoubleClipping)
			sb.PopClipping();
	}
}

ref@ LoadClipWidget(WidgetLoadingContext &ctx)
{
	ClipWidget@ w = ClipWidget();
	w.Load(ctx);
	return w;
}
