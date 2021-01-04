class BaseDungeonProperties : DungeonProperties
{
	BaseDungeonProperties(SValue& sv)
	{
		super(sv);
	}

	void OnEndOfGame() override
	{
		auto record = GetLocalPlayerRecord();

		Platform::Service.UnlockAchievement("beat_forsaken_tower");
%if HARDCORE
		Platform::Service.UnlockAchievement("merc_beat_forsaken_tower");
%endif

		if (g_ngp >= 1)
			Platform::Service.UnlockAchievement("beat_forsaken_tower_ng");
		if (g_ngp >= 2)
			Platform::Service.UnlockAchievement("beat_forsaken_tower_ng2");
		if (g_ngp >= 3)
			Platform::Service.UnlockAchievement("beat_forsaken_tower_ng3");
		if (g_ngp >= 4)
			Platform::Service.UnlockAchievement("beat_forsaken_tower_ng4");
		if (g_ngp >= 5)
			Platform::Service.UnlockAchievement("beat_forsaken_tower_ng5");

		auto ngp = record.ngps.Get(m_idHash, true);
		bool newTitle = (ngp.m_ngp <= int(float(g_ngp)));

		DungeonProperties::OnEndOfGame();

		if (newTitle)
		{
%if !HARDCORE
			record.titleIndex = ngp.m_ngp + 5;
%endif
			record.shortcut = 0;
		}
	}
}
