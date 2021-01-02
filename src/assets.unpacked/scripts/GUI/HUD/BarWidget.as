enum BarAlign
{
	Left,
	Center,
	Right
}

class BarWidget : RectWidget
{
	float m_scale;

	int m_changedC;

	vec2 m_barPadding;
	vec4 m_colorValue;
	BarAlign m_align = BarAlign::Left;

	SpriteRect@ m_spriteRectValue;
	SpriteRect@ m_spriteRectValueHi;
	int m_spriteRectVariation;

	int m_barCount;
	Sprite@ m_spriteBarOn;
	Sprite@ m_spriteBarOff;

	BarWidget()
	{
		super();
	}

	void SetScale(float scale, int changeCount = 100)
	{
		if (m_scale == scale)
			return;
		m_scale = scale;

		if (m_scale > 1.0f)
			m_scale = 1.0f;
		else if (m_scale < 0.0f)
			m_scale = 0.0f;

		m_changedC = changeCount;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		auto def = ctx.GetGUIDef();

		RectWidget::Load(ctx);

		m_barPadding = ctx.GetVector2("value-padding", false, vec2(1, 1));
		m_colorValue = ctx.GetColorRGBA("value-color", false);

		string strAlign = ctx.GetString("value-align", false, "left");
		     if (strAlign == "left") m_align = BarAlign::Left;
		else if (strAlign == "center") m_align = BarAlign::Center;
		else if (strAlign == "right") m_align = BarAlign::Right;

		string spritesetValue = ctx.GetString("spriteset-value", false);
		if (spritesetValue != "") @m_spriteRectValue = SpriteRect(spritesetValue);

		string spritesetValueHi = ctx.GetString("spriteset-value-hi", false);
		if (spritesetValueHi != "") @m_spriteRectValueHi = SpriteRect(spritesetValueHi);

		m_spriteRectVariation = ctx.GetInteger("spriteset-variation", false);

		m_barCount = ctx.GetInteger("bar-count", false);
		@m_spriteBarOn = def.GetSprite(ctx.GetString("bar-on", false));
		@m_spriteBarOff = def.GetSprite(ctx.GetString("bar-off", false));

		m_scale = ctx.GetFloat("scale", false);
	}

	Widget@ Clone() override
	{
		BarWidget@ w = BarWidget();
		CloneInto(w);
		return w;
	}

	void Update(int dt) override
	{
		RectWidget::Update(dt);

		if (m_changedC > 0)
			m_changedC -= dt;
	}

	Sprite@ GetBarSprite(float factor)
	{
		if (factor > m_scale)
			return m_spriteBarOff;
		return m_spriteBarOn;
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		RectWidget::DoDraw(sb, pos);

		vec4 p;
		p.y = pos.y + m_barPadding.y;
		p.z = (m_width - m_barPadding.x * 2) * m_scale;
		p.w = m_height - m_barPadding.y * 2;

		if (m_spriteRectValue !is null)
			p.z = max(p.z, float(m_spriteRectValue.GetLeft() + m_spriteRectValue.GetRight()));

		if (m_align == BarAlign::Left)
			p.x = pos.x + m_barPadding.x;
		else if (m_align == BarAlign::Center)
			p.x = pos.x + (m_width / 2 - p.z / 2);
		else if (m_align == BarAlign::Right)
			p.x = pos.x + m_width - m_barPadding.x - p.z;

		if (m_barCount > 0 && m_spriteBarOn !is null && m_spriteBarOff !is null)
		{
			int barWidth = m_spriteBarOn.GetWidth() - 1;
			for (int i = 0; i < m_barCount; i++)
			{
				float factor = i / float(m_barCount);

				Sprite@ sBar = GetBarSprite(factor);
				sb.DrawSprite(vec2(p.x, p.y) + vec2(i * barWidth, 0), sBar, g_menuTime);
			}
		}
		else if (m_scale > 0.0f)
		{
			SpriteRect@ spriteRect = m_spriteRectValue;
			if (m_changedC > 0 && m_spriteRectValueHi !is null)
				@spriteRect = m_spriteRectValueHi;

			if (spriteRect is null)
			{
				sb.DrawSprite(null, p, p, m_colorValue);
				return;
			}

			p.x = ceil(p.x);

			spriteRect.Draw(sb, vec2(p.x, p.y), int(p.z), int(p.w), m_spriteRectVariation);
		}
	}
}

ref@ LoadBarWidget(WidgetLoadingContext &ctx)
{
	BarWidget@ w = BarWidget();
	w.Load(ctx);
	return w;
}
