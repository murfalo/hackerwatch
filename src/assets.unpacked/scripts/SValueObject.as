class SVO
{
	string m_id;
	uint m_idHash;

	SVO(SValue& params)
	{
		m_id = GetParamString(UnitPtr(), params, "id");
		m_idHash = HashString(m_id);
	}
}
