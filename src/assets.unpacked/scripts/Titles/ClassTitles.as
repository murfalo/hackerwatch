namespace Titles
{
	int GetMaxClassTitleIndex()
	{
		if (!g_downscaling)
			return 9999;

		return 5 + int(g_ngp + 0.5f);
	}

	void LoadTitles(SValue@ sval)
	{
		string charClass = GetParamString(UnitPtr(), sval, "name");
		if (charClass == "")
		{
			PrintError("Missing \"name\" on class titles list, not adding it to the class titles!");
			return;
		}
		g_classTitles.AddClassTitles(charClass, sval);
	}

	void LoadMercenaryTitles(SValue@ sval)
	{
		@g_classTitles.m_titlesMercenary = Titles::TitleList(sval);
	}

	class ClassTitles
	{
		dictionary m_lists;

		Titles::TitleList@ m_titlesMercenary;

		void AddClassTitles(string charClass, SValue@ sval)
		{
			//print("Adding class titles for " + charClass);

			auto list = TitleList(sval);
			m_lists.set(charClass, @list);
		}

		TitleList@ GetList(string charClass)
		{
			TitleList@ list = null;
			m_lists.get(charClass, @list);
			return list;
		}

		Title@ GetTitle(string charClass, int index)
		{
			TitleList@ list = GetList(charClass);
			if (list is null)
			{
				PrintError("Class titles list for \"" + charClass + "\" is not loaded!");
				return null;
			}
			return list.GetTitle(index);
		}

		void RefreshModifiers(SValueBuilder& builder)
		{
			builder.PushArray();

			auto record = GetLocalPlayerRecord();

			record.modifiersTitles.Clear();

			if (Fountain::HasEffect("no_class_titles"))
			{
				builder.PopArray();
				return;
			}

%if HARDCORE
			int prestige = record.GetPrestige();
			int mercenaryTitleIndex = m_titlesMercenary.GetTitleIndexFromPoints(prestige);
			m_titlesMercenary.EnableTitleModifiers(record, mercenaryTitleIndex);
			builder.PushInteger(mercenaryTitleIndex);
%else
			dictionary titles;

			auto characters = HwrSaves::GetCharacters();
			for (uint i = 0; i < characters.length(); i++)
			{
				string charClass = GetParamString(UnitPtr(), characters[i], "class");
				int titleIndex = GetParamInt(UnitPtr(), characters[i], "title", false, 0);
				
				int64 best = titleIndex;
				if (titles.get(charClass, best))
					best = max(best, titleIndex);
					
				titles.set(charClass, best);
			}

			int maxTitleIndex = GetMaxClassTitleIndex();
			
			auto keys = titles.getKeys();
			for (uint i = 0; i < keys.length(); i++)
			{
				string charClass = keys[i];
				int64 titleIndex;
				titles.get(charClass, titleIndex);
				
				auto list = GetList(charClass);
				if (list is null)
				{
					PrintError("Class titles list for \"" + charClass + "\" is not loaded!");
					continue;
				}

				if (titleIndex > maxTitleIndex)
					titleIndex = maxTitleIndex;

				auto title = list.GetTitle(int(titleIndex));

				builder.PushArray();
				builder.PushString(charClass);
				builder.PushInteger(titleIndex);
				builder.PopArray();

				dictionary params = { { "title", Resources::GetString(title.m_name) } };
				title.m_modifiers.m_name = Resources::GetString(".modifier.list.classtitle", params);

				list.EnableTitleModifiers(record, titleIndex);
			}
%endif

			builder.PopArray();
		}

		void NetRefreshModifiers(PlayerRecord@ record, SValue@ params)
		{
			record.modifiersTitles.Clear();

			auto arrTitles = params.GetArray();

%if HARDCORE
			if (arrTitles.length() == 1)
			{
				int mercenaryTitleIndex = arrTitles[0].GetInteger();
				m_titlesMercenary.EnableTitleModifiers(record, mercenaryTitleIndex);
			}
%else
			for (uint i = 0; i < arrTitles.length(); i++)
			{
				auto arrTitle = arrTitles[i].GetArray();

				string charClass = arrTitle[0].GetString();
				int titleIndex = arrTitle[1].GetInteger();

				auto list = GetList(charClass);
				if (list is null)
				{
					PrintError("Class titles list for \"" + charClass + "\" is not loaded!");
					continue;
				}

				list.EnableTitleModifiers(record, titleIndex);
			}
%endif
		}
	}
}

Titles::ClassTitles g_classTitles;
