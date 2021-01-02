class ButtonWidget : RectWidget
{
	string m_func;
	string m_funcHover;

	BitmapFont@ m_font;
	vec4 m_textColor;
	vec4 m_textColorHover;
	vec4 m_textColorDisabled;
	bool m_textWrapping;
	string m_text;
	TextAlignment m_alignment = TextAlignment::Center;
	string m_textCurrent;
	bool m_enabled;

	vec2 m_textOffset;

	BitmapString@ m_renderText;

	Sprite@ m_sprite;

	SoundEvent@ m_pressSound;
	SoundEvent@ m_hoverSound;

	ButtonWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		ButtonWidget@ w = ButtonWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		auto def = ctx.GetGUIDef();

		m_func = ctx.GetString("func", false);
		m_funcHover = ctx.GetString("func-hover", false);

		string fnmFont = ctx.GetString("font", false);
		if (fnmFont != "")
			@m_font = Resources::GetBitmapFont(fnmFont);
		m_textOffset = ctx.GetVector2("textoffset", false, m_textOffset);
		m_textColor = ctx.GetColorRGBA("textcolor", false, vec4(0, 0.82, 1, 1));
		m_textColorHover = ctx.GetColorRGBA("textcolor-hover", false, vec4(1, 1, 1, 1));
		m_textColorDisabled = ctx.GetColorRGBA("textcolor-disabled", false, vec4(0, 0.41, 0.5, 0.8));
		m_textWrapping = ctx.GetBoolean("textwrapping", false, true);
		m_text = Resources::GetString(ctx.GetString("text", false));
		TextAlignment align = TextAlignment::Center;
		string alignStr = ctx.GetString("align", false);
		if (alignStr == "left")
			align = TextAlignment::Left;
		else if (alignStr == "right")
			align = TextAlignment::Right;
		m_enabled = ctx.GetBoolean("enabled", false, true);

		auto sprite = ctx.GetString("sprite", false);
		if (sprite != "")
			@m_sprite = def.GetSprite(sprite);

		@m_pressSound = Resources::GetSoundEvent("event:/ui/button_click");
		@m_hoverSound = Resources::GetSoundEvent("event:/ui/button_hover");

		RectWidget::Load(ctx);

		m_borderColor = ctx.GetColorRGBA("border", false);
		m_borderWidth = ctx.GetInteger("borderwidth", false);

		SetText(m_text, m_enabled ? m_textColor : m_textColorDisabled, align);

		m_canFocus = true;
	}

	void SetText(string str)
	{
		SetText(str, m_textColor, m_alignment);
	}

	void SetText(string str, vec4 color)
	{
		SetText(str, color, m_alignment);
	}

	void SetText(string str, vec4 color, TextAlignment align)
	{
		m_textCurrent = str;
		m_alignment = align;
		if (m_font is null)
			return;

		int width = m_width;
		if (!m_textWrapping)
			width = -1;
		@m_renderText = m_font.BuildText(str, width, align);

		SetColor(color);
	}

	void SetEnabled(bool enabled)
	{
		m_enabled = enabled;
		if (m_enabled)
		{
			if (m_hovering)
				SetColor(m_textColorHover);
			else
				SetColor(m_textColor);
		}
		else
			SetColor(m_textColorDisabled);
	}

	void SetColor(vec4 color)
	{
		if (m_renderText !is null)
			m_renderText.SetColor(color);
	}

	bool OnClick(vec2 mousePos) override
	{
		if (!m_enabled)
			return false;

		m_host.OnFunc(this, m_func);
		PlaySound2D(m_pressSound);
		return true;
	}

	void OnMouseEnter(vec2 mousePos, bool forced) override
	{
		if (m_enabled)
		{
			PlaySound2D(m_hoverSound);
			SetColor(m_textColorHover);

			if (m_funcHover != "")
				m_host.OnFunc(this, m_funcHover);
		}

		RectWidget::OnMouseEnter(mousePos, forced);
	}

	void OnMouseLeave(vec2 mousePos) override
	{
		if (m_enabled)
			SetColor(m_textColor);
		else
			SetColor(m_textColorDisabled);

		RectWidget::OnMouseLeave(mousePos);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		RectWidget::DoDraw(sb, pos);

		if (m_renderText !is null)
		{
			int wText = int(m_renderText.GetWidth());
			int hText = int(m_renderText.GetHeight());
			if (m_alignment == TextAlignment::Left)
			{
				sb.DrawString(vec2(
					int(pos.x + m_textOffset.x),
					int(pos.y + m_textOffset.y + m_height / 2 - hText / 2)
				), m_renderText);
			}
			else if (m_alignment == TextAlignment::Center)
			{
				sb.DrawString(vec2(
					int(pos.x + m_textOffset.x + m_width / 2 - wText / 2),
					int(pos.y + m_textOffset.y + m_height / 2 - hText / 2)
				), m_renderText);
			}
			else if (m_alignment == TextAlignment::Right)
			{
				sb.DrawString(vec2(
					int(pos.x + m_textOffset.x + m_width - wText),
					int(pos.y + m_textOffset.y + m_height / 2 - hText / 2)
				), m_renderText);
			}
		}

		if (m_sprite !is null)
		{
			float wSprite = m_sprite.GetWidth();
			float hSprite = m_sprite.GetHeight();
			sb.DrawSprite(vec2(
				pos.x + m_width / 2 - wSprite / 2,
				pos.y + m_height / 2 - hSprite / 2
			), m_sprite, g_menuTime);
		}
	}

	void ShowTooltip() override
	{
		m_tooltipEnabled = m_enabled;
		RectWidget::ShowTooltip();
	}
}

ref@ LoadButtonWidget(WidgetLoadingContext &ctx)
{
	ButtonWidget@ w = ButtonWidget();
	w.Load(ctx);
	return w;
}
