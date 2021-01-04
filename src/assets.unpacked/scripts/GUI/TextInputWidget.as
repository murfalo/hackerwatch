class TextInputWidget : Widget
{
	BitmapFont@ m_font;
	BitmapString@ m_bitmapText;

	utf8string m_text;
	int m_cursorPos = 0;
	float m_drawOffset = 0;

	vec2 m_textOffset;
	int m_textLimit;

	vec2 m_caretPos;
	int m_caretHeight;

	string m_func;
	string m_funcEdit;
	string m_funcCancel;

	TextAlignment m_alignment = TextAlignment::Left;

	vec4 m_color;

	void Load(WidgetLoadingContext &ctx) override
	{
		LoadWidthHeight(ctx);

		string alignStr = ctx.GetString("align", false);
		     if (alignStr == "right") m_alignment = TextAlignment::Right;
		else if (alignStr == "center") m_alignment = TextAlignment::Center;

		m_color = ctx.GetColorRGBA("color", false, vec4(1, 1, 1, 1));

		@m_font = Resources::GetBitmapFont(ctx.GetString("font"));
		m_text = ctx.GetString("text", false, "");

		m_textOffset = ctx.GetVector2("textoffset", false);
		m_textLimit = ctx.GetInteger("textlimit", false, -1);

		m_caretHeight = int(m_font.MeasureText("W").y);

		m_func = ctx.GetString("func", false, "");
		m_funcEdit = ctx.GetString("func-edit", false, "");
		m_funcCancel = ctx.GetString("func-cancel", false, "");

		@m_cursor = Platform::CursorCaret;

		UpdateText();
		Widget::Load(ctx);

		m_canFocus = true;
		m_canFocusInput = true;

		//m_overflow = WidgetOverflow::None;
	}

	void ClearText()
	{
		m_text = "";
		m_cursorPos = 0;
		m_drawOffset = 0;
		UpdateText();
		UpdateCursorPos();
	}

	bool UpdateInput(GameInput& input, MenuInput& menuInput) override
	{
		bool textUpdated = false;
		bool cursorUpdated = false;

		int n = input.GetTextInputCount();
		for (int i = 0; i < n; i++)
		{
			auto evt = input.GetTextInput(i);
			switch (evt.evt)
			{
				case TextInputControlEventType::None:
				case TextInputControlEventType::Paste:
					if (m_textLimit != -1 && int(m_text.length()) >= m_textLimit)
						break;
					m_text.insert(m_cursorPos, evt.text);
					m_cursorPos += evt.text.length();
					textUpdated = true;
					cursorUpdated = true;
					break;

				case TextInputControlEventType::Submit:
					if (m_func != "")
						m_host.OnFunc(this, m_func);
					break;

				case TextInputControlEventType::Cancel:
					@g_gameMode.m_widgetInputFocus = null;
					if (m_funcCancel != "")
						m_host.OnFunc(this, m_funcCancel);
					break;

				case TextInputControlEventType::Home: m_cursorPos = 0; cursorUpdated = true; break;
				case TextInputControlEventType::End: m_cursorPos = m_text.length(); cursorUpdated = true; break;

				case TextInputControlEventType::Left:
					if (--m_cursorPos < 0)
						m_cursorPos = 0;
					cursorUpdated = true;
					break;
				case TextInputControlEventType::Right:
					if (++m_cursorPos > int(m_text.length()))
						m_cursorPos = m_text.length();
					cursorUpdated = true;
					break;

				case TextInputControlEventType::LeftWord:
					if (m_cursorPos > 0)
					{
						int j = m_text.findLast(" ", m_cursorPos - 1);
						if (j == -1)
							m_cursorPos = 0;
						else
							m_cursorPos = j;
						cursorUpdated = true;
					}
					break;
				case TextInputControlEventType::RightWord:
					if (m_cursorPos < int(m_text.length()))
					{
						int j = m_text.findFirst(" ", m_cursorPos + 1);
						if (j == -1)
							m_cursorPos = m_text.length();
						else
							m_cursorPos = j + 1;
						cursorUpdated = true;
					}
					break;

				case TextInputControlEventType::Backspace:
					if (m_cursorPos > 0)
					{
						m_text.erase(--m_cursorPos, 1);
						textUpdated = true;
						cursorUpdated = true;
					}
					break;

				case TextInputControlEventType::Delete:
					if (m_cursorPos < int(m_text.length()))
					{
						m_text.erase(m_cursorPos, 1);
						textUpdated = true;
					}
					break;
			}
		}

		if (textUpdated)
		{
			UpdateText();
			if (m_funcEdit != "")
				m_host.OnFunc(this, m_funcEdit);
		}

		if (cursorUpdated)
			UpdateCursorPos();

		return true;
	}

	void SetText(string str)
	{
		m_text = str;
		UpdateText();

		m_cursorPos = m_text.length();
		UpdateCursorPos();
	}

	void UpdateText()
	{
		if (m_font is null)
			return;

		@m_bitmapText = m_font.BuildText(EscapeString(m_text.plain()));
		m_bitmapText.SetColor(m_color);

		if (m_bitmapText.GetWidth() <= m_width)
			m_drawOffset = 0;
	}

	vec2 GetTextOffset()
	{
		if (m_bitmapText.GetWidth() > m_width)
			return m_textOffset;

		if (m_alignment == TextAlignment::Left)
			return m_textOffset;
		else if (m_alignment == TextAlignment::Center)
			return vec2(m_width / 2 - m_bitmapText.GetWidth() / 2, m_textOffset.y);
		else if (m_alignment == TextAlignment::Right)
			return vec2(m_width - m_bitmapText.GetWidth(), m_textOffset.y);

		return vec2();
	}

	void UpdateCursorPos()
	{
		if (m_font is null)
			return;

		string escText = EscapeString(m_text.substr(0, m_cursorPos).plain());
		auto textSize = m_font.MeasureText(escText);
		m_caretPos.x = textSize.x;
		m_caretPos.y = 0;

		if (m_bitmapText.GetWidth() > m_width)
		{
			float left = m_drawOffset;
			float right = left + m_width;

			if (m_caretPos.x > right)
				m_drawOffset = m_caretPos.x - m_width;
			else if (m_caretPos.x < left)
				m_drawOffset = max(0.0f, m_caretPos.x - 20.0f);
		}
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_bitmapText is null)
			return;

		sb.PushClipping(vec4(
			m_origin.x, m_origin.y,
			m_width, m_height
		));

		vec2 textPos = pos + GetTextOffset();
		textPos.x -= m_drawOffset;

		sb.DrawString(textPos, m_bitmapText);

		sb.PopClipping();

		if (g_gameMode.m_widgetInputFocus is this)
		{
			vec4 rectCaret;
			rectCaret.x = textPos.x + m_caretPos.x;
			rectCaret.y = textPos.y + m_caretPos.y;
			rectCaret.z = 1;
			rectCaret.w = m_caretHeight;
			sb.DrawSprite(null, rectCaret, rectCaret, vec4(1, 1, 1, 1));
		}
	}
}

ref LoadTextInputWidget(WidgetLoadingContext &ctx)
{
	TextInputWidget@ w = TextInputWidget();
	w.Load(ctx);
	return w;
}
