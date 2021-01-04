class MouseBase
{
	GameInput@ m_inputGame;
	MenuInput@ m_inputMenu;

	GameInput@ m_hackSecondGame;
	MenuInput@ m_hackSecondMenu;
	bool m_hackUseSecondary;
	vec2 m_hackPosPrimaryPrev;

	bool m_real;

	vec2 m_pos;
	vec2 m_posPrev;

	int m_colorC = 0;
	vec3 m_color = vec3(1, 1, 1);

	MouseBase(GameInput@ inputGame, MenuInput@ inputMenu)
	{
		@m_inputGame = inputGame;
		@m_inputMenu = inputMenu;

		m_real = inputGame.UsingMouseLook;
	}

	MenuInput@ UsingSecondaryMenuInput()
	{
		if (m_hackUseSecondary)
			return m_hackSecondMenu;
		return null;
	}

	void Update(int dt)
	{
		float width = g_gameMode.m_wndWidth;
		float height = g_gameMode.m_wndHeight;
		float scale = g_gameMode.m_wndScale;

		GameInput@ gi = m_inputGame;
		MenuInput@ mi = m_inputMenu;
		if (m_hackSecondGame !is null)
		{
			if (m_inputGame.MousePos.x != m_hackPosPrimaryPrev.x || m_inputGame.MousePos.y != m_hackPosPrimaryPrev.y)
			{
				m_hackPosPrimaryPrev = m_inputGame.MousePos;
				m_hackUseSecondary = false;
			}
			else if (length(m_hackSecondMenu.MouseMove) > 0)
				m_hackUseSecondary = true;

			if (m_hackUseSecondary)
			{
				@gi = m_hackSecondGame;
				@mi = m_hackSecondMenu;
			}
		}

		m_posPrev = m_pos;
		if (gi.UsingGamepad)
		{
			m_real = false;

			auto map = gi.GetCurrentMap();

			vec2 move = mi.MouseMove;
			if (map !is null && map.SteamController)
			{
				// Absolute movement (Steam controller etc.)
				m_pos += move;
			}
			else
			{
				// Normalized movement (Thumbsticks etc.)
				for (int i = 0; i < 2; i++)
					move *= length(move);
				m_pos += move * GetVarFloat("g_mousemove_speed");
			}

			if (m_pos.x < 0)
				m_pos.x = 0;
			else if (m_pos.x > width * scale)
				m_pos.x = width * scale;

			if (m_pos.y < 0)
				m_pos.y = 0;
			else if (m_pos.y > height * scale)
				m_pos.y = height * scale;
		}
		else
		{
			if (gi.MousePos.x >= 0 && gi.MousePos.y >= 0)
			{
				m_real = true;
				m_pos = gi.MousePos;
			}
			else
			{
				m_real = false;
				m_pos = vec2(width / 2, height / 2) * scale;
			}
		}
	}

	void SetColor(vec4 color)
	{
		m_color = vec3(color.x, color.y, color.z);
	}

	vec2 GetPos(int idt)
	{
		if (m_inputGame.UsingMouseLook && m_real)
			return Platform::GetMousePosition();
		else
			return lerp(m_posPrev, m_pos, idt / 33.0);
	}

	void CenterPos()
	{
		if (m_inputGame.UsingMouseLook && m_real)
			return;

		m_posPrev = m_pos = vec2(
			g_gameMode.m_wndWidth / 2.0f,
			g_gameMode.m_wndHeight / 2.0f
		) * g_gameMode.m_wndScale;
	}

	Platform::CursorInfo@ GetCursor()
	{
		return g_gameMode.m_currCursor;
	}

	void Draw(int idt, SpriteBatch& sb)
	{
		float scale = g_gameMode.m_wndScale;

		Platform::CursorInfo@ cursor = GetCursor();
		if (cursor is null)
			return;

		auto tex = cursor.m_texture;

		vec2 mousePos = GetPos(idt);

		vec4 mousePosScaled = vec4(
			mousePos.x - cursor.m_hotX * scale,
			mousePos.y - cursor.m_hotY * scale, 0, 0) * g_gameMode.m_wndInvScaleTransform;
		mousePosScaled.z = tex.GetWidth();
		mousePosScaled.w = tex.GetHeight();

		auto gm = cast<BaseGameMode>(g_gameMode);

		vec4 color = vec4(1, 1, 1, GetVarFloat("ui_cursor_alpha"));
		if (!gm.m_usingUICursor)
			color = vec4(m_color.x, m_color.y, m_color.z, color.w);

		sb.DrawSprite(tex, mousePosScaled, vec4(0, 0, tex.GetWidth(), tex.GetHeight()), color);
	}

	void DrawTooltip(int idt, SpriteBatch &sb, Tooltip@ tooltip)
	{
		vec2 mousePos = GetPos(idt);
		mousePos /= g_gameMode.m_wndScale;

		tooltip.Draw(sb, mousePos);
	}
}
