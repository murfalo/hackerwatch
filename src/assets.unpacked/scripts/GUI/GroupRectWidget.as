class GroupRectWidget : RectWidget
{
	bool m_dynamicWidth;
	bool m_dynamicHeight;
	bool m_innerSz;

	// Option that fixes fill behavior in automatically-offset widgets using flow="[vh]box"
	// Also see the //TODO about this below!
	bool m_fillRest;

	GroupRectWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		GroupRectWidget@ w = GroupRectWidget();
		CloneInto(w);
		return w;
	}

	void LoadWidthHeight(WidgetLoadingContext &ctx, bool required = true) override
	{
		// :D
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		int w = ctx.GetInteger("width", false, -1);
		int h = ctx.GetInteger("height", false, -1);

		m_innerSz = ctx.GetBoolean("inner", false, false);
		m_fillRest = ctx.GetBoolean("fill-rest", false, false);

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

		RectWidget::Load(ctx);
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (!m_innerSz && (m_dynamicWidth || m_dynamicHeight))
		{
			int w = m_width;
			int h = m_height;

			if (m_dynamicWidth)
				w = int(parentSz.x);
			if (m_dynamicHeight)
				h = int(parentSz.y);

			//TODO: Remove this option and use the code from this option instead of the
			//      code below when the option is disabled.
			//
			//      Only reason this is here right now is because I don't know which
			//      widgets are using this code and if things might break if we change
			//      this behavior right now.
			//
			//      We should also fix this behavior in GroupWidget!
			if (m_fillRest)
			{
				if (m_parent !is null)
				{
					auto offset = origin - (m_parent.m_origin - m_parent.m_padding);
					if (offset.x > 0)
						w -= int(offset.x);
					if (offset.y > 0)
						h -= int(offset.y);
				}
			}
			else
			{
				if (m_offset.x > 0)
					w -= int(m_offset.x * 2);
				if (m_offset.y > 0)
					h -= int(m_offset.y * 2);
			}

			m_width = w;
			m_height = h;

			//CalculateOrigin(origin, parentSz);
		}

		RectWidget::DoLayout(origin, parentSz);

		if (m_innerSz && (m_dynamicWidth || m_dynamicHeight))
		{
			float mw = m_width, mh = m_height;
			float w = 0, h = 0;

			for (uint i = 0; i < m_children.length(); i++)
			{
				auto c = m_children[i];
				if (!c.m_visible)
					continue;

				vec2 o = c.m_origin - m_origin;
				float x2 = o.x + c.m_width;
				float y2 = o.y + c.m_height;

				if (o.x < mw) mw = o.x;
				if (o.y < mh) mh = o.y;

				if (x2 > w) w = x2;
				if (y2 > h) h = y2;
			}

			if (m_children.length() == 0)
				mw = mh = 0;

			if (m_dynamicWidth)
			{
				w += -mw;
				m_width = int(w + m_padding.x * 2);
			}

			if (m_dynamicHeight)
			{
				h += -mh;
				m_height = int(h + m_padding.y * 2);
			}

			RectWidget::DoLayout(origin, parentSz);
		}
	}
}

ref@ LoadGroupRectWidget(WidgetLoadingContext &ctx)
{
	GroupRectWidget@ w = GroupRectWidget();
	w.Load(ctx);
	return w;
}
