namespace Titles
{
	class Title
	{
		string m_name;
		int m_points;

		Modifiers::ModifierList@ m_modifiers;

		int m_unlockGold;
		int m_unlockOre;

		int m_skillPoints;

		Title(SValue@ sval)
		{
			m_name = GetParamString(UnitPtr(), sval, "name");
			m_points = GetParamInt(UnitPtr(), sval, "points", false);

			@m_modifiers = Modifiers::LoadModifiersList(UnitPtr(), sval);

			m_unlockGold = GetParamInt(UnitPtr(), sval, "unlock-gold", false);
			m_unlockOre = GetParamInt(UnitPtr(), sval, "unlock-ore", false);

			m_skillPoints = GetParamInt(UnitPtr(), sval, "skillpoints", false);

			dictionary params = { { "title", Resources::GetString(m_name) } };
			m_modifiers.m_name = Resources::GetString(".modifier.list.title", params);
		}

		void EnableModifiers(PlayerRecord@ record)
		{
			record.modifiersTitles.Add(m_modifiers);
		}

		void EnableModifiers(Modifiers::ModifierList@ modifiers)
		{
			modifiers.Add(m_modifiers);
		}
	}
}
