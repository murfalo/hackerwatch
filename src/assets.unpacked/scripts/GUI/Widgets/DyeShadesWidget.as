class DyeShadesWidget : Widget
{
	Materials::IDyeState@ m_dyeState;

	DyeShadesWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		DyeShadesWidget@ w = DyeShadesWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx);

		Widget::Load(ctx);
	}

	void Update(int dt) override
	{
		if (m_dyeState !is null)
			m_dyeState.Update(dt);

		Widget::Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_dyeState is null)
			return;

		int blockWidth = m_width / 3;
		int blockRest = m_width - blockWidth * 3;

		auto shades = m_dyeState.GetShades(m_host.m_idt);
		for (uint i = 0; i < 3; i++)
		{
			int x = i * blockWidth;
			if (i == 2)
				x += blockRest;

			int w = blockWidth;
			if (i == 1)
				w += blockRest;

			vec4 rect = vec4(
				pos.x + x, pos.y,
				w, m_height
			);
			sb.FillRectangle(rect, shades[2 - i]);
		}

		Widget::DoDraw(sb, pos);
	}
}

ref@ LoadDyeShadesWidget(WidgetLoadingContext &ctx)
{
	DyeShadesWidget@ w = DyeShadesWidget();
	w.Load(ctx);
	return w;
}
