namespace SurvivalSwitches
{
	class Switch
	{
		string m_flag;
		uint m_flagHash;

		string m_name;
		string m_description;
	}

	array<Switch@> g_switches;

	void LoadSwitches(SValue@ sval)
	{
		auto arrSwitches = sval.GetArray();
		for (uint i = 0; i < arrSwitches.length(); i++)
		{
			auto svSwitch = arrSwitches[i];

			auto newSwitch = Switch();
			newSwitch.m_flag = GetParamString(UnitPtr(), svSwitch, "flag");
			newSwitch.m_flagHash = HashString(newSwitch.m_flag);
			newSwitch.m_name = GetParamString(UnitPtr(), svSwitch, "name");
			newSwitch.m_description = GetParamString(UnitPtr(), svSwitch, "description");
			g_switches.insertLast(newSwitch);
		}
	}

	Switch@ GetSwitch(string flag)
	{
		return GetSwitch(HashString(flag));
	}

	Switch@ GetSwitch(uint flag)
	{
		for (uint i = 0; i < g_switches.length(); i++)
		{
			auto sw = g_switches[i];
			if (sw.m_flagHash == flag)
				return sw;
		}
		return null;
	}
}
