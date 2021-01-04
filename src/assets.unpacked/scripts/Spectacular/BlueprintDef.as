namespace Spectacular
{
	array<BlueprintDef@> g_blueprints;

	void LoadBlueprints(SValue@ sval)
	{
		auto arr = sval.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto svDef = arr[i];
			auto newBlueprint = BlueprintDef(svDef);
			g_blueprints.insertLast(newBlueprint);
		}
	}

	BlueprintDef@ GetBlueprint(uint id)
	{
		for (uint i = 0; i < g_blueprints.length(); i++)
		{
			auto blueprint = g_blueprints[i];
			if (blueprint.m_idHash == id)
				return blueprint;
		}
		return null;
	}

	BlueprintDef@ GetBlueprint(const string &in id)
	{
		return GetBlueprint(HashString(id));
	}

	class BlueprintDef
	{
		string m_id;
		uint m_idHash;

		string m_name;
		string m_description;

		array<string> m_flags;

		bool m_unlocked;

		BlueprintDef(SValue@ sval)
		{
			m_id = GetParamString(UnitPtr(), sval, "id");
			m_idHash = HashString(m_id);

			m_name = Resources::GetString(GetParamString(UnitPtr(), sval, "name"));
			m_description = Resources::GetString(GetParamString(UnitPtr(), sval, "description"));

			auto arrFlags = GetParamArray(UnitPtr(), sval, "flags");
			for (uint i = 0; i < arrFlags.length(); i++)
				m_flags.insertLast(arrFlags[i].GetString());

			m_unlocked = GetParamBool(UnitPtr(), sval, "unlocked", false, false);
		}
	}
}
