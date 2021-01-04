namespace Stats
{
	// Usage for regular stats:
	//   Stats::Add("damage-taken", 10, m_record);
	//
	// Usage for average stats:
	//   Stats::Add("avg-items-picked-act-1", 1, m_record);
	//   Stats::AddAvg("avg-items-picked-act-1", m_record);
	//
	// Usage for stats with a max value:
	//   Stats::Max("best-combo", 20, m_record);

	void Add(const string &in name, int value, PlayerRecord@ record = null)
	{
		if (value == 0)
			return;

		if (record !is null)
		{
			record.statistics.Add(name, value);
			record.statisticsSession.Add(name, value);
			
			if (!record.local)
				return;
		}

		Crowd::Trigger(name, value, true);

		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
		{
%if HARDCORE
			gm.m_townLocal.m_statisticsMercenaries.Add(name, value);
%else
			gm.m_townLocal.m_statistics.Add(name, value);
			gm.m_townLocal.CheckForNewTitle();
%endif
		}
	}

	void AddAvg(const string &in name, PlayerRecord@ record = null)
	{
		if (record !is null)
		{
			record.statistics.AddAvg(name);
			record.statisticsSession.AddAvg(name);
			
			if (!record.local)
				return;
		}

		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
		{
			gm.m_townLocal.m_statistics.AddAvg(name);
			gm.m_townLocal.CheckForNewTitle();
		}
	}

	void Max(const string &in name, int value, PlayerRecord@ record = null)
	{
		if (record !is null)
		{
			record.statistics.Max(name, value);
			record.statisticsSession.Max(name, value);
			
			if (!record.local)
				return;
		}

		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
		{
			gm.m_townLocal.m_statistics.Max(name, value);
			gm.m_townLocal.CheckForNewTitle();
		}
	}

	StatList@ LoadList(string filename)
	{
		SValue@ sval = Resources::GetSValue(filename);
		if (sval is null)
		{
			PrintError("Couldn't find statistics list file \"" + filename + "\"");
			return null;
		}

		StatList@ ret = StatList();

		array<SValue@>@ arr = sval.GetArray();
		for (uint i = 0; i < arr.length(); i++)
			ret.AddStat(Stat(arr[i]));

		ret.SortStats();

		return ret;
	}
}
