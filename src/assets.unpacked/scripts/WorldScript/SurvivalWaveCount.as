namespace WorldScript
{
	[WorldScript color="0 196 150" icon="system/icons.png;256;0;32;32"]
	class SurvivalWaveCount
	{
		[Editable]
		int Count;

		SValue@ ServerExecute()
		{
			auto gm = cast<Survival>(g_gameMode);
			gm.m_totalWaveCount = Count;
			gm.UpdateDiscordStatus();
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
