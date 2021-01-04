namespace WorldScript
{
	[WorldScript color="143 188 143" icon="system/icons.png;128;32;32;32"]
	class SetFlag
	{
		[Editable]
		string Flag;
		
		[Editable type=enum default=0]
		FlagState State;
		
		
		SValue@ ServerExecute()
		{
			auto st = State;
			if (st == FlagState::TownAll || st == FlagState::HostTown)
				st = FlagState::Town;
		
			g_flags.Set(Flag, st);
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}