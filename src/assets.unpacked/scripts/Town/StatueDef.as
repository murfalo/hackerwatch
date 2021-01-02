// Usage:
//   if (Statues::GetPlacedLevel("armor-statue") == 1)

namespace Statues
{
	array<Statues::StatueDef@> g_statues;

	class StatueDef
	{
		string m_id;
		uint m_idHash;

		string m_name;
		string m_desc;
		string m_descUpgrade;
		string m_useText;

		string m_achievement;

		bool m_unlocked;

		int m_cost;

		Modifiers::ModifierList@ m_modifiers;

		array<Modifiers::Modifier@> m_builtModifiers;
		array<Modifiers::Modifier@> m_incModifiers;

		UnitScene@ m_scene;
		UnitScene@ m_sceneSmall;

		StatueDef(string id, SValue@ sval)
		{
			m_id = id;
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), sval, "name");
			m_desc = GetParamString(UnitPtr(), sval, "desc");
			m_descUpgrade = GetParamString(UnitPtr(), sval, "desc-upgrade");
			m_useText = GetParamString(UnitPtr(), sval, "use-text");

			m_achievement = GetParamString(UnitPtr(), sval, "achievement", false);

			m_unlocked = GetParamBool(UnitPtr(), sval, "unlocked", false);

			m_cost = GetParamInt(UnitPtr(), sval, "cost");

			m_builtModifiers = Modifiers::LoadModifiers(UnitPtr(), sval, "", Modifiers::SyncVerb::Statue, m_idHash);
			m_incModifiers = Modifiers::LoadModifiers(UnitPtr(), sval, "inc-");

			@m_modifiers = Modifiers::ModifierList();
			dictionary params = { { "statue", Resources::GetString(m_name) } };
			m_modifiers.m_name = Resources::GetString(".modifier.list.statue", params);

			auto prod = Resources::GetUnitProducer(GetParamString(UnitPtr(), sval, "unit"));
			@m_scene = prod.GetUnitScene(GetParamString(UnitPtr(), sval, "scene"));
			@m_sceneSmall = prod.GetUnitScene(GetParamString(UnitPtr(), sval, "scene-small"));
		}

		int GetUpgradeCost(int level)
		{
			if (level == 1)
				return m_cost;

			return 100 * int(pow(level, 1.5f));
		}

		void EnableModifiers(Modifiers::ModifierList@ list, int level)
		{
			if (level >= 1)
			{
				for (uint i = 0; i < m_builtModifiers.length(); i++)
				{
					auto mod = list.Add(m_builtModifiers[i]);

					auto statueMod = cast<Modifiers::IStatueModifier>(mod);
					if (statueMod !is null)
						statueMod.SetStatue(this, level);
				}

				for (uint j = 0; j < m_incModifiers.length(); j++)
				{
					auto mod = list.Add(m_incModifiers[j]);

					auto statueMod = cast<Modifiers::IStatueModifier>(mod);
					if (statueMod !is null)
						statueMod.SetStatue(this, level);

					auto stackedMod = cast<Modifiers::StackedModifier>(mod);
					if (stackedMod !is null)
						stackedMod.m_stackCount = level;
				}
			}
		}
	}

	int GetPlacedLevel(string id)
	{
		auto gm = cast<Campaign>(g_gameMode);

		int placement = gm.m_town.GetStatuePlacement(id);
		if (placement == -1)
			return 0;

		auto statue = gm.m_town.GetStatue(id);
		if (statue is null)
		{
			PrintError("Coulnd't find statue with ID \"" + id + "\"");
			return 0;
		}

		return statue.m_level;
	}

	StatueDef@ GetStatue(uint id)
	{
		for (uint i = 0; i < g_statues.length(); i++)
		{
			if (g_statues[i].m_idHash == id)
				return g_statues[i];
		}
		return null;
	}

	StatueDef@ GetStatue(string id)
	{
		for (uint i = 0; i < g_statues.length(); i++)
		{
			if (g_statues[i].m_id == id)
				return g_statues[i];
		}
		return null;
	}

	void LoadStatues(SValue@ sv)
	{
		auto keys = sv.GetDictionary().getKeys();
		for (uint i = 0; i < keys.length(); i++)
			g_statues.insertLast(StatueDef(keys[i], sv.GetDictionaryEntry(keys[i])));
	}
}
