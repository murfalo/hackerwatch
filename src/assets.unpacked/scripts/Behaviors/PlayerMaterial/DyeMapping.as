namespace Materials
{
	array<DyeMapping@> g_dyeMappings;

	class DyeMapping
	{
		string m_charClass;

		array<Category> m_categories;
		array<string> m_names;

		DyeMapping(string charClass)
		{
			m_charClass = charClass;
		}

		DyeMapping(string charClass, array<SValue@>@ arr)
		{
			m_charClass = charClass;
			for (uint i = 0; i < arr.length(); i++)
			{
				auto arrPair = arr[i].GetArray();
				m_categories.insertLast(GetCategoryValue(arrPair[0].GetString()));
				m_names.insertLast(arrPair[1].GetString());
			}
		}
	}

	DyeMapping@ GetDyeMapping(string charClass)
	{
		for (uint i = 0; i < g_dyeMappings.length(); i++)
		{
			auto mapping = g_dyeMappings[i];
			if (mapping.m_charClass == charClass)
				return mapping;
		}
		return null;
	}

	void LoadDyesMapping(SValue@ svMapping)
	{
		if (svMapping is null)
			return;

		dictionary dicMapping = svMapping.GetDictionary();
		auto keys = dicMapping.getKeys();
		for (uint i = 0; i < keys.length(); i++)
		{
			SValue@ svMap = null;
			dicMapping.get(keys[i], @svMap);

			DyeMapping@ newMapping = DyeMapping(keys[i], svMap.GetArray());
			g_dyeMappings.insertLast(newMapping);
		}
	}
}
