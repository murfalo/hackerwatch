class RetiredGladiatorValue
{
	pint m_value;
	pint m_max;

	int opImplConv()
	{
		return m_value;
	}

	void opPostInc()
	{
		m_value++;
		m_max = max(m_value, m_max);
	}

	void opAssign(int value)
	{
		m_value = value;
		m_max = max(m_value, m_max);
	}

	void Save(SValueBuilder& builder, const string &in name)
	{
		builder.PushArray(name);
		builder.PushInteger(m_value);
		builder.PushInteger(m_max);
		builder.PopArray();
	}

	void Load(SValue@ sval, const string &in name, int def = 0)
	{
		auto sv = sval.GetDictionaryEntry(name);
		if (sv is null)
			return;

		if (sv.GetType() == SValueType::Array)
		{
			auto arr = sv.GetArray();
			m_value = arr[0].GetInteger();
			m_max = arr[1].GetInteger();
			return;
		}

		if (sv.GetType() == SValueType::Integer)
		{
			m_value = sv.GetInteger();
			m_max = m_value;
			return;
		}

		m_value = def;
		m_max = def;
	}
}
