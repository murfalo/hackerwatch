class PlayerWaypoint : Waypoint
{
	UnitPtr m_unit;
	PlayerRecord@ m_player;

	Sprite@ m_spriteHead;
	Sprite@ m_spritePing;

	Sprite@ m_spriteCircle;
	BitmapString@ m_textName;

	float m_fadeNearStart = 300.0f;
	float m_fadeNearEnd = 250.0f;

	PlayerWaypoint(UnitPtr unit, PlayerRecord@ record)
	{
		HUD@ hud = GetHUD();
		if (hud is null)
			return;

		auto spriteHead = hud.m_guiDef.GetSprite("waypoint-player-head");

		super(spriteHead, unit.GetPosition());

		@m_font = Resources::GetBitmapFont("gui/fonts/arial11.fnt");

		@m_spriteHead = spriteHead;
		@m_spritePing = hud.m_guiDef.GetSprite("waypoint-player-ping");

		@m_spriteCircle = hud.m_guiDef.GetSprite("waypoint-player");

		m_unit = unit;
		@m_player = record;

		@m_spriteTexture = m_spriteHead.GetTexture2D();

		MakeNameText();
	}

	void MakeNameText()
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		string playerName = gm.GetPlayerDisplayName(m_player);
		@m_textName = m_font.BuildText(playerName, -1, TextAlignment::Center);
	}

	void Update(int dt) override
	{
		if (m_player.actor !is null && !m_player.IsDead())
		{
			m_unit = m_player.actor.m_unit;
			m_pos = m_unit.GetPosition();

			int x = 0;
			int y = 0;
			string c = m_player.charClass;
			if (c == "paladin") x = 0;
			else if (c == "ranger") x = 14;
			else if (c == "sorcerer") x = 28;
			else if (c == "priest") x = 42;
			else if (c == "wizard") x = 56;
			else if (c == "warlock") x = 70;
			else if (c == "thief") x = 84;
			else if (c == "gladiator") { x = 0; y = 42; }
			else if (c == "witch_hunter") { x = 14; y = 42; }

			m_spriteFrame = vec4(x, y, 14, 14);
		}
		else
			m_spriteFrame = vec4(98, 0, 14, 14);

		if (m_player.pingCount > 0)
		{
			@m_sprite = m_spritePing;
			@m_spriteTexture = null;
		}
		else
			@m_spriteTexture = m_spriteHead.GetTexture2D();

		Waypoint::Update(dt);
	}

	bool ShouldStay() override
	{
		return (m_player.peer != 255);
	}

	vec4 GetColor() override
	{
		float distance = dist(m_fromPos, m_pos);
		float a = 1.0f;

		if (distance < m_fadeNearEnd)
			a = 0.0f;
		else if (distance < m_fadeNearStart)
			a = 1.0f - (distance - m_fadeNearStart) / (m_fadeNearEnd - m_fadeNearStart);

		vec4 ret = vec4(1, 1, 1, 1);

		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm !is null)
			ret = gm.ColorForPlayer(m_player);
		else
			ret = ParseColorRGBA("#" + GetPlayerColor(m_player.peer) + "ff");

		ret.w = a * GetVarFloat("ui_waypoint_player");
		return ret;
	}

	bool ShouldShow(vec2 screenPos) override
	{
		auto mode = cast<BaseGameMode>(g_gameMode);
		if (mode is null)
			return false;

		PlayerBase@ player = cast<PlayerBase>(m_unit.GetScriptBehavior());
		if (player !is null && !mode.ShowOffscreenPlayer(player))
			return false;

		float distance = dist(m_fromPos, m_pos);
		if (m_fadeNearStart > -1)
		{
			if (distance < m_fadeNearEnd)
				return false;
		}
		return true;
	}

	void Draw(SpriteBatch& sb, vec2 pos) override
	{
		vec4 color = GetColor();

		sb.DrawSprite(pos - vec2(m_spriteCircle.GetWidth() / 2, m_spriteCircle.GetHeight() / 2), m_spriteCircle, g_menuTime, color);

		if (m_textName !is null)
		{
			m_textName.SetColor(color);
			sb.DrawString(pos + vec2(-(m_textName.GetWidth() / 2), -(m_sprite.GetHeight() / 2) - m_textName.GetHeight() - 2), m_textName);
		}

		Waypoint::Draw(sb, pos);
	}
}
