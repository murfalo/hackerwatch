class SpeechBubble
{
	UnitPtr m_unit;

	WorldScript::ShowSpeechBubble@ m_shower;

	SpriteRect@ m_spriteRect;

	BitmapFont@ m_fontTitle;
	BitmapFont@ m_fontText;

	BitmapString@ m_title;
	BitmapString@ m_text;

	vec4 m_titleColor;
	vec4 m_textColor;
	vec4 m_lineColor;

	ScriptSprite@ m_spriteArrow;

	SoundEvent@ m_sound;

	vec2 m_offset;

	SpeechBubble()
	{
	}

	void SetUnit(UnitPtr unit)
	{
		m_unit = unit;
	}

	void UpdateAlpha()
	{
		m_spriteRect.m_background.w = GetVarFloat("ui_speechbubble_alpha");
	}

	void SetStyle(string style)
	{
		auto sval = Resources::GetSValue(style);

		@m_spriteRect = SpriteRect(GetParamString(UnitPtr(), sval, "spriteset"));
		UpdateAlpha();

		auto arrowArray = GetParamArray(UnitPtr(), sval, "tail", false);
		if (arrowArray !is null)
			@m_spriteArrow = ScriptSprite(arrowArray);

		m_titleColor = ParseColorRGBA(GetParamString(UnitPtr(), sval, "color-title", false, "#000000FF"));
		m_textColor = ParseColorRGBA(GetParamString(UnitPtr(), sval, "color-text", false, "#000000FF"));
		m_lineColor = ParseColorRGBA(GetParamString(UnitPtr(), sval, "color-line", false, "#000000FF"));

		@m_fontTitle = Resources::GetBitmapFont(GetParamString(UnitPtr(), sval, "font-title", false, "gui/fonts/arial11_bold_nooutline.fnt"));
		@m_fontText = Resources::GetBitmapFont(GetParamString(UnitPtr(), sval, "font", false, "gui/fonts/arial11_nooutline.fnt"));

		string snd = GetParamString(UnitPtr(), sval, "sound", false);
		if (snd != "")
			@m_sound = Resources::GetSoundEvent(snd);

		if (m_title !is null)
			m_title.SetColor(m_titleColor);
		if (m_text !is null)
			m_text.SetColor(m_textColor);
	}

	void SetText(string title, string text)
	{
		if (title != "")
		{
			@m_title = m_fontTitle.BuildText(title, 200, TextAlignment::Center);
			m_title.SetColor(m_titleColor);
		}
		else
			@m_title = null;

		if (text != "")
		{
			@m_text = m_fontText.BuildText(text, 200, TextAlignment::Center);
			m_text.SetColor(m_textColor);
		}
		else
			@m_text = null;
	}

	void OnShown()
	{
		if (m_sound !is null)
			PlaySound3D(m_sound, m_unit);
	}

	void Update(int dt)
	{
		UpdateAlpha();

		if (m_unit.IsValid() && m_unit.IsDestroyed() && m_shower !is null)
			m_shower.HideBubble();
	}

	void Draw(SpriteBatch& sb, int idt)
	{
		vec4 padding = vec4(3, 0, 4, 3);

		vec2 pos = ToScreenspace(m_unit.GetInterpolatedPosition(idt)) / g_gameMode.m_wndScale;

		vec2 size = vec2();

		if (m_title !is null)
		{
			size.x = max(size.x, float(m_title.GetWidth()));
			size.y += m_title.GetHeight();
		}

		if (m_text !is null)
		{
			size.x = max(size.x, float(m_text.GetWidth()));
			size.y += m_text.GetHeight();
		}

		size.x += padding.x + padding.z;
		size.y += padding.y + padding.w;

		pos.x -= size.x / 2;
		pos.y -= size.y;
		pos.y -= 18;

		pos += m_offset;

		pos.x = round(pos.x);
		pos.y = round(pos.y);

		m_spriteRect.Draw(sb, pos, int(size.x), int(size.y));

		if (m_spriteArrow !is null)
			m_spriteArrow.Draw(sb, pos + vec2(round(size.x / 2 - m_spriteArrow.GetWidth() / 2), size.y - 1), g_menuTime);

		float curY = 0;

		if (m_title !is null)
		{
			sb.DrawString(pos + vec2(size.x / 2 - m_title.GetWidth() / 2 - 1, padding.y), m_title);
			curY += m_title.GetHeight();
		}

		if (m_text !is null)
		{
			sb.DrawString(pos + vec2(size.x / 2 - m_text.GetWidth() / 2 - 1, padding.y + curY), m_text);
			curY += m_text.GetHeight();
		}

		if (m_title !is null && m_text !is null)
			sb.FillRectangle(vec4(pos.x + 3, pos.y + m_title.GetHeight(), size.x - 6, 1), m_lineColor);
	}
}
