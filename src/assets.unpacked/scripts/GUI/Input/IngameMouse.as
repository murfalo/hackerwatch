class IngameMouse : MouseBase
{
	IngameMouse(GameInput@ inputGame, MenuInput@ inputMenu)
	{
		super(inputGame, inputMenu);
	}

	void Update(int dt) override
	{
		MouseBase::Update(dt);

		auto player = GetLocalPlayerRecord();
		if (player is null || player.IsDead() || player.actor is null)
		{
			m_color = vec3(1, 1, 1);
			return;
		}

		m_colorC -= dt;
		if (m_colorC <= 0)
		{
			m_colorC = 60;
			UpdateMouseColor();
		}
	}

	void UpdateMouseColor()
	{
		auto player = GetLocalPlayerRecord();

		vec3 mousePos = ToWorldspace(m_inputGame.MousePos);
		auto arrUnits = g_scene.QueryCircle(xy(mousePos), 12, ~0, RaycastType::Any, true);

		bool anyActor = false;
		float lowestHp = 1;
		for (uint i = 0; i < arrUnits.length(); i++)
		{
			auto unit = arrUnits[i];

			auto actor = cast<Actor>(unit.GetScriptBehavior());
			if (actor !is null && actor !is player.actor && actor.m_crosshairColors)
			{
				float hp = actor.GetHealth();
				lowestHp = min(hp, lowestHp);
				anyActor = true;
			}
		}

		Player@ localPlayer = cast<Player>(player.actor);

		vec2 playerPos = xy(player.actor.m_unit.GetPosition());
		playerPos.y -= Tweak::PlayerCameraHeight;
		vec2 dir = m_inputGame.AimDir;

		if (localPlayer.m_buffs.Confuse() && !localPlayer.m_buffs.AntiConfuse())
			dir *= -1;

		auto gm = cast<BaseGameMode>(g_gameMode);

		if (anyActor)
		{
			if (lowestHp < 0.33)
				m_color = vec3(1, 0, 0);
			else if (lowestHp < 0.66)
				m_color = vec3(1, 1, 0);
			else
				m_color = vec3(0, 1, 0);
		}
		else
			m_color = vec3(1, 1, 1);
	}

	void Draw(int idt, SpriteBatch& sb) override
	{
		MouseBase::Draw(idt, sb);

		auto gm = cast<BaseGameMode>(g_gameMode);
		if (!gm.m_usingUICursor && GetVarBool("ui_cursor_health"))
		{
			Platform::CursorInfo@ cursor = GetCursor();
			if (cursor is null)
				return;

			float alpha = GetVarFloat("ui_cursor_health_alpha") * GetVarFloat("ui_cursor_alpha");

			auto font = Resources::GetBitmapFont("gui/fonts/font_hw8.fnt");

			auto record = GetLocalPlayerRecord();
			if (record.IsDead())
				return;

			auto textHealth = font.BuildText("" + record.CurrentHealth());
			textHealth.SetColor(vec4(1, 0, 0, alpha));

			auto textMana = font.BuildText("" + record.CurrentMana());
			textMana.SetColor(vec4(0, 1, 1, alpha));

			vec2 mousePos = GetPos(idt);
			mousePos /= g_gameMode.m_wndScale;
			mousePos.x = int(mousePos.x);
			mousePos.y = int(mousePos.y);

			sb.DrawString(mousePos + vec2(
				-(textHealth.GetWidth() / 2),
				-(cursor.m_texture.GetHeight() / 2)
			), textHealth);

			sb.DrawString(mousePos + vec2(
				-(textMana.GetWidth() / 2),
				(cursor.m_texture.GetHeight() / 2) - 6
			), textMana);
		}
	}
}
