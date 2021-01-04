namespace WorldScript
{
	[WorldScript color="0 196 150" icon="system/icons.png;256;0;32;32"]
	class SurvivalShrine
	{
		[Editable]
		int Time;

		SValue@ ServerExecute()
		{
			auto gm = cast<Survival>(g_gameMode);
			gm.m_hudSurvival.SetShrine(Time);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
