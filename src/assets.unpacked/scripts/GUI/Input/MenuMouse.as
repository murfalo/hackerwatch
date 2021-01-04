class MenuMouse : MouseBase
{
	BitmapString@ m_text;

	bool m_splitscreen;
	ControlMap@ m_singularMap;

	vec2 m_lastPosMove;
	int m_tmSinceMove;

	MenuMouse(GameInput@ inputGame, MenuInput@ inputMenu, bool splitscreen)
	{
		super(inputGame, inputMenu);

		m_splitscreen = splitscreen;
		if (m_splitscreen)
		{
			array<ControlMap@>@ maps = inputGame.GetControlMaps();
			if (maps.length() == 1)
			{
				@m_singularMap = maps[0];
				SetText(Resources::GetString(".menu.controls.layout." + m_singularMap.ID));
			}
		}
	}

	Platform::CursorInfo@ GetCursor() override
	{
		if (m_splitscreen)
			return Platform::CursorColorable;
		else
			return g_gameMode.m_currCursor;
	}

	void SetText(string str)
	{
		auto font = Resources::GetBitmapFont("gui/fonts/font_hw8.fnt");
		if (font !is null)
			@m_text = font.BuildText(str);
	}

	void Update(int dt) override
	{
		vec2 mousePos = GetPos(0);
		if (distsq(mousePos, m_lastPosMove) > 0)
			m_tmSinceMove = 0;
		else
			m_tmSinceMove += dt;
		m_lastPosMove = mousePos;

		MouseBase::Update(dt);
	}

	bool ShouldRenderName()
	{
		auto gm = cast<MainMenu>(g_gameMode);
		return (gm !is null && gm.m_mice.length() > 1);
	}

	void Draw(int idt, SpriteBatch& sb) override
	{
		MouseBase::Draw(idt, sb);

		if (m_text is null)
			return;

		Platform::CursorInfo@ cursor = GetCursor();
		if (cursor is null)
			return;

		vec2 pos = GetPos(idt) / g_gameMode.m_wndScale;
		pos.x += (cursor.m_texture.GetWidth() - 10) / 2 - m_text.GetWidth() / 2;
		pos.y += 28;
		sb.DrawString(pos, m_text);
	}
}
