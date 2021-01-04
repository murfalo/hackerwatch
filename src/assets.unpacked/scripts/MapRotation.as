class MapRotation
{
	array<string> m_levels;
	int m_currentLevel;

	MapRotation(string fnm)
	{
		m_currentLevel = -1;
	
		SValue@ sv = Resources::GetSValue(fnm);
		if (sv is null)
			return;

		string currentLevel = GetCurrentLevelFilename();
		auto arr = sv.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto map = arr[i].GetString();
			if (currentLevel == map)
				m_currentLevel = i;
				
			m_levels.insertLast(map);
		}
	}

	MapRotation(SValue@ sv)
	{
		string currentLevel = GetCurrentLevelFilename();
		auto arr = sv.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto map = arr[i].GetString();
			if (currentLevel == map)
				m_currentLevel = i;
			m_levels.insertLast(map);
		}
	}

	void Write(SValueBuilder& builder, string name)
	{
		builder.PushArray(name);
		for (uint i = 0; i < m_levels.length(); i++)
			builder.PushString(m_levels[i]);
		builder.PopArray();
	}

	string GetNextMap()
	{
		if (m_levels.length() == 0)
			return "";
		if (m_levels.length() == 1)
			return m_levels[0];

		int nextMap = randi(m_levels.length());
		if (m_currentLevel > -1)
			nextMap = (m_currentLevel + 1) % m_levels.length();
		
//		while (nextMap == m_currentLevel)
//			nextMap = randi(m_levels.length());

		return m_levels[nextMap];
	}
}
