class KnobSliderWidget : Widget
{
	vec2 m_prevPos;
	vec2 m_diff;

	float m_threshold;

	string m_funcIncrease;
	string m_funcDecrease;

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx);

		m_threshold = ctx.GetFloat("threshold", false, 1.0f);

		m_funcIncrease = ctx.GetString("func-increase", false);
		m_funcDecrease = ctx.GetString("func-decrease", false);

		Widget::Load(ctx);

		@m_cursor = Platform::CursorVScale;

		m_canFocus = true;
		m_canFocusInput = true;
	}

	bool UpdateInput(GameInput& input, MenuInput& menuInput) override
	{
		if (!menuInput.Forward.Down)
		{
			@g_gameMode.m_widgetInputFocus = null;
			return false;
		}

		vec2 newPos = (input.MousePos / g_gameMode.m_wndScale) - m_origin;
		vec2 offset = m_prevPos - newPos;
		m_prevPos = newPos;

		m_diff += offset;

		while (m_diff.y <= -m_threshold)
		{
			m_diff.y += m_threshold;
			if (m_funcDecrease != "")
				m_host.OnFunc(this, m_funcDecrease);
		}

		while (m_diff.y >= m_threshold)
		{
			m_diff.y -= m_threshold;
			if (m_funcIncrease != "")
				m_host.OnFunc(this, m_funcIncrease);
		}

		return true;
	}

	bool OnMouseDown(vec2 mousePos) override
	{
		@g_gameMode.m_widgetInputFocus = this;
		m_prevPos = mousePos;
		return true;
	}
}

ref LoadKnobSliderWidget(WidgetLoadingContext &ctx)
{
	KnobSliderWidget@ w = KnobSliderWidget();
	w.Load(ctx);
	return w;
}
