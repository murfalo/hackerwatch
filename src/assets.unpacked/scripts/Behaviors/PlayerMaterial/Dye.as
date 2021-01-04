namespace Materials
{
	array<Dye@> g_dyes;

	class Dye
	{
		Category m_category;
		string m_id;
		uint m_idHash;

		string m_name;

		ActorItemQuality m_quality;
		bool m_default;
		string m_dlc;

		int m_legacyPoints;

		Dye(SValue@ sval)
		{
			m_id = GetParamString(UnitPtr(), sval, "id");
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), sval, "name", false, "???");

			m_quality = ParseActorItemQuality(GetParamString(UnitPtr(), sval, "quality"));
			m_default = GetParamBool(UnitPtr(), sval, "default", false);
			m_dlc = GetParamString(UnitPtr(), sval, "dlc", false);

			m_legacyPoints = GetParamInt(UnitPtr(), sval, "legacy-points", false);
		}

		IDyeState@ MakeDyeState(PlayerRecord@ record = null)
		{
			return null;
		}
	}

	int GetDyeCount(Category category)
	{
		int ret = 0;
		for (uint i = 0; i < g_dyes.length(); i++)
		{
			if (g_dyes[i].m_category == category)
				ret++;
		}
		return ret;
	}

	Dye@ GetDye(string category, string id)
	{
		return GetDye(GetCategoryValue(category), HashString(id));
	}

	Dye@ GetDye(string category, uint id)
	{
		return GetDye(GetCategoryValue(category), id);
	}

	Dye@ GetDye(Category category, uint id)
	{
		for (uint i = 0; i < g_dyes.length(); i++)
		{
			Dye@ dye = g_dyes[i];
			if (dye.m_category != category)
				continue;

			if (dye.m_idHash == id)
				return dye;
		}

		//TODO: This should be temporary
		PrintError("Can't find dye with category " + int(category) + " and ID " + id + ", returning random dye instead");
		return GetRandomDye(category);
	}

	Dye@ GetRandomDye(Category category)
	{
		array<Dye@> possibleDyes;
		for (uint i = 0; i < g_dyes.length(); i++)
		{
			auto dye = g_dyes[i];
			if (dye.m_category != category)
				continue;

			if (!dye.m_default)
				continue;

			possibleDyes.insertLast(dye);
		}

		if (possibleDyes.length() == 0)
			return null;

		return possibleDyes[randi(possibleDyes.length())];
	}

	array<Dye@> DyesFromSval(SValue@ sval)
	{
		array<Dye@> ret;
		if (sval is null)
			return ret;

		string charClass = GetParamString(UnitPtr(), sval, "class");

		auto arrColors = GetParamArray(UnitPtr(), sval, "colors", false);
		if (arrColors !is null)
		{
			for (uint i = 0; i < arrColors.length(); i++)
			{
				auto arrCol = arrColors[i].GetArray();
				int category = arrCol[0].GetInteger();
				uint id = uint(arrCol[1].GetInteger());
				auto dye = GetDye(Category(category), id);
				if (dye is null)
				{
					PrintError("Couldn't find dye with category " + category + " with ID " + id);
					continue;
				}
				ret.insertLast(dye);
			}
		}
		else
		{
			auto mapping = GetDyeMapping(charClass);
			if (mapping is null)
				return ret;

			for (uint i = 0; i < mapping.m_categories.length(); i++)
			{
				Category category = mapping.m_categories[i];
				ret.insertLast(GetRandomDye(category));
			}
		}

		return ret;
	}

	void LoadDyesCategory(string category, array<SValue@>@ arr)
	{
		if (arr is null)
			return;

		for (uint i = 0; i < arr.length(); i++)
		{
			SValue@ svDye = arr[i];
			string className = GetParamString(UnitPtr(), svDye, "class", false, "Materials::DyeColor");

			auto newDye = cast<Dye>(InstantiateClass(className, svDye));
			if (newDye is null)
			{
				PrintError("Unable to instantiate player material dye of type \"" + className + "\"!");
				continue;
			}

			newDye.m_category = GetCategoryValue(category);
			g_dyes.insertLast(newDye);
		}
	}

	void LoadDyes(SValue@ sval)
	{
		LoadDyesMapping(GetParamDictionary(UnitPtr(), sval, "mapping", false));

		LoadDyesCategory("skin", GetParamArray(UnitPtr(), sval, "skin", false));
		LoadDyesCategory("hair", GetParamArray(UnitPtr(), sval, "hair", false));
		LoadDyesCategory("cloth", GetParamArray(UnitPtr(), sval, "cloth", false));
		LoadDyesCategory("metal", GetParamArray(UnitPtr(), sval, "metal", false));
		LoadDyesCategory("leather", GetParamArray(UnitPtr(), sval, "leather", false));
		LoadDyesCategory("wood", GetParamArray(UnitPtr(), sval, "wood", false));
	}
}
