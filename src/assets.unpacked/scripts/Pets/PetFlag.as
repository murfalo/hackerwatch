namespace Pets
{
	class PetFlag
	{
		uint m_idHash;
		string m_id;

		string m_name;
		string m_description;

		bool m_default;

		PetFlag(SValue@ sv)
		{
			m_id = GetParamString(UnitPtr(), sv, "id");
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), sv, "name");
			m_description = GetParamString(UnitPtr(), sv, "description", false);

			m_default = GetParamBool(UnitPtr(), sv, "default", false);
		}
	}
}
