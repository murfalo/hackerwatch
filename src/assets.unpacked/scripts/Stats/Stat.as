namespace Stats
{
	enum StatType
	{
		Number,
		Average
	}

	enum StatDisplay
	{
		None,
		Number,
		Time,
		Distance
	}

	enum StatScope
	{
		Town,
		Character,
		Global
	}

	class Stat
	{
		string m_name;
		string m_category;
		uint m_nameHash;

		string m_dlc;

		bool m_town;
		bool m_survival;

		StatType m_type;
		StatDisplay m_display;
		StatDisplay m_displayGuildhall;
		StatScope m_scope;

		bool m_hasCounter;
		string m_counterId;
		uint m_counterIdHash;

		array<Accomplishment@> m_accomplishments;

		pint64 m_valueInt;
		pint64 m_valueCount;

		string m_achievement;
		int64 m_achievementLimit;

		Stat(SValue@ params)
		{
			m_name = GetParamString(UnitPtr(), params, "name");
			m_category = GetParamString(UnitPtr(), params, "category", false, "");
			m_nameHash = HashString(m_name);

			m_dlc = GetParamString(UnitPtr(), params, "dlc", false);

			m_town = GetParamBool(UnitPtr(), params, "town", false);
			m_survival = GetParamBool(UnitPtr(), params, "survival", false, true);

			string statTypeString = GetParamString(UnitPtr(), params, "type", false, "number");
			     if (statTypeString == "number") m_type = StatType::Number;
			else if (statTypeString == "average") m_type = StatType::Average;
			else PrintError("Unknown stat type \"" + statTypeString + "\"");

			string statDisplayString = GetParamString(UnitPtr(), params, "display", false, "number");
			m_display = GetStatDisplay(statDisplayString);

			string statDisplayGuildhallString = GetParamString(UnitPtr(), params, "display-guildhall", false, statDisplayString);
			m_displayGuildhall = GetStatDisplay(statDisplayGuildhallString);

			string statScopeString = GetParamString(UnitPtr(), params, "scope", false, "global");
			     if (statScopeString == "town") m_scope = StatScope::Town;
			else if (statScopeString == "character") m_scope = StatScope::Character;
			else if (statScopeString == "global") m_scope = StatScope::Global;

			m_hasCounter = GetParamBool(UnitPtr(), params, "has-counter", false, true);

			auto arrAccomplishments =  GetParamArray(UnitPtr(), params, "rewards", false);
			if (arrAccomplishments !is null)
			{
				for (uint i = 0; i < arrAccomplishments.length(); i++)
					m_accomplishments.insertLast(Accomplishment(this, arrAccomplishments[i], i + 1));
			}

			m_achievement = GetParamString(UnitPtr(), params, "achievement", false);
			m_achievementLimit = GetParamInt(UnitPtr(), params, "achievement-limit", false, 0);
		}

		StatDisplay GetStatDisplay(const string &in str)
		{
			if (m_dlc != "" && !Platform::HasDLC(m_dlc))
				return StatDisplay::None;

			if (str == "none") return StatDisplay::None;
			else if (str == "number") return StatDisplay::Number;
			else if (str == "time") return StatDisplay::Time;
			else if (str == "distance") return StatDisplay::Distance;
			else PrintError("Unknown stat display type \"" + str + "\"");
			return StatDisplay::None;
		}

		int opCmp(const Stat &in other) const
		{
			return m_category.opCmp(other.m_category);
		}

		string ToString(bool guildhall = false)
		{
			return ToString(m_valueInt, guildhall);
		}

		string ToString(int64 value, bool guildhall = false)
		{
			if (guildhall)
				return ToString(value, m_displayGuildhall);
			else
				return ToString(value, m_display);
		}

		string ToString(int64 value, StatDisplay display)
		{
			if (display == StatDisplay::None)
				return "";

			if (m_type == StatType::Average)
			{
				value /= m_valueCount;

				// Special case: If avg result is < 100 and it's a regular number,
				// we can show the average as a float
				if (value < 100 && display == StatDisplay::Number)
					return "" + roundl(double(m_valueInt) / double(m_valueCount), 2);
			}

			if (display == StatDisplay::Distance)
				return formatMeters(value);

			switch (display)
			{
				case StatDisplay::Number: return "" + formatThousands(value);
				case StatDisplay::Time: return formatTime(value, false, true);
			}

			return "" + value;
		}

		int64 ValueInt()
		{
			return m_valueInt;
		}

		void Add(int64 value, bool checkAwards)
		{
			if (g_isTown && !m_town)
				return;

			if (g_isSurvival && !m_survival)
				return;

			m_valueInt += value;

			if (checkAwards)
			{
				for (uint i = 0; i < m_accomplishments.length(); i++)
					m_accomplishments[i].OnUpdated();
					
				if (m_achievementLimit > 0 && m_valueInt >= m_achievementLimit)
				{
					Platform::Service.UnlockAchievement(m_achievement);
					m_achievementLimit = 0;
				}
			}

			UpdateCounter();
		}

		void AddAvg()
		{
			if (g_isTown && !m_town)
				return;

			if (g_isSurvival && !m_survival)
				return;

			if (m_type != StatType::Average)
			{
				PrintError("Tried adding average count to non-average stat \"" + m_name + "\"!");
				return;
			}
			m_valueCount++;

			UpdateCounter();
		}

		void Max(int value, bool checkAwards)
		{
			if (g_isTown && !m_town)
				return;

			if (value <= m_valueInt)
				return;
			m_valueInt = value;

			if (checkAwards)
			{
				for (uint i = 0; i < m_accomplishments.length(); i++)
					m_accomplishments[i].OnUpdated();
					
				if (m_achievementLimit > 0 && m_valueInt >= m_achievementLimit)
				{
					Platform::Service.UnlockAchievement(m_achievement);
					m_achievementLimit = 0;
				}
			}

			UpdateCounter();
		}

		int GetNumRewarded()
		{
			int ret = 0;
			for (uint i = 0; i < m_accomplishments.length(); i++)
			{
				if (m_accomplishments[i].m_finished)
					ret++;
			}
			return ret;
		}

		void UpdateCounter()
		{
			if (m_counterIdHash == 0)
				return;

			SetCounter(m_counterIdHash, m_valueInt);
		}

		void Load(SValue@ svStat, bool checkAwards)
		{
			if (m_type == StatType::Number)
			{
				if (svStat.GetType() == SValueType::Integer)
				{
					m_valueInt = int64(svStat.GetInteger());
					if (m_valueInt < 0)
						m_valueInt += uint(-1);
				}
				else
					m_valueInt = svStat.GetLong();
			}
			else if (m_type == StatType::Average && svStat.GetType() == SValueType::Array)
			{
				auto arr = svStat.GetArray();
				if (arr[0].GetType() == SValueType::Integer)
				{
					m_valueInt = int64(arr[0].GetInteger());
					m_valueCount = int64(arr[1].GetInteger());
				}
				else
				{
					m_valueInt = arr[0].GetLong();
					m_valueCount = arr[1].GetLong();
				}
			}

			for (uint i = 0; i < m_accomplishments.length(); i++)
			{
				auto reward = m_accomplishments[i];
				if (reward.IsValueGood(m_valueInt))
				{
					reward.m_finished = true;
					reward.OnLoadFinished();
				}
			}

			if (checkAwards)
			{
				if (m_achievementLimit > 0 && m_valueInt >= m_achievementLimit)
				{
					Platform::Service.UnlockAchievement(m_achievement);
					m_achievementLimit = 0;
				}
			}

			UpdateCounter();
		}

		void Save(SValueBuilder& builder)
		{
			if (m_type == StatType::Number)
				builder.PushLong(m_name, m_valueInt);
			else if (m_type == StatType::Average)
			{
				builder.PushArray(m_name);
				builder.PushLong(m_valueInt);
				builder.PushLong(m_valueCount);
				builder.PopArray();
			}
		}

		void Clear()
		{
			m_valueInt = 0;
			m_valueCount = 0;

			UpdateCounter();
		}
	}
}
