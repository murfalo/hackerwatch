class Waypoint
{
	Sprite@ m_sprite;

	Texture2D@ m_spriteTexture;
	vec4 m_spriteFrame;

	vec3 m_pos;
	vec3 m_fromPos;

	vec4 m_colorText;

	BitmapFont@ m_font;
	BitmapString@ m_text;
	int m_lastDistance = -1;

	Waypoint(Sprite@ sprite, vec3 pos)
	{
		@m_sprite = sprite;
		m_pos = pos;
	}

	void Update(int dt)
	{
		if (m_font !is null)
		{
			int distance = int(dist(m_pos, m_fromPos));
			if (distance == m_lastDistance && m_text !is null)
				return;

			@m_text = m_font.BuildText(int(distance / 16) + "m");
			m_text.SetColor(GetColor());
			m_lastDistance = distance;
		}
	}

	bool ShouldStay()
	{
		return true;
	}

	bool ShouldShow(vec2 screenPos)
	{
		return (screenPos.x < 0 || screenPos.x > g_gameMode.m_wndWidth || screenPos.y < 0 || screenPos.y > g_gameMode.m_wndHeight);
	}

	vec4 GetColor()
	{
		return vec4(1, 1, 1, 1);
	}

	vec2 GetScreenPosition(vec2 pos)
	{
		vec2 centerPos = vec2(g_gameMode.m_wndWidth / 2.0, g_gameMode.m_wndHeight / 2.0);
		float arrowDistance = min(g_gameMode.m_wndWidth, g_gameMode.m_wndHeight) * 0.4;
		vec2 dir = normalize(pos - centerPos) * Tweak::WaypointShape;
		vec2 ret = centerPos + dir * arrowDistance;
		ret.x = int(ret.x);
		ret.y = int(ret.y);
		return ret;
	}

	void Draw(SpriteBatch& sb, vec2 pos)
	{
		//pos.x = int(pos.x);
		//pos.y = int(pos.y);

		if (m_spriteTexture !is null)
		{
			int width = int(m_spriteFrame.z);
			int height = int(m_spriteFrame.w);
			vec4 dst = vec4(pos.x - width / 2, pos.y - height / 2, width, height);
			sb.DrawSprite(m_spriteTexture, dst, m_spriteFrame, vec4(1, 1, 1, GetColor().a));
		}
		else
			sb.DrawSprite(pos - vec2(m_sprite.GetWidth() / 2, m_sprite.GetHeight() / 2), m_sprite, g_menuTime, vec4(1, 1, 1, GetColor().a));

		DrawText(sb, pos);
	}

	void DrawText(SpriteBatch& sb, vec2 pos)
	{
		if (m_text is null)
			return;

		pos.x = int(pos.x);
		pos.y = int(pos.y);

		sb.DrawString(pos + vec2(-(m_text.GetWidth() / 2), m_sprite.GetHeight() / 2 + 3), m_text);
	}
}
