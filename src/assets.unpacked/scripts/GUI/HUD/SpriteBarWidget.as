class SpriteBarWidget : Widget
{
	Sprite@ m_sprite;
	Sprite@ m_spriteHi;
	Sprite@ m_spriteExtra;

	vec4 m_color;
	float m_value;
	float m_valueExtra;

	float m_valuePrev;
	int m_timePrev;

	SpriteBarWidget()
	{
		super();
		@m_sprite = null;

		m_width = 0;
		m_height = 0;
	}

	void SetValue(float v)
	{
		v = clamp(v, 0.0f, 1.0f);

		if (v > m_value && (v - m_value) > 0.1f && m_spriteHi !is null)
		{
			if (m_timePrev <= 0)
				m_valuePrev = m_value;
			m_timePrev = 1000;
		}

		m_value = v;
	}

	Widget@ Clone() override
	{
		auto w = SpriteBarWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		string spriteName = ctx.GetString("src", false);
		if (spriteName != "")
		{
			@m_sprite = ctx.GetGUIDef().GetSprite(spriteName);
			m_width = m_sprite.GetWidth();
			m_height = m_sprite.GetHeight();
		}

		string spriteHiName = ctx.GetString("src-hi", false);
		if (spriteHiName != "")
			@m_spriteHi = ctx.GetGUIDef().GetSprite(spriteHiName);

		string spriteExtraName = ctx.GetString("src-extra", false);
		if (spriteExtraName != "")
			@m_spriteExtra = ctx.GetGUIDef().GetSprite(spriteExtraName);

		m_color = ctx.GetColorRGBA("color", false, vec4(1, 1, 1, 1));
		Widget::Load(ctx);
	}

	void Update(int dt) override
	{
		if (m_timePrev > 0)
			m_timePrev -= dt;

		Widget::Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_valueExtra > 0 && m_spriteExtra !is null)
		{
			auto tex = m_spriteExtra.GetTexture2D();
			auto frame = m_spriteExtra.GetFrame(g_menuTime);

			int vOffset = m_height - int(round(m_height * m_value));

			vec4 p(pos.x, pos.y + vOffset, m_width, m_height - vOffset);
			frame.y += vOffset;
			frame.w -= vOffset;

			sb.DrawSprite(tex, p, frame, m_color);
		}

		if (m_timePrev > 0 && m_spriteHi !is null)
		{
			auto tex = m_spriteHi.GetTexture2D();
			auto frame = m_spriteHi.GetFrame(g_menuTime);

			int vOffset = m_height - int(round(m_height * m_value));

			vec4 p(pos.x, pos.y + vOffset, m_width, m_height - vOffset);
			frame.y += vOffset;
			frame.w -= vOffset;

			sb.DrawSprite(tex, p, frame, m_color);
		}

		if (m_sprite !is null)
		{
			auto tex = m_sprite.GetTexture2D();
			auto frame = m_sprite.GetFrame(g_menuTime);

			float showValue = m_value;
			if (m_timePrev > 0)
				showValue = m_valuePrev;

			if (m_valueExtra > 0 && showValue > m_valueExtra)
				showValue = m_valueExtra;

			int vOffset = m_height - int(round(m_height * showValue));

			vec4 p(pos.x, pos.y + vOffset, m_width, m_height - vOffset);
			frame.y += vOffset;
			frame.w -= vOffset;

			sb.DrawSprite(tex, p, frame, m_color);
		}
	}
}

ref@ LoadSpriteBarWidget(WidgetLoadingContext &ctx)
{
	auto w = SpriteBarWidget();
	w.Load(ctx);
	return w;
}
