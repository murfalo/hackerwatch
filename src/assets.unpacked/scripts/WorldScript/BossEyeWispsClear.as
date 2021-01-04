namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;96;32;32;32"]
	class BossEyeWispsClear
	{
		[Editable validation=IsBossEye]
		UnitFeed Boss;

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
				if (boss !is null)
					boss.ClearWisps();
			}

			return null;
		}

		void ClientExecute(SValue@ param)
		{
			ServerExecute();
		}
	}
}
