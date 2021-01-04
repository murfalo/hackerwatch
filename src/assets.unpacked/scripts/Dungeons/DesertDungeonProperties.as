class DesertDungeonProperties : DungeonProperties
{
	DesertDungeonProperties(SValue& sv)
	{
		super(sv);
	}

	void OnEndOfGame() override
	{
		auto record = GetLocalPlayerRecord();

		Platform::Service.UnlockAchievement("beat_pop");
%if HARDCORE
		Platform::Service.UnlockAchievement("merc_beat_pop");
%endif

		if (g_ngp >= 1)
			Platform::Service.UnlockAchievement("beat_pop_ng");
		if (g_ngp >= 2)
			Platform::Service.UnlockAchievement("beat_pop_ng2");
		if (g_ngp >= 3)
			Platform::Service.UnlockAchievement("beat_pop_ng3");
		if (g_ngp >= 4)
			Platform::Service.UnlockAchievement("beat_pop_ng4");
		if (g_ngp >= 5)
			Platform::Service.UnlockAchievement("beat_pop_ng5");

		DungeonProperties::OnEndOfGame();
	}
}
