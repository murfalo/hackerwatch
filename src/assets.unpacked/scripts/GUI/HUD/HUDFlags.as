class HUDFlags
{
	BitmapFont@ m_font;

	HUDFlags()
	{
		@m_font = Resources::GetBitmapFont("system/system.fnt");
	}

	string GetList(string name, FlagState state)
	{
		string text = "\\cff0000" + name + ":\\d\n";
		auto keys = g_flags.m_flags.getKeys();
		for (uint i = 0; i < keys.length(); i++)
		{
			int64 s;
			g_flags.m_flags.get(keys[i], s);
			if (FlagState(s) == state)
				text += " " + keys[i] + "\n";
		}
		return text + "\n";
	}

	void Draw(SpriteBatch& sb, int idt, int type)
	{
		string strFlags = "";
		strFlags += GetList("Level", FlagState::Level);
		strFlags += GetList("Run", FlagState::Run);
		strFlags += GetList("Town", FlagState::Town);
		strFlags += GetList("Town all", FlagState::TownAll);
		strFlags += GetList("Host town", FlagState::HostTown);

		mat4 tform;
		tform *= g_gameMode.m_wndInvScaleTransform;

		BitmapString@ text = null;
		vec2 pos;

		if (type == 2)
		{
			@text = m_font.BuildText(strFlags, -1, TextAlignment::Right);
			pos = vec2((g_gameMode.m_wndWidth * g_gameMode.m_wndScale) - 6 - text.GetWidth(), 16);
		}
		else
		{
			@text = m_font.BuildText(strFlags);
			pos = vec2(6, 16);
		}

		sb.PushTransformation(tform);
		sb.DrawString(pos, text);
		sb.PopTransformation();
	}
}
