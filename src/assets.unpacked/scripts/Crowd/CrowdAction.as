abstract class CrowdAction
{
	string m_id;
	uint m_idHash;

	bool m_stat;

	CrowdAction(SValue& params)
	{
		if (params.GetDictionaryEntry("stat") !is null)
		{
			m_id = GetParamString(UnitPtr(), params, "stat");
			m_stat = true;
		}
		else
			m_id = GetParamString(UnitPtr(), params, "id");

		m_idHash = HashString(m_id);
	}

	void Clear()
	{
	}

	void TimeReset()
	{
	}

	float GetDelta()
	{
		return 0.0f;
	}

	float GetDebugValue()
	{
		return 0.0f;
	}
}
