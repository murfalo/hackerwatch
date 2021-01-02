class OverheadBossBar
{
	Actor@ m_actor;

	float m_checkpoint = -1;

	int m_barCount;
	int m_barOffset;
	PlayerRecord@ m_playerOwner;

	void Set(Actor@ actor, int barCount, int barOffset)
	{
		@m_actor = actor;
		m_barCount = barCount;
		m_barOffset = barOffset;
	}

	bool Draw(SpriteBatch& sb, int idt)
	{
		Actor@ a = m_actor;
		if (!a.m_unit.IsValid() || a.IsDead())
			return false;

		int barWidthPixels = m_barCount;
		int barHeight = 4;

		vec2 pos = ToScreenspace(a.m_unit.GetInterpolatedPosition(idt)) / g_gameMode.m_wndScale;
		pos += vec2(-(barWidthPixels) / 2, m_barOffset);

		float hp = a.GetHealth();

		vec4 baseRect = vec4(pos.x, pos.y, barWidthPixels, barHeight);

		if (m_playerOwner !is null)
		{
			vec4 barPlayerColor = ParseColorRGBA("#" + GetPlayerColor(m_playerOwner.peer) + "ff");
			vec4 barPlayerColorRect = (baseRect + vec4(0, 0, 1, 1));
			sb.FillRectangle(barPlayerColorRect, barPlayerColor * 0.75);

			vec4 barBackgroundRect = (baseRect + vec4(1, 1, -1, -1));
			sb.FillRectangle(barBackgroundRect, vec4(0, 0, 0, 1));

			vec4 barMinionHealthRect = (barBackgroundRect + vec4(1, 1, -2, -2));
			barMinionHealthRect.z *= hp;

			vec4 colorBar = lerp(vec4(0.25, 0, 0, 1), vec4(1, 0, 0, 1), hp);
			sb.FillRectangle(barMinionHealthRect, colorBar);

			return true;
		}

		vec4 barHealthRect = (baseRect + vec4(1, 1, -2, -2));
		barHealthRect.z *= hp;

		sb.FillRectangle(baseRect, vec4(0, 0, 0, 1));
		vec4 colorBar = lerp(vec4(1, 0, 0, 1), vec4(0, 1, 0, 1), hp);
		sb.FillRectangle(barHealthRect, colorBar);

		return true;
	}
}
