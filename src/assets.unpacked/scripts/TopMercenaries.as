namespace TopMercenaries
{
	class Item
	{
		int m_index;
		SValue@ m_charData;
		int m_pointsReward;

		int opCmp(const Item& in other)
		{
			if (other.m_pointsReward > m_pointsReward) return -1;
			else if (other.m_pointsReward < m_pointsReward) return 1;
			else return 0;
		}
	}

	array<Item@> Get(bool locked = true)
	{
		array<Item@> ret;

		auto allChars = HwrSaves::GetCharacters();
		for (uint i = 0; i < allChars.length(); i++)
		{
			auto svChar = allChars[i];

			bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
			if (!mercenary)
				continue;

			bool mercenaryLocked = GetParamBool(UnitPtr(), svChar, "mercenary-locked", false);
			if (locked != mercenaryLocked)
				continue;

			int pointsReward = GetParamInt(UnitPtr(), svChar, "mercenary-points-reward", false);

			auto newItem = Item();
			newItem.m_index = i;
			@newItem.m_charData = svChar;
			newItem.m_pointsReward = pointsReward;
			ret.insertLast(newItem);
		}

		ret.sortDesc();
		return ret;
	}

	array<int> TitleCounts()
	{
		array<int> ret;

		auto titleList = g_classTitles.m_titlesMercenary;

		for (uint i = 0; i < titleList.m_titles.length(); i++)
			ret.insertLast(0);

		auto allChars = HwrSaves::GetCharacters();
		for (uint i = 0; i < allChars.length(); i++)
		{
			auto svChar = allChars[i];

			bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
			if (!mercenary)
				continue;

			int legacyPointsWorth = GetParamInt(UnitPtr(), svChar, "mercenary-points-reward", false);
			int titleIndex = titleList.GetTitleIndexFromPoints(legacyPointsWorth);

			ret[titleIndex]++;
		}

		return ret;
	}
}
