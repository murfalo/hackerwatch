class ScrollableWidget : ClipWidget
{
	//TODO: Autoscroll currently only works automatically if the container
	//      has flow="vbox". Otherwise, you have to set autoscroll-height to
	//      a height yourself. If you don't provide a height manually, it
	//      will attempt to calculate it automatically for you, which only
	//      works well on vbox flow right now.
	bool m_autoScroll = true;
	int m_autoScrollHeight = -1;
	private int _m_autoScrollValue = 0;
	int m_autoScrollValue
	{
		get { return _m_autoScrollValue; }
		set {
			if (value != _m_autoScrollValue)
				Invalidate();
			_m_autoScrollValue = value;
		}
	}
	int m_autoScrollArrowDelta = 40;
	bool m_autoScrollLimits = true;

	bool m_scrollingPaused;

	Sprite@ m_scrollBackdropSprite;

	void Load(WidgetLoadingContext& ctx) override
	{
		ClipWidget::Load(ctx);

		m_autoScroll = ctx.GetBoolean("autoscroll", false, m_autoScroll);
		m_autoScrollHeight = ctx.GetInteger("autoscroll-height", false, m_autoScrollHeight);
		m_autoScrollValue = ctx.GetInteger("autoscroll-value", false, m_autoScrollValue);
		m_autoScrollArrowDelta = ctx.GetInteger("autoscroll-arrow-delta", false, m_autoScrollArrowDelta);
		m_autoScrollLimits = ctx.GetBoolean("autoscroll-limits", false, m_autoScrollLimits);

		auto def = ctx.GetGUIDef();
		@m_scrollBackdropSprite = def.GetSprite(ctx.GetString("scroll-backdrop-sprite", false));
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		m_childOffset = vec2(0, -_m_autoScrollValue);

		ClipWidget::DoLayout(origin, parentSz);

		if (!m_autoScroll)
			return;

		for (uint i = 0; i < m_children.length(); i++)
		{
			Widget@ child = m_children[i];

			if (!child.m_visible)
				continue;

			int bottom = int((child.m_origin.y - m_origin.y) + child.m_height) + _m_autoScrollValue;
			//if (bottom > m_autoScrollHeight)
				m_autoScrollHeight = bottom;
		}

		TestAutoscrollLimit();
	}

	bool ShouldDrawChild(Widget@ child) override
	{
		if (!m_autoScroll)
			return true;

		if (child.m_origin.y + child.m_height > m_origin.y && child.m_origin.y < m_origin.y + m_height)
			return true;

		return false;
	}

	void DebugDraw(SpriteBatch& sb) override
	{
		ClipWidget::DebugDraw(sb);

		sb.PauseClipping();

		if (m_autoScroll)
		{
			vec2 asOrigin = m_origin + vec2(2, 2 - _m_autoScrollValue);
			sb.DrawLine(asOrigin, asOrigin + vec2(0, m_autoScrollHeight), 2, vec4(0.4, 0.4, 1, 1));
		}

		sb.ResumeClipping();
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_scrollBackdropSprite is null)
			return;

		int spriteWidth = m_scrollBackdropSprite.GetWidth();
		int spriteHeight = m_scrollBackdropSprite.GetHeight();
		for (int y = 0; y < m_height + spriteHeight; y += spriteHeight)
		{
			for (int x = 0; x < m_width; x += spriteWidth)
			{
				vec2 offset = vec2(x, y);
				offset.y -= _m_autoScrollValue % spriteHeight;
				sb.DrawSprite(pos + offset, m_scrollBackdropSprite, g_menuTime);
			}
		}
	}

	bool UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override
	{
		if (m_autoScroll && int(mousePos.z) != 0 && m_hovering && SpaceToScroll())
		{
			int scrollStep = 20 * int(abs(mousePos.z));
			if (mousePos.z < 0)
				m_autoScrollValue += scrollStep;
			else if (mousePos.z > 0)
				m_autoScrollValue -= scrollStep;

			// if this one can still scroll further, don't allow children to respond to mouse wheel events
			if (!TestAutoscrollLimit())
				mousePos.z = 0;
		}

		return ClipWidget::UpdateInput(origin, parentSz, mousePos);
	}

	bool FocusTowards(WidgetDirection dir) override
	{
		// special case: if we're trying to go up/down, and we are autoscrolling without any focusable widgets inside, it's probably scrollable visual content, so just scroll
		if ((dir == WidgetDirection::Up || dir == WidgetDirection::Down) && m_autoScroll)
		{
			bool hasFocusable = false;
			for (uint i = 0; i < m_children.length(); i++)
			{
				auto w = m_children[i];
				if (w.ContainsFocusable())
				{
					hasFocusable = true;
					break;
				}
			}

			if (!hasFocusable)
			{
				if (SpaceToScroll())
				{
					if (dir == WidgetDirection::Up)
						m_autoScrollValue -= m_autoScrollArrowDelta;
					else if (dir == WidgetDirection::Down)
						m_autoScrollValue += m_autoScrollArrowDelta;
				}

				if (!TestAutoscrollLimit())
					return true;
			}
		}

		return ClipWidget::FocusTowards(dir);
	}

	void PauseScrolling()
	{
		m_scrollingPaused = true;
	}

	void ResumeScrolling()
	{
		m_scrollingPaused = false;
		TestAutoscrollLimit();
	}

	void AddChild(ref widget, int insertAt = -1) override
	{
		ClipWidget::AddChild(widget, insertAt);

		Widget@ w = cast<Widget>(widget);

		if (!m_scrollingPaused && m_autoScroll && m_flow == WidgetFlow::Vbox && w.m_visible)
			m_autoScrollHeight += w.m_height;
	}

	void ClearChildren() override
	{
		ClipWidget::ClearChildren();

		if (!m_scrollingPaused && m_autoScroll)
		{
			m_autoScrollValue = 0;
			m_autoScrollHeight = 0;
		}
	}

	void ScrollUp()
	{
		m_autoScrollValue = 0;
		TestAutoscrollLimit();
	}

	void ScrollDown()
	{
		int scrollWidgetHeight = int(m_height - m_padding.y);
		m_autoScrollValue = m_autoScrollHeight - scrollWidgetHeight;
		TestAutoscrollLimit();
	}

	bool TestAutoscrollLimit()
	{
		if (!m_autoScrollLimits)
			return false;
		int scrollWidgetHeight = int(m_height - m_padding.y);
		if (m_autoScrollValue <= 0)
		{
			m_autoScrollValue = 0;
			return true;
		}
		else if (m_autoScrollHeight >= 0 && m_autoScrollValue >= m_autoScrollHeight - scrollWidgetHeight)
		{
			m_autoScrollValue = m_autoScrollHeight - scrollWidgetHeight;
			return true;
		}
		return false;
	}

	bool SpaceToScroll()
	{
		// The widget height, minus the padding (so that we can scroll far enough to have our Y padding left)
		int scrollWidgetHeight = int(m_height - m_padding.y);
		return m_autoScrollHeight > scrollWidgetHeight;
	}
}
