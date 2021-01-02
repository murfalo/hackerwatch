class MercenaryUpgradeDef : SVO
{
	string m_name;
	string m_description;

	ScriptSprite@ m_sprite;

	array<Modifiers::Modifier@> m_modifiers;

	MercenaryUpgradeDef(SValue& sval)
	{
		super(sval);

		m_name = GetParamString(UnitPtr(), sval, "name");
		m_description = GetParamString(UnitPtr(), sval, "description", false);

		auto arrSprite = GetParamArray(UnitPtr(), sval, "sprite", false);
		if (arrSprite !is null)
			@m_sprite = ScriptSprite(arrSprite);

		m_modifiers = Modifiers::LoadModifiers(UnitPtr(), sval);
	}
}
