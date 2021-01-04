class DetailsWidget : Widget
{
	SpriteRect@ m_spriteRect;

	Sprite@ m_spriteArrowDown;
	Sprite@ m_spriteArrowUp;

	Widget@ m_wHeader;
	Widget@ m_wDetails;

	bool m_pressedDown;

	string m_func;

	DetailsWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		DetailsWidget@ w = DetailsWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		auto def = ctx.GetGUIDef();

		string spriteset = ctx.GetString("spriteset", false, "");
		if (spriteset != "")
			@m_spriteRect = SpriteRect(spriteset);

		@m_spriteArrowDown = def.GetSprite(ctx.GetString("arrow-down", false));
		@m_spriteArrowUp = def.GetSprite(ctx.GetString("arrow-up", false));

		m_func = ctx.GetString("func", false);

		Widget::Load(ctx);

		m_canFocus = true;

		m_flow = WidgetFlow::Vbox;

		if (m_spriteRect !is null)
		{
			m_padding = vec2(
				m_spriteRect.GetLeft(),
				m_spriteRect.GetTop()
			);
		}
	}

	void UpdateSize()
	{
		int padX = 0;
		int padY = 0;

		if (m_spriteRect !is null)
		{
			padX = m_spriteRect.GetLeft() + m_spriteRect.GetRight();
			padY = m_spriteRect.GetTop() + m_spriteRect.GetBottom();
		}

		m_width = 0;
		m_height = 0;

		if (m_wHeader.m_visible)
		{
			m_width = max(m_width, m_wHeader.m_width);
			m_height += m_wHeader.m_height;
		}

		if (m_wDetails.m_visible)
		{
			m_width = max(m_width, m_wDetails.m_width);
			m_height += m_wDetails.m_height;
		}

		m_width += padX;
		m_height += padY;
	}

	void ToggleDetails()
	{
		m_wDetails.m_visible = !m_wDetails.m_visible;
		m_host.DoLayout();
		UpdateSize();

		if (m_func != "")
			m_host.OnFunc(this, m_func);
	}

	void AddedToParent() override
	{
		Widget::AddedToParent();

		@m_wHeader = GetWidgetById("header");
		@m_wDetails = GetWidgetById("details");

		if (m_wHeader is null)
		{
			PrintError("No header found in DetailsWidget!");
			return;
		}

		if (m_wDetails is null)
		{
			PrintError("No details found in DetailsWidget!");
			return;
		}

		m_wDetails.m_visible = false;

		UpdateSize();
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_spriteRect !is null)
		{
			int variation = 0;
			if (m_hovering && m_pressedDown)
				variation = 2;
			else if (m_hovering)
				variation = 1;

			m_spriteRect.Draw(sb, pos, m_width, m_height, variation);
		}

		Sprite@ arrowSprite = m_spriteArrowDown;
		if (m_wDetails.m_visible)
			@arrowSprite = m_spriteArrowUp;

		if (m_spriteArrowDown !is null)
		{
			float bottomPadding = 8.0f;
			if (m_spriteRect !is null)
				bottomPadding = m_spriteRect.GetBottom();

			vec2 arrowPos = pos + vec2(
				float(int(m_width / 2.0f - arrowSprite.GetWidth() / 2.0f)),
				m_height - arrowSprite.GetHeight() / 2.0f - bottomPadding / 2.0f - 1
			);
			sb.DrawSprite(arrowPos, arrowSprite, g_menuTime);
		}
	}

	bool OnMouseDown(vec2 mousePos) override
	{
		m_pressedDown = true;
		return true;
	}

	bool OnMouseUp(vec2 mousePos) override
	{
		m_pressedDown = false;
		return true;
	}

	bool OnClick(vec2 mousePos) override
	{
		ToggleDetails();
		return true;
	}
}

ref@ LoadDetailsWidget(WidgetLoadingContext &ctx)
{
	DetailsWidget@ w = DetailsWidget();
	w.Load(ctx);
	return w;
}
