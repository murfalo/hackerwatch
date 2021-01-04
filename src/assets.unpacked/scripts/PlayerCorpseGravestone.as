class PlayerCorpseGravestone : SVO
{
	UnitProducer@ m_prod;
	string m_scene;

	string m_name;
	string m_description;

	int m_legacyPoints;

	ScriptSprite@ m_icon;

	PlayerCorpseGravestone(SValue& params)
	{
		super(params);

		@m_prod = Resources::GetUnitProducer(GetParamString(UnitPtr(), params, "unit"));
		m_scene = GetParamString(UnitPtr(), params, "scene", false);

		m_name = GetParamString(UnitPtr(), params, "name");
		m_description = GetParamString(UnitPtr(), params, "description", false);

		m_legacyPoints = GetParamInt(UnitPtr(), params, "legacy-points");

		auto arrIcon = GetParamArray(UnitPtr(), params, "icon", false);
		if (arrIcon !is null)
			@m_icon = ScriptSprite(arrIcon);
	}

	UnitScene@ GetScene()
	{
		if (m_prod is null)
			return null;

		return m_prod.GetUnitScene(m_scene);
	}
}
