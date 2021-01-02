namespace Stats
{
	class StatList
	{
		array<Stat@> m_stats;

		string m_id;
		bool m_checkRewards;

		void AddStat(Stat@ stat)
		{
			m_stats.insertLast(stat);
		}

		void InitializeCounters(string id)
		{
			for (uint i = 0; i < m_stats.length(); i++)
			{
				auto stat = m_stats[i];
				if (stat.m_hasCounter)
				{
					stat.m_counterId = "stat_" + stat.m_name.replace("-", "_") + "_" + id;
					stat.m_counterIdHash = HashString(stat.m_counterId);

					if (!CounterExists(stat.m_counterId))
						AddCounterInt(stat.m_counterId, CounterClear::Never);

					stat.UpdateCounter();
				}
			}
		}

		void CombineStatsFrom(StatList@ other)
		{
			for (uint i = 0; i < other.m_stats.length(); i++)
			{
				auto otherStat = other.m_stats[i];

				auto stat = GetStat(otherStat.m_nameHash);
				if (stat is null)
					continue;

				stat.m_valueInt += otherStat.m_valueInt;
				stat.m_valueCount += otherStat.m_valueCount;
			}
		}

		void SortStats()
		{
			m_stats.sortAsc();
		}

		Stat@ GetStat(const string &in name)
		{
			return GetStat(HashString(name));
		}

		Stat@ GetStat(uint hash)
		{
			for (uint i = 0; i < m_stats.length(); i++)
			{
				if (m_stats[i].m_nameHash == hash)
					return m_stats[i];
			}
			return null;
		}

		string GetStatString(const string &in name)
		{
			auto stat = GetStat(name);
			if (stat is null)
				return "???";
			return stat.ToString();
		}

		int GetStatInt(const string &in name, int def = -1)
		{
			auto stat = GetStat(name);
			if (stat is null)
				return def;
			return stat.m_valueInt;
		}

		void Add(const string &in name, int value)
		{
			auto stat = GetStat(name);
			if (stat is null)
			{
				PrintError("Couldn't find statistic \"" + name + "\"");
				return;
			}
			stat.Add(value, m_checkRewards);
		}

		void AddAvg(const string &in name)
		{
			auto stat = GetStat(name);
			if (stat is null)
			{
				PrintError("Couldn't find statistic \"" + name + "\"");
				return;
			}
			stat.AddAvg();
		}

		void Max(const string &in name, int value)
		{
			auto stat = GetStat(name);
			if (stat is null)
			{
				PrintError("Couldn't find statistic \"" + name + "\"");
				return;
			}
			stat.Max(value, m_checkRewards);
		}

		string ToString()
		{
			string ret = "";
			for (uint i = 0; i < m_stats.length(); i++)
			{
				auto stat = m_stats[i];
				ret += stat.m_name + ": " + stat.ToString();
				if (m_checkRewards && stat.m_accomplishments.length() > 0)
					ret += " (" + stat.GetNumRewarded() + " / " + stat.m_accomplishments.length() + " rewards)";
				ret += "\n";
			}
			return ret;
		}

		int GetReputationPoints()
		{
			int ret = 0;
			for (uint i = 0; i < m_stats.length(); i++)
			{
				auto stat = m_stats[i];
				for (uint j = 0; j < stat.m_accomplishments.length(); j++)
				{
					auto accomplishment = stat.m_accomplishments[j];
					if (accomplishment.m_finished)
						ret += accomplishment.m_reputation;
				}
			}
			return ret;
		}

		void Load(SValue@ dictStatistics)
		{
			Clear();

			auto keys = dictStatistics.GetDictionary().getKeys();
			for (uint i = 0; i < keys.length(); i++)
			{
				Stats::Stat@ stat = GetStat(keys[i]);
				if (stat is null)
				{
					PrintError("Tried loading non-existing statistic: \"" + keys[i] + "\"");
					continue;
				}

				SValue@ svStat = dictStatistics.GetDictionaryEntry(keys[i]);
				stat.Load(svStat, m_checkRewards);
			}
		}

		void Save(SValueBuilder& builder)
		{
			for (uint i = 0; i < m_stats.length(); i++)
				m_stats[i].Save(builder);
		}

		void Clear()
		{
			for (uint i = 0; i < m_stats.length(); i++)
				m_stats[i].Clear();
		}
	}
}
