class CurseBuffInfo : IBuffWidgetInfo
{
	PlayerBase@ m_player;

	ScriptSprite@ m_icon;

	CurseBuffInfo(PlayerBase@ player)
	{
		@m_player = player;

		auto texture = Resources::GetTexture2D("gui/icons_buffs.png");
		@m_icon = ScriptSprite(texture, vec4(0, 36, 12, 12));
	}

	void RefreshIcon()
	{
		auto hud = GetHUD();
		if (hud !is null)
			hud.ShowBuffIcon(m_player, this);
	}

	ScriptSprite@ GetBuffIcon() { return m_icon; }
	int GetBuffIconDuration() { return 1; }
	int GetBuffIconMaxDuration() { return 1; }
	int GetBuffIconCount()
	{
		if (m_player.IsDead())
			return 0;

		auto localPlr = cast<Player>(m_player);
		if (localPlr !is null)
			return localPlr.m_cachedCurses;

		return m_player.m_record.curses;
	}
}
