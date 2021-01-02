class DungeonNgpList
{
	array<DungeonNgp@> m_ngps;

	void Load(SValue@ sv, const string &in name, bool withCompatibility = true)
	{
		m_ngps.removeRange(0, m_ngps.length());

		// Load NGPs list
		auto svNgps = sv.GetDictionaryEntry(name);
		if (svNgps !is null)
		{
			auto arr = svNgps.GetArray();
			for (uint i = 0; i < arr.length(); i++)
				m_ngps.insertLast(DungeonNgp(arr[i]));
		}

		// Compatibility
		if (withCompatibility)
		{
			int base_ngp = GetParamInt(UnitPtr(), sv, "new-game-plus", false, -1);
			int desert_ngp = GetParamInt(UnitPtr(), sv, "desert-new-game-plus", false, -1);
			int moon_ngp = GetParamInt(UnitPtr(), sv, "moon-new-game-plus", false, -1);

			if (base_ngp != -1)
				Get("base", true).SetBoth(base_ngp);
			if (desert_ngp != -1)
				Get("pop", true).SetBoth(desert_ngp);
			if (moon_ngp != -1)
				Get("mt", true).SetBoth(moon_ngp);
		}
	}

	void Save(SValueBuilder& builder, const string &in name)
	{
		builder.PushArray(name);
		for (uint i = 0; i < m_ngps.length(); i++)
			m_ngps[i].Save(builder);
		builder.PopArray();
	}

	string BuildCharacterInfoTooltip()
	{
		string ret;
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_ngp <= 0)
				continue;

			auto dungeon = DungeonProperties::Get(ngp.m_id);
			if (dungeon is null)
			{
				PrintError("WARNING: Couldn't find dungeon for NG+ with ID " + ngp.m_id + "!");
				continue;
			}

			if (dungeon.m_strCharInfoNgp == "")
				continue;

			ret += Resources::GetString(dungeon.m_strCharInfoNgp, { { "ngp", int(ngp.m_ngp) } }) + "\n";
		}
		return ret;
	}

	bool Has(const string &in id)
	{
		return Has(HashString(id));
	}

	bool Has(uint id)
	{
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_id == id)
				return true;
		}
		return false;
	}

	DungeonNgp@ Get(const string &in id, bool allowNew = false)
	{
		return Get(HashString(id), allowNew);
	}

	DungeonNgp@ Get(uint id, bool allowNew = false)
	{
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_id == id)
				return ngp;
		}

		if (allowNew)
		{
			auto newNgp = DungeonNgp(id, 0);
			m_ngps.insertLast(newNgp);
			return newNgp;
		}

		return null;
	}

	int GetHighest()
	{
		int ret = 0;
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_ngp > ret)
				ret = ngp.m_ngp;
		}
		return ret;
	}

	int GetHighestPresented()
	{
		int ret = 0;
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_presented > ret)
				ret = ngp.m_presented;
		}
		return ret;
	}

	void SetPresented()
	{
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			ngp.m_presented = ngp.m_ngp;
		}
	}

	int opIndex(const string &in id)
	{
		return opIndex(HashString(id));
	}

	int opIndex(uint id)
	{
		for (uint i = 0; i < m_ngps.length(); i++)
		{
			auto ngp = m_ngps[i];
			if (ngp.m_id == id)
				return ngp.m_ngp;
		}
		return 0;
	}
}
