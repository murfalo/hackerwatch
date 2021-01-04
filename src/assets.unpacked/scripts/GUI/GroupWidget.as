class GroupWidget : Widget
{
	bool m_dynamicWidth;
	bool m_dynamicHeight;
	bool m_innerSz;

	GroupWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		int w = ctx.GetInteger("width", false, -1);
		int h = ctx.GetInteger("height", false, -1);

		m_innerSz = ctx.GetBoolean("inner", false, false);

		if (w != -1)
		{
			m_width = w;
			m_dynamicWidth = false;
		}
		else
			m_dynamicWidth = true;

		if (h != -1)
		{
			m_height = h;
			m_dynamicHeight = false;
		}
		else
			m_dynamicHeight = true;

		Widget::Load(ctx);
	}

	Widget@ Clone() override
	{
		GroupWidget@ w = GroupWidget();
		CloneInto(w);
		return w;
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (!m_innerSz && (m_dynamicWidth || m_dynamicHeight))
		{
			if (m_dynamicWidth)
				m_width = int(parentSz.x);
			if (m_dynamicHeight)
				m_height = int(parentSz.y);

			//CalculateOrigin(origin, parentSz);
		}

		Widget::DoLayout(origin, parentSz);

		if (m_innerSz && (m_dynamicWidth || m_dynamicHeight))
		{
			float w = 0;
			float h = 0;

			for (uint i = 0; i < m_children.length(); i++)
			{
				auto c = m_children[i];
				if (!c.m_visible)
					continue;

				vec2 o = c.m_origin - m_origin;
				float x2 = o.x + c.m_width;
				float y2 = o.y + c.m_height;

				if (x2 > w) w = x2;
				if (y2 > h) h = y2;
			}

			if (m_dynamicWidth)
				m_width = int(w);
			if (m_dynamicHeight)
				m_height = int(h);
		}
	}
}

ref@ LoadGroupWidget(WidgetLoadingContext &ctx)
{
	GroupWidget@ w = GroupWidget();
	w.Load(ctx);
	return w;
}
