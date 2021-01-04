class FlagWidget : Widget
{
	string m_flag;
	bool m_invert;
	bool m_resetSprite;

	bool m_flagSet;

	bool m_slide;
	int m_slideTime;
	vec2 m_slideVisible;
	vec2 m_slideHidden;
	bool m_slideHiding;
	
	FlagWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		m_flag = ctx.GetString("flag", true);
		m_invert = ctx.GetBoolean("invert", false);

		m_width = ctx.GetInteger("width", false, 0);
		m_height = ctx.GetInteger("height", false, 0);

		m_resetSprite = ctx.GetBoolean("resetsprite", false);

		m_slide = ctx.GetBoolean("slide", false, false);
		m_slideTime = ctx.GetInteger("slide-time", false, 0);
		m_slideVisible = ctx.GetVector2("slide-visible", false, vec2());
		m_slideHidden = ctx.GetVector2("slide-hidden", false, vec2());

		Widget::Load(ctx);

		m_visible = false; // Default
	}

	void Update(int dt) override
	{
		bool makeVisible = g_flags.IsSet(m_flag);
		bool isVisible = m_visible;

		if (m_slide)
		{
			if (makeVisible && !isVisible)
			{
				m_visible = true;
				Animate(WidgetVec2Animation("offset", m_slideHidden, m_slideVisible, m_slideTime));
			}
			else if (!makeVisible && isVisible && !m_slideHiding)
			{
				m_slideHiding = true;
				Animate(WidgetVec2Animation("offset", m_slideVisible, m_slideHidden, m_slideTime));
				Animate(WidgetBoolAnimation("visible", false, m_slideTime));
				Animate(WidgetBoolAnimation("hiding", false, m_slideTime));
			}
		}
		else
		{
			if (makeVisible && !isVisible && m_resetSprite && m_children.length() > 0)
			{
				auto wSprite = cast<SpriteWidget>(m_children[0]);
				if (wSprite !is null)
					wSprite.m_timeOffset = g_menuTime;
			}

			if (m_invert)
				m_visible = !makeVisible;
			else
				m_visible = makeVisible;
		}

		Widget::Update(dt);
	}

	void AnimateSet(string key, bool b) override
	{
		if (key == "hiding")
			m_slideHiding = b;
		else
			Widget::AnimateSet(key, b);
	}
}

ref@ LoadFlagWidget(WidgetLoadingContext &ctx)
{
	FlagWidget@ w = FlagWidget();
	w.Load(ctx);
	return w;
}
