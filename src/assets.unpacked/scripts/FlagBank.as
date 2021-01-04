enum FlagState
{
	Off = 0,
	Level,
	Run,
//	Character,
	Town,
	TownAll,
	HostTown
}

class FlagBank
{
	dictionary m_flags;
	
	
	void Set(const string &in flag, FlagState state)
	{
		if (state == FlagState::Off)
		{
			Delete(flag);
			return;
		}
		
		m_flags.set(flag, state);
	}
	
	void Delete(const string &in flag)
	{
		m_flags.delete(flag);
	}
	
	bool IsSet(const string &in flag)
	{
		return m_flags.exists(flag);
	}
	
	FlagState Get(const string &in flag)
	{
		int64 state;
		if (!m_flags.get(flag, state))
			return FlagState::Off;
	
		return FlagState(state);
	}
}