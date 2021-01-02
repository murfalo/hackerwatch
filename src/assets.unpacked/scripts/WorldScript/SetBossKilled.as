namespace WorldScript
{
	[WorldScript color="200 150 100" icon="system/icons.png;416;384;32;32"]
	class SetBossKilled
	{
		[Editable default=1]
		int BossNumber;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto localPlayer = GetLocalPlayerRecord();

			if (BossNumber == 1)
				Platform::Service.UnlockAchievement("beat_stone_guardian");
			else if (BossNumber == 2)
				Platform::Service.UnlockAchievement("beat_warden");
			else if (BossNumber == 3)
				Platform::Service.UnlockAchievement("beat_three_councilors");
			else if (BossNumber == 4)
				Platform::Service.UnlockAchievement("beat_watcher");
			else if (BossNumber == 5)
				Platform::Service.UnlockAchievement("beat_thundersnow");
			else if (BossNumber == 6)
				Platform::Service.UnlockAchievement("beat_vampire");

			else if (BossNumber == 7)
				Platform::Service.UnlockAchievement("beat_crustworm");
			else if (BossNumber == 8)
				Platform::Service.UnlockAchievement("beat_iris");
			else if (BossNumber == 9)
				Platform::Service.UnlockAchievement("beat_nerys");

			else if (BossNumber == 10)
				Platform::Service.UnlockAchievement("beat_elder_wisp");
			else if (BossNumber == 11)
				Platform::Service.UnlockAchievement("beat_wolf");
			else if (BossNumber == 12)
				Platform::Service.UnlockAchievement("beat_agents");

			auto gm = cast<Campaign>(g_gameMode);
			gm.m_townLocal.m_bossesKilled[BossNumber - 1] |= localPlayer.GetCharFlags();

			int numClasses = 0;
			for (int i = 0; i < 7 + 2 + 3; i++)
			{
				if ((gm.m_townLocal.m_bossesKilled[BossNumber - 1] & (1 << i)) != 0)
					numClasses++;
			}

			Stats::Max("boss-" + BossNumber + "-killed-class", numClasses, localPlayer);
		}
	}
}
