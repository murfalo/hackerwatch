namespace Titles
{
	class TitleList
	{
		array<Title@> m_titles;

		array<Modifiers::Modifier@> m_incModifiers;

		bool m_forceIncModifiers;
		int m_extraIncModifiers;

		TitleList(string filename)
		{
			auto sval = Resources::GetSValue(filename);
			if (sval is null)
			{
				PrintError("Couldn't find titles list file \"" + filename + "\"");
				return;
			}

			Load(sval);
		}

		TitleList(SValue@ sval)
		{
			Load(sval);
		}

		void Load(SValue@ sval)
		{
			m_incModifiers = Modifiers::LoadModifiers(UnitPtr(), sval, "inc-");

			auto arr = GetParamArray(UnitPtr(), sval, "titles");
			for (uint i = 0; i < arr.length(); i++)
				m_titles.insertLast(Title(arr[i]));

			m_forceIncModifiers = GetParamBool(UnitPtr(), sval, "force-inc-modifiers", false);
			m_extraIncModifiers = GetParamInt(UnitPtr(), sval, "extra-inc-modifiers", false);
		}

		void ClearModifiers(Modifiers::ModifierList@ modifiers)
		{
			for (uint i = 0; i < m_titles.length(); i++)
				modifiers.Remove(m_titles[i].m_modifiers);
		}

		void EnableTitleModifiers(PlayerRecord@ record, int index)
		{
			GetTitle(index).EnableModifiers(record);

			auto extra = GetExtraModifiers(index);
			for (uint i = 0; i < extra.length(); i++)
				record.modifiersTitles.Add(extra[i]);
		}

		array<Modifiers::Modifier@> GetExtraModifiers(int index)
		{
			if (index < 0)
				index = 0;

			array<Modifiers::Modifier@> ret;
			if ((!m_forceIncModifiers && index < int(m_titles.length())) || m_incModifiers.length() == 0)
				return ret;

			int num;
			if (m_forceIncModifiers)
				num = index + m_extraIncModifiers;
			else
				num = index - int(m_titles.length()) + 1;

			for (int i = 0; i < num; i++)
			{
				for (uint j = 0; j < m_incModifiers.length(); j++)
					ret.insertLast(m_incModifiers[j]);
			}

			return ret;
		}

		Title@ GetTitle(int index)
		{
			if (index < 0)
				return m_titles[0];
			if (index >= int(m_titles.length()))
				return m_titles[m_titles.length() - 1];
			return m_titles[index];
		}

		Title@ GetTitleFromPoints(int points)
		{
			for (int i = m_titles.length() - 1; i >= 0; i--)
			{
				if (points >= m_titles[i].m_points)
					return m_titles[i];
			}
			return null;
		}

		int GetTitleIndexFromPoints(int points)
		{
			for (int i = m_titles.length() - 1; i >= 0; i--)
			{
				if (points >= m_titles[i].m_points)
					return i;
			}
			return 0;
		}

		Title@ GetNextTitleFromPoints(int points)
		{
			for (int i = m_titles.length() - 1; i >= 0; i--)
			{
				if (points >= m_titles[i].m_points)
				{
					if (i == int(m_titles.length()) - 1)
						break;
					return m_titles[i + 1];
				}
			}
			return null;
		}
	}
}
