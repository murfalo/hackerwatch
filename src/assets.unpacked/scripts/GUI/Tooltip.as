class TooltipSubText
{
	Sprite@ m_sprite;
	BitmapString@ m_text;

	int GetWidth()
	{
		int ret = 0;
		if (m_sprite !is null)
			ret += m_sprite.GetWidth() + 4;
		ret += m_text.GetWidth();
		return ret;
	}
}

class Tooltip
{
	ScriptSprite@ m_spriteTopLeft;
	ScriptSprite@ m_spriteTop;
	ScriptSprite@ m_spriteTopRight;

	ScriptSprite@ m_spriteLeft;
	ScriptSprite@ m_spriteMiddle;
	ScriptSprite@ m_spriteRight;

	ScriptSprite@ m_spriteBottomLeft;
	ScriptSprite@ m_spriteBottom;
	ScriptSprite@ m_spriteBottomRight;

	BitmapFont@ m_fontTitle;
	BitmapString@ m_textTitle;
	int m_titleSpacing;

	BitmapFont@ m_fontSub;
	vec2 m_subSpacing;

	array<TooltipSubText@> m_subTexts;

	BitmapFont@ m_font;
	BitmapString@ m_text;

	int m_maxWidth;
	vec2 m_textOffset;
	vec2 m_sizeOffset;

	TextAlignment m_textAlignment = TextAlignment::Left;

	bool m_enabled = true;

	Tooltip(SValue@ params)
	{
		@m_spriteTopLeft = ScriptSprite(GetParamArray(UnitPtr(), params, "top-left"));
		@m_spriteTop = ScriptSprite(GetParamArray(UnitPtr(), params, "top"));
		@m_spriteTopRight = ScriptSprite(GetParamArray(UnitPtr(), params, "top-right"));

		@m_spriteLeft = ScriptSprite(GetParamArray(UnitPtr(), params, "left"));
		@m_spriteMiddle = ScriptSprite(GetParamArray(UnitPtr(), params, "middle"));
		@m_spriteRight = ScriptSprite(GetParamArray(UnitPtr(), params, "right"));

		@m_spriteBottomLeft = ScriptSprite(GetParamArray(UnitPtr(), params, "bottom-left"));
		@m_spriteBottom = ScriptSprite(GetParamArray(UnitPtr(), params, "bottom"));
		@m_spriteBottomRight = ScriptSprite(GetParamArray(UnitPtr(), params, "bottom-right"));

		@m_fontTitle = Resources::GetBitmapFont(GetParamString(UnitPtr(), params, "font-title", false, "gui/fonts/arial11_bold.fnt"));
		@m_fontSub = Resources::GetBitmapFont(GetParamString(UnitPtr(), params, "font-sub", false, "gui/fonts/arial11.fnt"));
		@m_font = Resources::GetBitmapFont(GetParamString(UnitPtr(), params, "font", false, "gui/fonts/arial11.fnt"));

		m_titleSpacing = GetParamInt(UnitPtr(), params, "title-spacing", false, -2);
		m_subSpacing = GetParamVec2(UnitPtr(), params, "sub-spacing", false, vec2(6, 0));

		m_maxWidth = GetParamInt(UnitPtr(), params, "max-width", false, 100);
		m_textOffset = GetParamVec2(UnitPtr(), params, "text-offset", false, vec2(5, 4));
		m_sizeOffset = GetParamVec2(UnitPtr(), params, "size-offset", false, vec2(9, 8));

		string align = GetParamString(UnitPtr(), params, "alignment", false);
		if (align == "right")
			m_textAlignment = TextAlignment::Right;
		else if (align == "center")
			m_textAlignment = TextAlignment::Center;
	}

	void Hide()
	{
		@m_text = null;
	}

	void Reset()
	{
		@m_textTitle = null;
		m_subTexts.removeRange(0, m_subTexts.length());
		@m_text = null;

		m_enabled = true;
	}

	void SetEnabled(bool enabled)
	{
		m_enabled = enabled;
/*
		if (m_textTitle !is null)
		{
			if (!m_enabled)
				m_textTitle.SetColor(vec4(0.5, 0.5, 0.5, 1));
		}

		if (m_text !is null)
		{
			if (m_enabled)
				m_text.SetColor(vec4(1, 1, 1, 1));
			else
				m_text.SetColor(vec4(0.5, 0.5, 0.5, 1));
		}
*/
	}

	void SetTitle(string title)
	{
		if (m_fontTitle is null)
			return;

		if (title == "")
			@m_textTitle = null;
		else
			@m_textTitle = m_fontTitle.BuildText(title, m_maxWidth, m_textAlignment);
	}

	void AddSub(Sprite@ sprite, string sub)
	{
		if (m_fontSub is null)
			return;

		auto subText = TooltipSubText();
		@subText.m_sprite = sprite;
		@subText.m_text = m_fontSub.BuildText(sub, m_maxWidth, m_textAlignment);
		AddSub(subText);
	}

	void AddSub(TooltipSubText@ subText)
	{
		m_subTexts.insertLast(subText);
	}

	void SetText(string text)
	{
		@m_text = m_font.BuildText(text, m_maxWidth, m_textAlignment);
	}

	void SetText(string text, TextAlignment align)
	{
		@m_text = m_font.BuildText(text, m_maxWidth, align);
	}

	int GetSubtextWidth()
	{
		int ret = 0;
		for (uint i = 0; i < m_subTexts.length(); i++)
		{
			ret += m_subTexts[i].GetWidth();
			if (i < m_subTexts.length() - 1)
				ret += int(m_subSpacing.x);
		}
		return ret;
	}

	vec2 GetSize()
	{
		vec2 ret = vec2(m_text.GetWidth(), m_text.GetHeight());

		// Set height to a minimum value if width is 0 (no characters)
		if (ret.x == 0.0f)
			ret.y = 2.0f;

		if (m_textTitle !is null)
		{
			ret.x = max(int(ret.x), m_textTitle.GetWidth());
			ret.y += m_textTitle.GetHeight() + m_titleSpacing;
		}

		ret.x = max(int(ret.x), GetSubtextWidth());
		if (m_subTexts.length() > 0)
			ret.y += m_subTexts[0].m_text.GetHeight() + m_subSpacing.y;

		ret.x += int(m_sizeOffset.x);
		ret.y += int(m_sizeOffset.y);

		return ret;
	}

	void Draw(SpriteBatch& sb, vec2 pos)
	{
		if (m_text is null)
			return;

		//pos.x = int(pos.x);
		//pos.y = int(pos.y);

		vec2 size = GetSize();

		vec2 offset = vec2(22, 3);

		if (pos.x + offset.x + size.x > g_gameMode.m_wndWidth)
			offset.x = -offset.x - size.x;
		if (pos.y + offset.y + size.y > g_gameMode.m_wndHeight)
			offset.y = -offset.y - size.y;

		pos += offset;

		if (pos.x < 0)
			pos.x = 0;
		else if (pos.x + size.x > g_gameMode.m_wndWidth)
			pos.x = g_gameMode.m_wndWidth - size.x;

		if (pos.y < 0)
			pos.y = 0;
		else if (pos.y + size.y > g_gameMode.m_wndHeight)
			pos.y = g_gameMode.m_wndHeight - size.y;

		auto tm = g_menuTime;

		if (!m_enabled)
			sb.EnableColorize(vec4(0, 0, 0, 1), vec4(0.125, 0.125, 0.125, 1), vec4(0.25, 0.25, 0.25, 1));

		if (GetVarBool("ui_tooltip_pretty"))
		{
			m_spriteTopLeft.Draw(sb, pos, tm);
			m_spriteTop.Draw(sb, vec4(
				pos.x + m_spriteTopLeft.GetWidth(),
				pos.y,
				size.x - m_spriteTopLeft.GetWidth() - m_spriteTopRight.GetWidth(),
				m_spriteTop.GetHeight()
			), tm);
			m_spriteTopRight.Draw(sb, pos + vec2(size.x - m_spriteTopRight.GetWidth(), 0), tm);

			m_spriteLeft.Draw(sb, vec4(
				pos.x,
				pos.y + m_spriteTopLeft.GetHeight(),
				m_spriteLeft.GetWidth(),
				size.y - m_spriteTopLeft.GetHeight() - m_spriteBottomLeft.GetHeight()
			), tm);
			m_spriteMiddle.Draw(sb, vec4(
				pos.x + m_spriteTopLeft.GetWidth(),
				pos.y + m_spriteTopLeft.GetHeight(),
				size.x - m_spriteTopLeft.GetWidth() - m_spriteTopRight.GetWidth(),
				size.y - m_spriteTopLeft.GetHeight() - m_spriteBottomLeft.GetHeight()
			), tm);
			m_spriteRight.Draw(sb, vec4(
				pos.x + size.x - m_spriteRight.GetWidth(),
				pos.y + m_spriteTopRight.GetHeight(),
				m_spriteRight.GetWidth(),
				size.y - m_spriteTopRight.GetHeight() - m_spriteBottomRight.GetHeight()
			), tm);

			m_spriteBottomLeft.Draw(sb, pos + vec2(0, size.y - m_spriteBottomLeft.GetHeight()), tm);
			m_spriteBottom.Draw(sb, vec4(
				pos.x + m_spriteBottomLeft.GetWidth(),
				pos.y + size.y - m_spriteBottom.GetHeight(),
				size.x - m_spriteBottomLeft.GetWidth() - m_spriteBottomRight.GetWidth(),
				m_spriteBottom.GetHeight()
			), tm);
			m_spriteBottomRight.Draw(sb, pos + vec2(size.x - m_spriteBottomRight.GetWidth(), size.y - m_spriteBottomRight.GetHeight()), tm);
		}
		else
			sb.FillRectangle(vec4(pos.x + 2, pos.y + 2, size.x, size.y), vec4(0, 0, 0, 0.8));

		vec2 textPos = pos + m_textOffset;

		float anchorX = 0;
		switch (m_textAlignment)
		{
			case TextAlignment::Center: anchorX = 0.5; break;
			case TextAlignment::Right: anchorX = 1; break;
		}

		float contentWidth = size.x - m_textOffset.x * 2;

		if (m_textTitle !is null)
		{
			sb.DrawString(textPos + vec2(anchorX * (contentWidth - m_textTitle.GetWidth()), 0), m_textTitle);
			textPos += vec2(0, m_textTitle.GetHeight() + m_titleSpacing);
		}

		int totalSubWidth = GetSubtextWidth();
		int subX = int((anchorX * contentWidth) - (anchorX * totalSubWidth));

		for (uint i = 0; i < m_subTexts.length(); i++)
		{
			auto subText = m_subTexts[i];

			vec2 subTextPos = textPos + vec2(subX, 0);
			subX += int(subText.GetWidth() + m_subSpacing.x);

			vec2 subTextOffset;
			if (subText.m_sprite !is null)
				subTextOffset.x = subText.m_sprite.GetWidth() + 4;

			sb.DrawString(subTextPos + subTextOffset, subText.m_text);

			if (subText.m_sprite !is null)
				sb.DrawSprite(subTextPos + vec2(0, subText.m_text.GetHeight() / 2 - subText.m_sprite.GetHeight() / 2 + 1), subText.m_sprite, g_menuTime);
		}

		if (m_subTexts.length() > 0)
			textPos += vec2(0, m_subTexts[0].m_text.GetHeight() + m_subSpacing.y);

		sb.DrawString(textPos + vec2(anchorX * (contentWidth - m_text.GetWidth()), 0), m_text);

		if (!m_enabled)
			sb.DisableColorize();
	}
}
