class DungeonNgp
{
	uint m_id;

	pint m_ngp;
	pint m_presented;

	DungeonNgp() {}

	DungeonNgp(SValue@ sv)
	{
		auto arr = sv.GetArray();
		m_id = uint(arr[0].GetInteger());
		m_ngp = arr[1].GetInteger();
		m_presented = arr[2].GetInteger();
	}

	DungeonNgp(uint id, int ngp, int presented = -1)
	{
		m_id = id;
		m_ngp = ngp;
		m_presented = (presented != -1 ? presented : ngp);
	}

	void Save(SValueBuilder& builder)
	{
		builder.PushArray();
		builder.PushInteger(int(m_id));
		builder.PushInteger(m_ngp);
		builder.PushInteger(m_presented);
		builder.PopArray();
	}

	void SetBoth(int ngp)
	{
		m_ngp = ngp;
		m_presented = ngp;
	}
}
