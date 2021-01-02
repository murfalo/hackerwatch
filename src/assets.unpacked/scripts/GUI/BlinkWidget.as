enum BlinkType
{
	Disappear,
	Colorize
}

class BlinkWidget : Widget
{
	BlinkType m_type;

	int m_tm;
	int m_tmDisappear;
	int m_tmCycle;

	vec4 m_colorOn;
	vec4 m_colorOff;

	BlinkWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx, false);

		string type = ctx.GetString("type", false, "disappear");
		     if (type == "disappear") m_type = BlinkType::Disappear;
		else if (type == "colorize") m_type = BlinkType::Colorize;

		m_tmDisappear = ctx.GetInteger("disappear", false, 500);
		m_tmCycle = ctx.GetInteger("cycle", false, 1000);

		m_colorOn = ctx.GetColorRGBA("color-on", false, vec4(1, 1, 1, 1));
		m_colorOff = ctx.GetColorRGBA("color-off", false, vec4(1, 0, 0, 1));

		Widget::Load(ctx);
	}

	void Colorize(Widget@ w, const vec4 &in col)
	{
		auto wText = cast<TextWidget>(w);
		if (wText !is null)
			wText.SetColor(col);

		auto wButton = cast<ButtonWidget>(w);
		if (wButton !is null && !wButton.m_hovering)
			wButton.SetColor(col);

		for (uint i = 0; i < w.m_children.length(); i++)
			Colorize(w.m_children[i], col);
	}

	void Update(int dt) override
	{
		m_tm += dt;

		if (m_type == BlinkType::Colorize)
		{
			if (m_tm >= m_tmDisappear && m_tm - dt < m_tmDisappear)
				Colorize(this, m_colorOff);
			else if (m_tm >= m_tmCycle && m_tm - dt < m_tmCycle)
				Colorize(this, m_colorOn);
		}

		if (m_tm >= m_tmCycle)
			m_tm -= m_tmCycle;

		Widget::Update(dt);
	}

	bool ShouldDrawChild(Widget@ child) override
	{
		if (m_type != BlinkType::Disappear)
			return true;

		if (m_tm > m_tmDisappear)
			return false;

		return true;
	}
}

ref@ LoadBlinkWidget(WidgetLoadingContext &ctx)
{
	BlinkWidget@ w = BlinkWidget();
	w.Load(ctx);
	return w;
}
