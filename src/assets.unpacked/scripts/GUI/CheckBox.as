class CheckBoxWidget : ICheckableWidget, Widget
{
	GUIDef@ m_def;

	CheckBoxGroupWidget@ m_checkBoxGroup;

	SpriteRect@ m_spriteRect;
	Sprite@ m_spriteUnchecked;
	Sprite@ m_spriteHover;
	Sprite@ m_spriteChecked;
	Sprite@ m_spriteDisabled;

	bool m_enabled;
	bool m_disabledTooltip;

	BitmapFont@ m_font;
	BitmapString@ m_text;

	string m_str = "";
	vec4 m_color = vec4(1, 1, 1, 1);

	string m_value;

	string m_func;
	string m_funcHover;
	string m_funcLeave;

	string m_cvar;
	bool m_cvarOrig;

	bool m_checked;

	SoundEvent@ m_pressSound;
	SoundEvent@ m_selectSound;

	int m_contentWidth;
	int m_contentHeight;

	CheckBoxWidget()
	{
		super();
	}

	string GetValue() { return m_value; }
	bool IsChecked() { return m_checked; }
	void SetCheckable() { }
	void SetChecked(bool b) { m_checked = b; }
	void SetGroupWidget(CheckBoxGroupWidget@ group) { @m_checkBoxGroup = group; }
	bool IsEnabled() { return m_enabled; }

	Widget@ Clone() override
	{
		CheckBoxWidget@ w = CheckBoxWidget();
		CloneInto(w);
		return w;
	}

	void Reset()
	{
		bool def = GetVarBoolDefault(m_cvar);
		SetVar(m_cvar, def);
		if (def)
			SetChecked(true);
		else
			SetChecked(false);
	}

	void Cancel()
	{
		SetVar(m_cvar, m_cvarOrig);
		if (m_cvarOrig)
			SetChecked(true);
		else
			SetChecked(false);
	}

	void Save()
	{
		m_cvarOrig = GetVarBool(m_cvar);
		Config::SaveVar(m_cvar);
	}

	bool IsChanged()
	{
		return GetVarBool(m_cvar) != m_cvarOrig;
	}

	void SetSpriteset(const string &in spriteset)
	{
		if (spriteset.findLast(".sval") == int(spriteset.length()) - 5)
			@m_spriteRect = SpriteRect(spriteset);
		else
		{
			@m_spriteUnchecked = m_def.GetSprite(spriteset);
			@m_spriteHover = m_def.GetSprite(spriteset + "-hover");
			@m_spriteChecked = m_def.GetSprite(spriteset + "-checked");
			@m_spriteDisabled = m_def.GetSprite(spriteset + "-disabled");
		}
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		@m_def = ctx.GetGUIDef();

		SetSpriteset(ctx.GetString("spriteset"));

		m_enabled = ctx.GetBoolean("enabled", false, true);
		m_disabledTooltip = ctx.GetBoolean("disabled-tooltip", false);

		if (m_font is null)
		{
			string fontName = ctx.GetString("font", false);
			@m_font = Resources::GetBitmapFont(fontName);
		}

		m_color = ctx.GetColorRGBA("color", false, vec4(1, 1, 1, 1));

		m_value = ctx.GetString("value", false);

		m_func = ctx.GetString("func", false);
		m_funcHover = ctx.GetString("func-hover", false);
		m_funcLeave = ctx.GetString("func-leave", false);

		m_checked = ctx.GetBoolean("checked", false);

		m_cvar = ctx.GetString("cvar", false);
		if (m_cvar != "")
		{
			SetChecked(GetVarBool(m_cvar));
			m_cvarOrig = GetVarBool(m_cvar);
		}

		SetText(Resources::GetString(ctx.GetString("text", false)));

		@m_pressSound = Resources::GetSoundEvent("event:/ui/button_click");
		@m_selectSound = Resources::GetSoundEvent("event:/ui/button_hover");

		if (m_font is null)
		{
			if (m_spriteRect !is null)
			{
				m_width = ctx.GetInteger("content-width", false, m_spriteRect.m_width);
				m_height = ctx.GetInteger("content-height", false, m_spriteRect.m_height);
			}
			else
			{
				m_width = ctx.GetInteger("content-width", false, m_spriteUnchecked.GetWidth());
				m_height = ctx.GetInteger("content-height", false, m_spriteUnchecked.GetHeight());
			}
		}

		Widget::Load(ctx);

		m_canFocus = true;
	}

	void SetText(string str)
	{
		if (m_font is null)
			return;

		m_str = str;

		@m_text = m_font.BuildText(str);
		m_text.SetColor(m_color);

		if (m_spriteUnchecked !is null)
			m_width = m_text.GetWidth() + m_spriteUnchecked.GetWidth() + 1;
		else
			m_width = m_text.GetWidth();
		m_height = m_text.GetHeight();
	}

	void SetColor(vec4 color)
	{
		m_color = color;

		m_text.SetColor(color);
	}

	bool OnClick(vec2 mousePos) override
	{
		if (!m_enabled)
			return false;

		PlaySound2D(m_pressSound);

		if (m_checkBoxGroup !is null)
			m_checkBoxGroup.Toggled(this);
		else
			m_checked = !m_checked;

		if (m_func != "")
			m_host.OnFunc(this, m_func);

		return true;
	}

	bool OnDoubleClick(vec2 mousePos) override
	{
		if (!m_enabled)
			return false;

		PlaySound2D(m_pressSound);

		if (m_checkBoxGroup !is null)
			return m_checkBoxGroup.OnDoubleClick(mousePos);

		return true;
	}

	void OnMouseEnter(vec2 mousePos, bool forced) override
	{
		if (m_enabled || m_disabledTooltip)
			Widget::OnMouseEnter(mousePos, forced);

		if (m_enabled)
		{
			PlaySound2D(m_selectSound);

			if (m_funcHover != "")
				m_host.OnFunc(this, m_funcHover);
		}
	}

	void OnMouseLeave(vec2 mousePos) override
	{
		Widget::OnMouseLeave(mousePos);

		if (m_enabled && m_funcLeave != "")
			m_host.OnFunc(this, m_funcLeave);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		int textOffset = 0;

		if (m_spriteRect !is null)
		{
			int variation = 0;

			if (!m_enabled)
				variation = 3;
			else if (m_checked)
				variation = 2;
			else if (m_hovering)
				variation = 1;

			m_spriteRect.Draw(sb, pos, m_width, m_height, variation);
		}
		else
		{
			Sprite@ sprite = m_spriteUnchecked;
			if (m_checked)
				@sprite = m_spriteChecked;
			else if (m_hovering && m_spriteHover !is null && m_enabled)
				@sprite = m_spriteHover;

			if (!m_enabled)
			{
				if (m_spriteDisabled !is null)
					@sprite = m_spriteDisabled;
				else
					sb.EnableColorize(vec4(0, 0, 0, 1), vec4(0.125, 0.125, 0.125, 1), vec4(0.25, 0.25, 0.25, 1));
			}

			sb.DrawSprite(pos + vec2(0, m_height / 2 - sprite.GetHeight() / 2), sprite, g_menuTime);

			if (!m_enabled && m_spriteDisabled is null)
				sb.DisableColorize();

			textOffset = sprite.GetWidth() + 2;
		}

		if (m_text !is null)
		{
			vec4 textColor = m_color;
			if (!m_enabled)
				textColor = vec4(0.25, 0.25, 0.25, 1);
			m_text.SetColor(textColor);
			sb.DrawString(pos + vec2(textOffset, -1), m_text);
		}
	}
}

ref@ LoadCheckboxWidget(WidgetLoadingContext &ctx)
{
	CheckBoxWidget@ w = CheckBoxWidget();
	w.Load(ctx);
	return w;
}
