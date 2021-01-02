class SpriteWidget : Widget
{
	Sprite@ m_spriteOrig;
	Sprite@ m_sprite;
	string m_spriteSrc;
	Texture2D@ m_spriteTexture;
	ScriptSprite@ m_ssprite;

	bool m_colorize;
	array<vec4> m_colorizeColors = { vec4(0, 0, 0, 1), vec4(0.125, 0.125, 0.125, 1), vec4(0.25, 0.25, 0.25, 1) };

	array<array<vec4>> m_multiColors;

	vec4 m_color;

	GUIDef@ m_def;

	int m_timeOffset;
	int m_fixedTime = -1;

	bool m_autoSize;
	
	SpriteWidget()
	{
		super();
		@m_spriteOrig = null;
		@m_sprite = null;
		
		m_width = 0;
		m_height = 0;
	}

	Widget@ Clone() override
	{
		SpriteWidget@ w = SpriteWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		@m_def = ctx.GetGUIDef();

		m_autoSize = ctx.GetBoolean("autosize", false, true);
		if (!m_autoSize)
			LoadWidthHeight(ctx);

		m_spriteSrc = ctx.GetString("src", false);
		if (m_spriteSrc != "")
			SetSprite(m_def.GetSprite(m_spriteSrc));

		if (m_sprite !is null && ctx.GetBoolean("random-start", false))
			m_timeOffset = -randi(m_sprite.GetLength());

		m_color = ctx.GetColorRGBA("color", false, vec4(1, 1, 1, 1));

		Widget::Load(ctx);
	}

	void SetSprite(string spriteName, bool resetTime = false)
	{
		m_spriteSrc = spriteName;
		SetSprite(m_def.GetSprite(spriteName), resetTime);
	}
	
	void SetSprite(Sprite@ sprite, bool resetTime = false)
	{
		if (m_spriteOrig is null)
			@m_spriteOrig = sprite;
		@m_sprite = sprite;
		@m_ssprite = null;
		
		if (m_autoSize)
		{
			if (m_sprite !is null)
			{
				m_width = m_sprite.GetWidth();
				m_height = m_sprite.GetHeight();
			}
			else
			{
				m_width = 0;
				m_height = 0;
			}
		}

		if (resetTime)
			m_timeOffset = g_menuTime;
	}
	
	void SetSprite(ScriptSprite@ sprite, bool resetTime = false)
	{
		@m_sprite = null;
		@m_ssprite = sprite;
		
		if (m_autoSize)
		{
			if (m_ssprite !is null)
			{
				m_width = m_ssprite.GetWidth();
				m_height = m_ssprite.GetHeight();
			}
			else
			{
				m_width = 0;
				m_height = 0;
			}
		}

		if (resetTime)
			m_timeOffset = g_menuTime;
	}

	void SetTexture(Texture2D@ texture)
	{
		@m_spriteTexture = texture;
	}
	
	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		vec4 dst = vec4(pos.x, pos.y, m_width, m_height);

		Texture2D@ texture = null;
		if (m_sprite !is null)
			@texture = m_sprite.GetTexture2D();
		else if (m_ssprite !is null)
			@texture = m_ssprite.m_texture;
		else if (m_spriteTexture !is null)
			@texture = m_spriteTexture;
		else
			return;

		if (texture is null)
		{
			PrintError("There is no texture for sprite widget! (src: \"" + m_spriteSrc + "\")");
			return;
		}

		if (m_colorize)
			sb.EnableColorize(m_colorizeColors[0], m_colorizeColors[1], m_colorizeColors[2]);

		for (uint i = 0; i < m_multiColors.length(); i++)
		{
			array<vec4> colors = m_multiColors[i];
			sb.SetMultiColor(i, colors[0], colors[1], colors[2]);
		}

		if (m_sprite !is null)
		{
			vec4 src;
			if (m_fixedTime != -1)
				src = m_sprite.GetFrame(m_fixedTime);
			else
				src = m_sprite.GetFrame(g_menuTime - m_timeOffset);
			sb.DrawSprite(texture, dst, src, m_color);
		}
		else if (m_ssprite !is null)
		{
			if (m_fixedTime != -1)
				m_ssprite.Draw(sb, dst, m_fixedTime, m_color);
			else
				m_ssprite.Draw(sb, dst, g_menuTime - m_timeOffset, m_color);
		}

		if (m_multiColors.length() > 0)
			sb.DisableMultiColor();

		if (m_colorize)
			sb.DisableColorize();
	}

	void AnimateSet(string key, vec4 v) override
	{
		if (key == "color")
			m_color = v;
		else
			Widget::AnimateSet(key, v);
	}

	void AnimateSet(string key, Sprite@ s) override
	{
		if (key == "sprite")
			SetSprite(s);
		else if (key == "spriter")
			SetSprite(s, true);
		else if (key == "sprite0")
		{
			SetSprite(s);
			m_timeOffset = 0;
		}
	}
}

ref@ LoadSpriteWidget(WidgetLoadingContext &ctx)
{
	SpriteWidget@ w = SpriteWidget();
	w.Load(ctx);
	return w;
}