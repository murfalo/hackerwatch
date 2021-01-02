class ScalableSpriteButtonWidget : ICheckableWidget, Widget
{
	CheckBoxGroupWidget@ m_checkBoxGroup;

	array<Sprite@> m_sprite;
	array<Sprite@> m_spriteHover;
	array<Sprite@> m_spriteDown;
	array<Sprite@> m_spriteDisabled;

	string m_func;
	string m_funcHover;
	string m_funcLeave;

	SoundEvent@ m_pressSound;
	SoundEvent@ m_selectSound;

	bool m_buttonDown;

	vec4 m_colorText;
	vec4 m_colorTextOriginal;
	vec4 m_colorDisableText;
	vec4 m_colorHoverText;
	vec4 m_colorDownText;

	bool m_enabled;
	bool m_disabledInGame;
	bool m_dynamicWidth;

	BitmapFont@ m_font;
	BitmapString@ m_text;

	string m_value;
	bool m_checkable;
	bool m_checked;

	vec2 m_textOffset;

	ScalableSpriteButtonWidget()
	{
		super();
	}

	string GetValue() { return m_value; }
	bool IsChecked() { return m_checked; }
	void SetCheckable() { m_checkable = true; }
	void SetChecked(bool b) { m_checked = b; }
	void SetGroupWidget(CheckBoxGroupWidget@ group) { @m_checkBoxGroup = group; }

	Widget@ Clone() override
	{
		ScalableSpriteButtonWidget@ w = ScalableSpriteButtonWidget();
		CloneInto(w);
		return w;
	}

	bool IsEnabled()
	{
		if (m_disabledInGame && cast<MainMenu>(g_gameMode).m_state == MenuState::InGameMenu)
			return false;
		return m_enabled;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		GUIDef@ def = ctx.GetGUIDef();
		string spriteSet = ctx.GetString("spriteset");

		m_sprite.insertLast(def.GetSprite(spriteSet + "-left"));
		m_sprite.insertLast(def.GetSprite(spriteSet + "-mid"));
		m_sprite.insertLast(def.GetSprite(spriteSet + "-right"));

		m_spriteHover.insertLast(def.GetSprite(spriteSet + "-hover-left"));
		m_spriteHover.insertLast(def.GetSprite(spriteSet + "-hover-mid"));
		m_spriteHover.insertLast(def.GetSprite(spriteSet + "-hover-right"));

		m_spriteDown.insertLast(def.GetSprite(spriteSet + "-down-left"));
		m_spriteDown.insertLast(def.GetSprite(spriteSet + "-down-mid"));
		m_spriteDown.insertLast(def.GetSprite(spriteSet + "-down-right"));

		m_spriteDisabled.insertLast(def.GetSprite(spriteSet + "-disabled-left"));
		m_spriteDisabled.insertLast(def.GetSprite(spriteSet + "-disabled-mid"));
		m_spriteDisabled.insertLast(def.GetSprite(spriteSet + "-disabled-right"));

		m_func = ctx.GetString("func", false);
		m_funcHover = ctx.GetString("func-hover", false);
		m_funcLeave = ctx.GetString("func-leave", false);

		@m_pressSound = Resources::GetSoundEvent("event:/ui/button_click");
		@m_selectSound = Resources::GetSoundEvent("event:/ui/button_hover");

		@m_font = Resources::GetBitmapFont(ctx.GetString("font", false));
		bool caps = ctx.GetBoolean("text-caps", false);
		if (caps)
			SetText(utf8string(Resources::GetString(ctx.GetString("text", false))).toUpper().plain());
		else
			SetText(Resources::GetString(ctx.GetString("text", false)));

		m_textOffset = ctx.GetVector2("textoffset", false, m_textOffset);

		m_colorTextOriginal = m_colorText = ctx.GetColorRGBA("color", false, Tweak::ScaleButtonTextColor);
		m_colorDisableText = ctx.GetColorRGBA("disabletext", false, vec4(0.5, 0.5, 0.5, 1));
		m_colorHoverText = ctx.GetColorRGBA("hovertext", false, Tweak::ScaleButtonTextHoverColor);
		m_colorDownText = ctx.GetColorRGBA("downtext", false, Tweak::ScaleButtonTextDownColor);

		m_enabled = ctx.GetBoolean("enabled", false, true);
		m_disabledInGame = ctx.GetBoolean("not-in-game", false, false);

		m_value = ctx.GetString("value", false);
		m_checkable = ctx.GetBoolean("checkable", false);
		m_checked = ctx.GetBoolean("checked", false);

		m_width = ctx.GetInteger("width", false, -1);
		if (m_width == -1)
		{
			m_dynamicWidth = true;
			m_width = 20;
		}
		m_height = m_sprite[0].GetHeight();

		m_canFocus = true;
	}

	void SetText(string str)
	{
		if (str == "")
			@m_text = null;
		else if (m_font !is null)
			@m_text = m_font.BuildText(str);
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (m_dynamicWidth && m_text !is null)
			m_width = m_text.GetWidth() + int(m_padding.x) * 2;

		Widget::DoLayout(origin, parentSz);
	}

	vec4 GetTextColor()
	{
		if (!IsEnabled())
			return m_colorDisableText;
		else if (m_buttonDown || (m_checked && m_checked))
			return m_colorDownText;
		else if (m_hovering)
			return m_colorHoverText;
		return m_colorText;
	}

	array<Sprite@> GetSprites()
	{
		if (!IsEnabled())
			return m_spriteDisabled;
		else
		{
			if (m_buttonDown || (m_checkable && m_checked))
				return m_spriteDown;
			else if (m_hovering)
				return m_spriteHover;
			else
				return m_sprite;
		}
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		array<Sprite@> sprites = GetSprites();
		if (sprites.length() == 0)
			return;

		Sprite@ left = sprites[0];
		Sprite@ mid = sprites[1];
		Sprite@ right = sprites[2];

		vec2 posLeft = pos;
		vec2 posRight = pos + vec2(m_width - right.GetWidth(), 0);
		vec4 rectMid = vec4(
			pos.x + left.GetWidth(),
			pos.y,
			m_width - left.GetWidth() - right.GetWidth(),
			m_height
		);

		sb.DrawSprite(posLeft, left, g_menuTime);
		sb.DrawSprite(mid.GetTexture2D(), rectMid, mid.GetFrame(g_menuTime));
		sb.DrawSprite(posRight, right, g_menuTime);

		if (m_text !is null)
		{
			m_text.SetColor(GetTextColor());

			vec2 textPos = GetTextPos();
			if (textPos.x < m_width)
				sb.DrawString(pos + textPos, m_text);
		}
	}

	vec2 GetTextPos()
	{
		int w = 0;
		int h = 0;

		if (m_text !is null)
		{
			w = m_text.GetWidth();
			h = m_text.GetHeight();
		}

		vec2 textPos;
		if (m_textOffset.x == 0)
			textPos.x = m_width / 2.0f - w / 2.0f;
		else
			textPos.x = m_textOffset.x;
		textPos.y = m_height / 2.0f - h / 2.0f + m_textOffset.y;

		textPos.x = int(textPos.x);
		textPos.y = int(textPos.y);
		return textPos;
	}

	bool OnClick(vec2 mousePos) override
	{
		if (!IsEnabled())
			return false;

		if (!m_buttonDown)
			return true;

		if (m_checkable)
		{
			if (m_checkBoxGroup !is null)
				m_checkBoxGroup.Toggled(this);
			else
				m_checked = !m_checked;
		}

		m_host.OnFunc(this, m_func);
		PlaySound2D(m_pressSound);
		return true;
	}

	void OnMouseEnter(vec2 mousePos, bool forced) override
	{
		Widget::OnMouseEnter(mousePos, forced);

		if (!IsEnabled())
			return;

		PlaySound2D(m_selectSound);

		if (m_funcHover != "")
			m_host.OnFunc(this, m_funcHover);
	}

	bool OnMouseDown(vec2 mousePos) override { m_buttonDown = true; return true; }
	bool OnMouseUp(vec2 mousePos) override { m_buttonDown = false; return true; }

	void OnMouseLeave(vec2 mousePos) override
	{
		Widget::OnMouseLeave(mousePos);

		if (!IsEnabled())
			return;

		m_buttonDown = false;

		if (m_funcLeave != "")
			m_host.OnFunc(this, m_funcLeave);
	}

	void SetHovering(bool hovering, vec2 mousePos, bool force = false) override
	{
		//HACK: We need to force current input focus to null here in order to avoid bad UX in text input dialog
		if (hovering && cast<TextInputWidget>(g_gameMode.m_widgetInputFocus) !is null)
			@g_gameMode.m_widgetInputFocus = null;

		Widget::SetHovering(hovering, mousePos, force);
	}

	void ShowTooltip() override
	{
		m_tooltipEnabled = m_enabled;
		Widget::ShowTooltip();
	}
}

ref@ LoadScalableSpriteButtonWidget(WidgetLoadingContext &ctx)
{
	ScalableSpriteButtonWidget@ w = ScalableSpriteButtonWidget();
	w.Load(ctx);
	return w;
}
