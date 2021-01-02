class SpriteButtonWidget : Widget
{
	GUIDef@ m_def;

	Sprite@ m_sprite;
	Sprite@ m_spriteHover;
	Sprite@ m_spriteDown;
	Sprite@ m_spriteDisabled;

	string m_func;
	string m_funcHover;
	string m_funcLeave;

	SoundEvent@ m_pressSound;
	SoundEvent@ m_selectSound;

	bool m_buttonDown;

	TextWidget@ m_wText;
	vec4 m_colorHoverText;

	bool m_enabled;

	SpriteButtonWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		SpriteButtonWidget@ w = SpriteButtonWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		@m_def = ctx.GetGUIDef();

		string spriteSet = ctx.GetString("spriteset", false);
		if (spriteSet != "")
			SetSpriteset(spriteSet);
		else
		{
			string spriteDefault = ctx.GetString("sprite");
			@m_sprite = m_def.GetSprite(spriteDefault);

			string spriteHover = ctx.GetString("sprite-hover", false, spriteDefault);
			@m_spriteHover = m_def.GetSprite(spriteHover);

			@m_spriteDown = m_def.GetSprite(ctx.GetString("sprite-down", false, spriteHover));
		}

		m_func = ctx.GetString("func", false);
		m_funcHover = ctx.GetString("func-hover", false);
		m_funcLeave = ctx.GetString("func-leave", false);

		@m_pressSound = Resources::GetSoundEvent("event:/ui/button_click");
		@m_selectSound = Resources::GetSoundEvent("event:/ui/button_hover");

		m_colorHoverText = ctx.GetColorRGBA("hovertext", false, vec4());

		m_enabled = ctx.GetBoolean("enabled", false, true);

		if (m_sprite !is null)
		{
			m_width = m_sprite.GetWidth();
			m_height = m_sprite.GetHeight();
		}

		m_canFocus = true;
	}

	void SetSpriteset(string spriteSet)
	{
		@m_sprite = m_def.GetSprite(spriteSet);
		@m_spriteHover = m_def.GetSprite(spriteSet + "-hover");
		@m_spriteDown = m_def.GetSprite(spriteSet + "-down");
		@m_spriteDisabled = m_def.GetSprite(spriteSet + "-disabled");
	}

	Sprite@ GetCurrentSprite()
	{
		if (!m_enabled && m_spriteDisabled !is null)
			return m_spriteDisabled;

		if (!m_hovering || !m_enabled)
			return m_sprite;
		else
		{
			if (!m_buttonDown)
				return m_spriteHover;
			else
				return m_spriteDown;
		}
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		sb.DrawSprite(pos, GetCurrentSprite(), g_menuTime);
	}

	bool OnClick(vec2 mousePos) override
	{
		if (!m_enabled)
			return false;

		if (!m_buttonDown)
			return true;

		m_host.OnFunc(this, m_func);
		PlaySound2D(m_pressSound);
		return true;
	}

	void ShowTooltip() override
	{
		m_tooltipEnabled = m_enabled;
		Widget::ShowTooltip();
	}

	void OnMouseEnter(vec2 mousePos, bool forced) override
	{
		Widget::OnMouseEnter(mousePos, forced);

		if (!m_enabled)
			return;

		PlaySound2D(m_selectSound);

		if (m_colorHoverText.w > 0)
		{
			if (m_wText is null)
				@m_wText = cast<TextWidget>(m_children[0]);
			m_wText.SetColor(m_colorHoverText);
		}

		if (m_funcHover != "")
			m_host.OnFunc(this, m_funcHover);
	}

	bool OnMouseDown(vec2 mousePos) override { m_buttonDown = true; return true; }
	bool OnMouseUp(vec2 mousePos) override { m_buttonDown = false; return true; }

	void OnMouseLeave(vec2 mousePos) override
	{
		Widget::OnMouseLeave(mousePos);

		if (!m_enabled)
			return;

		m_buttonDown = false;

		if (m_colorHoverText.w > 0 && m_wText !is null)
			m_wText.SetColor(m_wText.m_colorOriginal);

		if (m_funcLeave != "")
			m_host.OnFunc(this, m_funcLeave);
	}
}

ref@ LoadSpriteButtonWidget(WidgetLoadingContext &ctx)
{
	SpriteButtonWidget@ w = SpriteButtonWidget();
	w.Load(ctx);
	return w;
}
