namespace WorldScript
{
	[WorldScript color="200 150 100" icon="system/icons.png;32;32;32;32"]
	class AddScreenShake
	{
		vec3 Position;

		[Editable default=250]
		int Time;

		[Editable default=5]
		float Amount;

		[Editable default=-1]
		int Range;

		[Editable default=1]
		float DurationFrom;

		[Editable default=0]
		float DurationTo;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			ScreenShake@ shake = gm.ShakeScreen(Time, Amount, Position, float(Range));
			if (shake !is null)
			{
				shake.m_from = DurationFrom;
				shake.m_to = DurationTo;
			}
		}
	}
}
