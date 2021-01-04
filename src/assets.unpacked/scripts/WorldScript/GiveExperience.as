namespace WorldScript
{
	[WorldScript color="220 180 55" icon="system/icons.png;453;2;32;32"]
	class GiveExperience
	{
		[Editable default=10]
		int Amount;

		[Editable default=0]
		float Scalar = 0;

		SValue@ ServerExecute()
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				PlayerRecord@ record = g_players[i];
				int amnt = Amount;
				if (amnt == 0)
				{
					int xpStart = record.LevelExperience(record.level - 1);
					int xpEnd = record.LevelExperience(record.level) - xpStart;
					amnt = int(Scalar * xpEnd);
				}
				record.GiveExperience(amnt);
			}
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
