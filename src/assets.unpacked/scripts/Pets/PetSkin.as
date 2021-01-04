namespace Pets
{
	class PetSkin
	{
		string m_id;
		uint m_idHash;

		string m_name;
		string m_description;

		int m_cost;
		int m_legacyPoints;

		UnitProducer@ m_prod;

		ScriptSprite@ m_icon;

		PetSkin(SValue@ sv)
		{
			m_name = GetParamString(UnitPtr(), sv, "name");
			m_description = GetParamString(UnitPtr(), sv, "description", false);

			m_cost = GetParamInt(UnitPtr(), sv, "cost", false);
			m_legacyPoints = GetParamInt(UnitPtr(), sv, "legacy-points", false);

			m_id = GetParamString(UnitPtr(), sv, "unit");
			m_idHash = HashString(m_id);
			@m_prod = Resources::GetUnitProducer(m_idHash);

			@m_icon = ScriptSprite(GetParamArray(UnitPtr(), sv, "icon"));
		}
	}
}
