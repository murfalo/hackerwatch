class ScrollbarWidget : Widget
{
	vec2 m_topRight;

	string m_forId;
	bool m_outsideContainer;
	int m_extraSize;
	ScrollableWidget@ m_wContainer;

	bool m_overHandle;
	int m_overHandleY;

	int m_buttonsSize;
	int m_troughOffset;
	int m_troughSize;

	int m_handleY;
	int m_handleSize;

	vec4 m_colorTrough;

	vec4 m_colorHandle;
	vec4 m_colorHandleHover;

	vec4 m_colorButtons;
	vec4 m_colorButtonsHover;

	Sprite@ m_spriteHandle;
	Sprite@ m_spriteHandleHover;
	Sprite@ m_spriteHandlePressed;

	Sprite@ m_spriteButtonUp;
	Sprite@ m_spriteButtonUpHover;
	Sprite@ m_spriteButtonUpPressed;
	Sprite@ m_spriteButtonUpDisabled;

	Sprite@ m_spriteButtonDown;
	Sprite@ m_spriteButtonDownHover;
	Sprite@ m_spriteButtonDownPressed;
	Sprite@ m_spriteButtonDownDisabled;

	Sprite@ m_spriteTroughTop;
	Sprite@ m_spriteTroughMiddle;
	Sprite@ m_spriteTroughBottom;

	Sprite@ m_spriteTroughDisabledTop;
	Sprite@ m_spriteTroughDisabledMiddle;
	Sprite@ m_spriteTroughDisabledBottom;

	bool m_handleHover;
	bool m_buttonUpHover;
	bool m_buttonUpPressed;
	bool m_buttonDownHover;
	bool m_buttonDownPressed;

	bool m_hideOnFull;

	int m_handleBorder;

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		GUIDef@ def = ctx.GetGUIDef();

		m_forId = ctx.GetString("forid");
		m_outsideContainer = ctx.GetBoolean("outside", false);
		m_extraSize = ctx.GetInteger("height-add", false);

		m_colorTrough = ctx.GetColorRGBA("color-trough", false, vec4(0, 0, 0, 0));

		m_colorHandle = ctx.GetColorRGBA("color-handle", false, vec4(0, 0.8, 0.5, 0.5));
		m_colorHandleHover = ctx.GetColorRGBA("color-handle-hover", false, m_colorHandle);

		m_colorButtons = ctx.GetColorRGBA("color-buttons", false, vec4(1, 0.8, 0, 0.5));
		m_colorButtonsHover = ctx.GetColorRGBA("color-buttons-hover", false, m_colorButtons);

		string spriteset = ctx.GetString("spriteset", false);
		if (spriteset != "")
		{
			@m_spriteHandle = def.GetSprite(spriteset + "-handle");
			@m_spriteHandleHover = def.GetSprite(spriteset + "-handle-hover");
			@m_spriteHandlePressed = def.GetSprite(spriteset + "-handle-pressed");

			@m_spriteButtonUp = def.GetSprite(spriteset + "-button-up");
			@m_spriteButtonUpHover = def.GetSprite(spriteset + "-button-up-hover");
			@m_spriteButtonUpPressed = def.GetSprite(spriteset + "-button-up-pressed");
			@m_spriteButtonUpDisabled = def.GetSprite(spriteset + "-button-up-disabled");

			@m_spriteButtonDown = def.GetSprite(spriteset + "-button-down");
			@m_spriteButtonDownHover = def.GetSprite(spriteset + "-button-down-hover");
			@m_spriteButtonDownPressed = def.GetSprite(spriteset + "-button-down-pressed");
			@m_spriteButtonDownDisabled = def.GetSprite(spriteset + "-button-down-disabled");

			@m_spriteTroughTop = def.GetSprite(spriteset + "-trough-top");
			@m_spriteTroughMiddle = def.GetSprite(spriteset + "-trough-middle");
			@m_spriteTroughBottom = def.GetSprite(spriteset + "-trough-bottom");

			@m_spriteTroughDisabledTop = def.GetSprite(spriteset + "-trough-disabled-top");
			@m_spriteTroughDisabledMiddle = def.GetSprite(spriteset + "-trough-disabled-middle");
			@m_spriteTroughDisabledBottom = def.GetSprite(spriteset + "-trough-disabled-bottom");
		}

		m_width = 8;
		LoadWidthHeight(ctx, false);

		m_buttonsSize = ctx.GetInteger("buttons-size", false, 8);
		m_troughOffset = ctx.GetInteger("trough-offset", false, m_buttonsSize);

		m_hideOnFull = ctx.GetBoolean("hide-on-full", false);

		m_handleBorder = ctx.GetInteger("handle-border", false, 1);

		m_canFocus = true;
	}

	bool OnMouseDown(vec2 mousePos) override
	{
		if (mousePos.y > m_troughOffset + m_handleY && mousePos.y < m_troughOffset + m_handleY + m_handleSize)
		{
			vec2 absMousePos = (GetGameModeMousePosition() / g_gameMode.m_wndScale) - m_origin;
			m_overHandle = true;
			m_overHandleY = int(absMousePos.y - m_troughOffset) - m_handleY;
		}

		if (m_buttonUpHover)
			m_buttonUpPressed = true;

		if (m_buttonDownHover)
			m_buttonDownPressed = true;

		return true;
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (m_wContainer is null)
		{
			@m_wContainer = cast<ScrollableWidget>(m_parent.GetWidgetById(m_forId));

			if (m_wContainer is null)
				@m_wContainer = cast<ScrollableWidget>(m_host.m_widget.GetWidgetById(m_forId));

			if (m_wContainer is null)
			{
				PrintError("Couldn't find scrollbar container for id '" + m_forId + "'");
				Widget::DoLayout(origin, parentSz);
				return;
			}
		}

		m_origin.x = m_wContainer.m_origin.x + m_wContainer.m_width + m_offset.x;
		if (!m_outsideContainer)
			m_origin.x -= m_width;

		m_origin.y = (m_wContainer.m_origin.y - m_extraSize / 2) + m_offset.y;

		m_height = m_wContainer.m_height + m_extraSize;
		m_troughSize = m_height - m_troughOffset * 2;

		//Invalidate();
	}

	void Update(int dt) override
	{
		Widget::Update(dt);

		vec2 mousePos = (GetGameModeMousePosition() / g_gameMode.m_wndScale) - m_origin;
		MenuInput@ input = GetMenuInput();

		if (m_wContainer is null)
			return;

		if (IsDisabled())
		{
			m_overHandle = false;
			m_handleSize = m_troughSize;
			m_handleY = 0;
			return;
		}

		float handleSizeFactor = m_troughSize / float(m_wContainer.m_autoScrollHeight);
		if (handleSizeFactor < 0.05)
			handleSizeFactor = 0.05;
		m_handleSize = int(handleSizeFactor * m_troughSize);

		if (input.Forward.Down)
		{
			if (m_overHandle)
			{
				int moveHandleY = int(mousePos.y - m_troughOffset - m_overHandleY);
				if (moveHandleY < 0)
					moveHandleY = 0;
				else if (moveHandleY > m_troughSize - m_handleSize)
					moveHandleY = m_troughSize - m_handleSize;

				float setFactor = moveHandleY / float(m_troughSize - m_handleSize);
				m_wContainer.m_autoScrollValue = int(setFactor * (m_wContainer.m_autoScrollHeight - m_wContainer.m_height));
			}

			int scrollSpeed = 3;
			if (m_buttonUpPressed)
			{
				m_wContainer.m_autoScrollValue -= scrollSpeed;
				m_wContainer.TestAutoscrollLimit();
			}
			else if (m_buttonDownPressed)
			{
				m_wContainer.m_autoScrollValue += scrollSpeed;
				m_wContainer.TestAutoscrollLimit();
			}
		}
		else
		{
			m_overHandle = false;
			m_buttonUpPressed = false;
			m_buttonDownPressed = false;
		}

		float posFactor = m_wContainer.m_autoScrollValue / float(m_wContainer.m_autoScrollHeight - m_wContainer.m_height);
		if (posFactor < 0)
			posFactor = 0;
		else if (posFactor > 1)
			posFactor = 1;

		m_handleY = int(posFactor * (m_troughSize - m_handleSize));

		m_buttonUpHover = (m_hovering && mousePos.y < m_troughOffset);
		m_buttonDownHover = (m_hovering && mousePos.y > m_height - m_troughOffset);
		m_handleHover = (m_overHandle || (m_hovering && mousePos.y > m_troughOffset + m_handleY && mousePos.y < m_troughOffset + m_handleY + m_handleSize));
	}

	bool IsDisabled()
	{
		if (m_wContainer is null)
			return true;
		return m_wContainer.m_autoScrollHeight <= m_wContainer.m_height;
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_wContainer is null)
			return;

		bool disabled = IsDisabled();
		if (m_hideOnFull && disabled)
			return;

		auto tm = g_menuTime;

		// Button up
		if (m_spriteButtonUp !is null)
		{
			if (disabled)
				sb.DrawSprite(pos, m_spriteButtonUpDisabled, tm);
			else if (m_buttonUpPressed)
				sb.DrawSprite(pos, m_spriteButtonUpPressed, tm);
			else if (m_buttonUpHover)
				sb.DrawSprite(pos, m_spriteButtonUpHover, tm);
			else
				sb.DrawSprite(pos, m_spriteButtonUp, tm);
		}
		else
		{
			vec4 colorButtonUp = m_colorButtons;
			if (m_buttonUpHover)
				colorButtonUp = m_colorButtonsHover;
			sb.FillRectangle(vec4(pos.x, pos.y, m_width, m_buttonsSize), colorButtonUp);
		}

		// Button down
		if (m_spriteButtonDown !is null)
		{
			vec2 buttonPos = pos + vec2(0, m_height - m_buttonsSize);
			if (disabled)
				sb.DrawSprite(buttonPos, m_spriteButtonDownDisabled, tm);
			else if (m_buttonDownPressed)
				sb.DrawSprite(buttonPos, m_spriteButtonDownPressed, tm);
			else if (m_buttonDownHover)
				sb.DrawSprite(buttonPos, m_spriteButtonDownHover, tm);
			else
				sb.DrawSprite(buttonPos, m_spriteButtonDown, tm);
		}
		else
		{
			vec4 colorButtonDown = m_colorButtons;
			if (m_buttonDownHover)
				colorButtonDown = m_colorButtonsHover;
			sb.FillRectangle(vec4(pos.x, pos.y + m_height - m_buttonsSize, m_width, m_buttonsSize), colorButtonDown);
		}

		// Trough
		if (m_spriteTroughTop !is null)
		{
			Sprite@ spriteTop = m_spriteTroughTop;
			Sprite@ spriteMiddle = m_spriteTroughMiddle;
			Sprite@ spriteBottom = m_spriteTroughBottom;

			if (disabled)
			{
				@spriteTop = m_spriteTroughDisabledTop;
				@spriteMiddle = m_spriteTroughDisabledMiddle;
				@spriteBottom = m_spriteTroughDisabledBottom;
			}

			int offsetDiff = m_troughOffset - m_buttonsSize;
			sb.DrawSprite(pos + vec2(0, m_buttonsSize), spriteTop, tm);
			sb.DrawSprite(pos + vec2(0, m_buttonsSize + (m_troughSize + offsetDiff * 2) - spriteBottom.GetHeight()), spriteBottom, tm);
			sb.DrawSpriteWrapped(spriteMiddle, g_menuTime,
				pos + vec2(0, m_buttonsSize + spriteTop.GetHeight()),
				vec2(spriteMiddle.GetWidth(), (m_troughSize + offsetDiff * 2) - spriteTop.GetHeight() - spriteBottom.GetHeight())
			);
		}
		else
			sb.FillRectangle(vec4(pos.x, pos.y + m_troughOffset, m_width, m_troughSize), m_colorTrough);

		// Handle
		if (!disabled)
		{
			vec4 handleRect = vec4(pos.x, pos.y + m_troughOffset + m_handleY, m_width, m_handleSize);
			if (m_spriteHandle !is null)
			{
				Texture2D@ texture = m_spriteHandle.GetTexture2D();

				vec4 spriteFrame = m_spriteHandle.GetFrame(tm);
				if (m_overHandle)
					spriteFrame = m_spriteHandlePressed.GetFrame(tm);
				else if (m_handleHover)
					spriteFrame = m_spriteHandleHover.GetFrame(tm);

				int widthDiff = int(handleRect.z - spriteFrame.z);
				handleRect.x += widthDiff / 2;
				handleRect.z -= widthDiff;

				int bh = m_handleBorder;

				sb.DrawSprite(texture, vec4(handleRect.x, handleRect.y, handleRect.z, bh), vec4(spriteFrame.x, spriteFrame.y, spriteFrame.z, bh));
				sb.DrawSprite(texture, handleRect + vec4(0, bh, 0, -bh * 2), spriteFrame + vec4(0, bh, 0, -bh * 2));
				sb.DrawSprite(texture, vec4(handleRect.x, handleRect.y + handleRect.w - bh, handleRect.z, bh), vec4(spriteFrame.x, spriteFrame.y + spriteFrame.w - bh, spriteFrame.z, bh));
			}
			else
			{
				vec4 colorHandle = m_colorHandle;
				if (m_handleHover)
					colorHandle = m_colorHandleHover;
				sb.FillRectangle(handleRect, colorHandle);
			}
		}
	}
}

ref@ LoadScrollbarWidget(WidgetLoadingContext &ctx)
{
	ScrollbarWidget@ w = ScrollbarWidget();
	w.Load(ctx);
	return w;
}
