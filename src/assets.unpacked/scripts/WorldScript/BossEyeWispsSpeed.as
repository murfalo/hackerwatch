namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;96;32;32;32"]
	class BossEyeWispsSpeed
	{
		[Editable validation=IsBossEye]
		UnitFeed Boss;

		[Editable]
		float NewMultiplier;

		[Editable]
		int OverTime;

		bool IsBossEye(UnitPtr unit)
		{
			return cast<BossEye>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			array<UnitPtr>@ arr = Boss.FetchAll();
			for (uint i = 0; i < arr.length(); i++)
			{
				auto boss = cast<BossEye>(arr[i].GetScriptBehavior());
				if (boss is null)
					continue;

				for (uint j = 0; j < boss.m_wisps.length(); j++)
					boss.m_wisps[j].SetRotateSpeedTarget(NewMultiplier, OverTime);
			}

			return null;
		}

		void ClientExecute(SValue@ param)
		{
			ServerExecute();
		}
	}
}
