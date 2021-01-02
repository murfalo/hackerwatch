class TextWidget : Widget
{
	BitmapFont@ m_font;
	string m_fontName;
	bool m_direct;

	BitmapString@ m_text;

	string m_str = "";
	bool m_upper = false;
	int m_textWidth = -1;
	TextAlignment m_alignment = TextAlignment::Left;
	vec4 m_color = vec4(1, 1, 1, 1);
	vec4 m_colorOriginal;
	
	TextWidget()
	{
		super();
		
		m_width = 0;
		m_height = 0;
	}

	Widget@ Clone() override
	{
		TextWidget@ w = TextWidget();
		CloneInto(w);
		return w;
	}
	
	void Load(WidgetLoadingContext &ctx) override
	{
		TextAlignment align = TextAlignment::Left;
		string alignStr = ctx.GetString("align", false);
		if (alignStr == "right")
			align = TextAlignment::Right;
		else if (alignStr == "center")
			align = TextAlignment::Center;

		m_width = ctx.GetInteger("width", false, 0);

		m_upper = ctx.GetBoolean("upper", false, false);

		m_direct = ctx.GetBoolean("direct", false, false);

		if (m_font is null)
		{
			m_fontName = ctx.GetString("font", false);
			@m_font = Resources::GetBitmapFont(m_fontName);
			if (m_font is null)
				PrintError("Couldn't load font: '" + m_fontName + "'");
		}
		
		m_colorOriginal = ctx.GetColorRGBA("color", false, m_color);
		
		string text = Resources::GetString(ctx.GetString("text", false));
		LoadWidthHeight(ctx, false);
		SetText(text, m_width, align, m_colorOriginal);

		Widget::Load(ctx);
	}

	void SetFont(string fnm)
	{
		@m_font = Resources::GetBitmapFont(fnm);
		if (m_font is null)
		{
			PrintError("Font not found: \"" + fnm + "\"");
			@m_text = null;
		}
		else
			SetText(m_str, m_textWidth, m_alignment, m_color, true);
	}

	void MeasureSize()
	{
		if (m_direct)
		{
			auto size = m_font.MeasureText(m_str, m_textWidth);
			if (m_textWidth > 0)
				m_width = min(int(size.x), m_textWidth);
			else
				m_width = int(size.x);
			m_height = int(size.y);
		}
		else if (m_text !is null)
		{
			if (m_textWidth > 0)
				m_width = min(m_text.GetWidth(), m_textWidth);
			else
				m_width = m_text.GetWidth();
			m_height = m_text.GetHeight();
		}
	}

	void SetText(string str, int width, TextAlignment align = TextAlignment::Left, vec4 color = vec4(1, 1, 1, 1), bool force = false)
	{
		if (!force && m_str == str && m_textWidth == width && m_alignment == align)// && m_color == color)
			return;

		if (m_upper)
			str = utf8string(str).toUpper().plain();

		m_str = str;
		m_textWidth = width;
		m_alignment = align;
		m_color = color;
		m_filter = str.toLower();

		if (!m_direct)
		{
			@m_text = m_font.BuildText(str, width, align);
			m_text.SetColor(color);
		}

		MeasureSize();
	}

	void SetText(string str, bool setColor = true, bool force = false)
	{
		if (!force && m_str == str)
			return;

		if (m_upper)
			str = utf8string(str).toUpper().plain();

		m_str = str;
		m_filter = str.toLower();

		if (m_widthScalar >= 0 && m_parent !is null)
			m_textWidth = int(m_widthScalar * m_parent.m_width);

		@m_text = m_font.BuildText(str, m_textWidth, m_alignment);
		if (setColor)
			m_text.SetColor(m_color);

		MeasureSize();
	}

	void SetColor(vec4 color)
	{
		m_color = color;

		if (!m_direct)
			m_text.SetColor(color);
	}
	
	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		pos.x = int(pos.x);
		pos.y = int(pos.y);

		if (m_direct)
			sb.DrawString(pos, m_font, m_str, m_color, m_alignment);
		else if (m_text !is null)
			sb.DrawString(pos, m_text);
	}

	void AnimateSet(string key, vec4 v) override
	{
		if (key == "color")
			SetColor(v);
		Widget::AnimateSet(key, v);
	}
}

ref@ LoadTextWidget(WidgetLoadingContext &ctx)
{
	TextWidget@ w = TextWidget();
	w.Load(ctx);
	return w;
}

ref@ LoadSysTextWidget(WidgetLoadingContext &ctx)
{
	TextWidget@ w = TextWidget();
	@w.m_font = Resources::GetBitmapFont("system/system_small.fnt");
	w.Load(ctx);
	return w;
}

void ModTextWidget(Widget@ w, string text)
{
	auto tw = cast<TextWidget>(w);
	if (tw !is null)
		tw.SetText(text);
}
