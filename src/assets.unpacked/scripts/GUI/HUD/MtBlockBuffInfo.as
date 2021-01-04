class MtBlockBuffInfo : IBuffWidgetInfo
{
	PlayerBase@ m_player;

	ScriptSprite@ m_icon;

	MtBlockBuffInfo(PlayerBase@ player)
	{
		@m_player = player;

		auto texture = Resources::GetTexture2D("gui/icons_buffs.png");
		@m_icon = ScriptSprite(texture, vec4(36, 60, 12, 12)); //TODO: Change this
	}

	void RefreshIcon()
	{
		auto hud = GetHUD();
		if (hud !is null)
			hud.ShowBuffIcon(m_player, this);
	}

	ScriptSprite@ GetBuffIcon() { return m_icon; }

	int GetBuffIconDuration()
	{
		return max(1, Tweak::MtBlocksCooldown - m_player.m_mtBlocksCooldown);
	}

	int GetBuffIconMaxDuration()
	{
		return Tweak::MtBlocksCooldown;
	}

	int GetBuffIconCount()
	{
		if (m_player.IsDead())
			return 0;

		return m_player.m_record.mtBlocks;
	}
}
