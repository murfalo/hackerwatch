class MoonDungeonProperties : DungeonProperties
{
	MoonDungeonProperties(SValue& sv)
	{
		super(sv);
	}

	void OnEndOfGame() override
	{
		auto record = GetLocalPlayerRecord();

		Platform::Service.UnlockAchievement("beat_moon_temple");
%if HARDCORE
		Platform::Service.UnlockAchievement("merc_beat_moon_temple");
%endif

		if (g_ngp >= 1)
			Platform::Service.UnlockAchievement("beat_moon_temple_ng");
		if (g_ngp >= 2)
			Platform::Service.UnlockAchievement("beat_moon_temple_ng2");
		if (g_ngp >= 3)
			Platform::Service.UnlockAchievement("beat_moon_temple_ng3");
		if (g_ngp >= 4)
			Platform::Service.UnlockAchievement("beat_moon_temple_ng4");
		if (g_ngp >= 5)
			Platform::Service.UnlockAchievement("beat_moon_temple_ng5");

		DungeonProperties::OnEndOfGame();
	}

	bool ShouldExploreMinimap() override { return false; }
}
