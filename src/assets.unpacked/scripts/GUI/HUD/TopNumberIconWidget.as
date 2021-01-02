class TopNumberIconWidget : Widget
{
	GUIDef@ m_def;

	vec4 m_color;
	vec4 m_colorText;

	Sprite@ m_sprite;
	int m_number;

	BitmapFont@ m_font;
	BitmapString@ m_text;

	string m_topID;

	bool m_shouldSave = true;

	TopNumberIconWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		TopNumberIconWidget@ w = TopNumberIconWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		@m_def = ctx.GetGUIDef();

		m_color = ctx.GetColorRGBA("color", false, vec4(0, 0, 0, 1));
		m_colorText = ctx.GetColorRGBA("color-text", false, vec4(1, 1, 1, 1));

		@m_font = Resources::GetBitmapFont(ctx.GetString("font", false, "gui/fonts/font_hw8.fnt"));
		SetNumber(0, true);

		m_width = 17;
		m_height = 12;
	}

	void SetSprite(string sprite)
	{
		SetSprite(m_def.GetSprite(sprite));
	}

	void SetSprite(Sprite@ sprite)
	{
		@m_sprite = sprite;
	}

	void SetNumber(int number, bool force = false)
	{
		if (m_font is null || (m_number == number && !force))
			return;

		m_number = number;

		if (m_number != -1)
		{
			@m_text = m_font.BuildText("" + number);
			m_text.SetColor(m_colorText);

			m_width = 17; // Maybe we can use m_text.GetWidth() here?
		}
		else
		{
			@m_text = null;
			m_width = 12;
		}
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		Widget::DoDraw(sb, pos);

		vec4 p = vec4(pos.x, pos.y, m_width, m_height);
		sb.DrawSprite(null, p, p, m_color);

		if (m_sprite !is null)
			sb.DrawSprite(pos + vec2(1, 1), m_sprite, g_menuTime);

		if (m_text !is null)
		{
			vec2 posText = pos;
			posText.x = int(posText.x) + 11 + (3 - m_text.GetWidth() / 2);
			posText.y = int(posText.y) + 2;
			sb.DrawString(posText, m_text);
		}
	}

	void Save(SValueBuilder &builder)
	{
		if (!m_shouldSave)
			return;

		builder.PushDictionary();
		builder.PushString("id", m_topID);
		builder.PushInteger("num", m_number);
		builder.PopDictionary();
	}
}

ref@ LoadTopNumberIconWidget(WidgetLoadingContext &ctx)
{
	TopNumberIconWidget@ w = TopNumberIconWidget();
	w.Load(ctx);
	return w;
}
