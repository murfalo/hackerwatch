class HardcoreSkill
{
	string m_id;
	uint m_idHash;

	string m_charClass;
	bool m_default;

	string m_name;
	string m_description;

	int m_cost;
	ScriptSprite@ m_icon;

	bool m_passive;

	SValue@ m_data;

	HardcoreSkill(SValue@ sv, const string &in id)
	{
		m_id = id;
		m_idHash = HashString(m_id);

		m_charClass = GetParamString(UnitPtr(), sv, "charclass", false);
		m_default = GetParamBool(UnitPtr(), sv, "default", false);

		m_name = GetParamString(UnitPtr(), sv, "name");
		m_description = GetParamString(UnitPtr(), sv, "description", false);

		m_cost = GetParamInt(UnitPtr(), sv, "cost");
		@m_icon = ScriptSprite(GetParamArray(UnitPtr(), sv, "icon", false));

		@m_data = sv.GetDictionaryEntry("skill");

		m_passive = true; // Passive until proven active

		string strClassName = GetParamString(UnitPtr(), m_data, "class");
		auto typeInfo = Reflect::GetType(strClassName);
		while (typeInfo !is null)
		{
			if (typeInfo.GetName() == "ActiveSkill")
			{
				m_passive = false;
				break;
			}
			@typeInfo = typeInfo.GetBaseType();
		}
	}
}

array<HardcoreSkill@> g_hardcoreSkills;

HardcoreSkill@ GetHardcoreSkill(const string &in id)
{
	return GetHardcoreSkill(HashString(id));
}

HardcoreSkill@ GetHardcoreSkill(uint idHash)
{
	for (uint i = 0; i < g_hardcoreSkills.length(); i++)
	{
		auto skill = g_hardcoreSkills[i];
		if (skill.m_idHash == idHash)
			return skill;
	}
	return null;
}

void LoadHardcoreSkill(SValue@ sv, string path)
{
	if (sv.GetType() != SValueType::Dictionary)
	{
		PrintError("SValue must be a dictionary!");
		return;
	}

	g_hardcoreSkills.insertLast(HardcoreSkill(sv, path));
}
