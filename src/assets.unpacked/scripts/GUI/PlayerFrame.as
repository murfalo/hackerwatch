class PlayerFrame : SVO
{
	string m_name;
	string m_description;

	bool m_owned;
	int m_legacyPoints;

	ScriptSprite@ m_sprite;

	PlayerFrame(SValue& params)
	{
		super(params);

		m_name = GetParamString(UnitPtr(), params, "name");
		m_description = GetParamString(UnitPtr(), params, "description", false);

		m_owned = GetParamBool(UnitPtr(), params, "owned", false);
		m_legacyPoints = GetParamInt(UnitPtr(), params, "legacy-points", false);

		auto arrSprite = GetParamArray(UnitPtr(), params, "sprite");
		if (arrSprite !is null)
			@m_sprite = ScriptSprite(arrSprite);
	}
}
