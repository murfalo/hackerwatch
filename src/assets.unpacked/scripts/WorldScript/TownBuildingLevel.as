namespace WorldScript
{
	[WorldScript color="#DBB1DE" icon="system/icons.png;224;288;32;32"]
	class TownBuildingLevel
	{
		[Editable type=enum default=1]
		CompareFunc Function;

		[Editable]
		int Value;

		[Editable]
		string ID;

		[Editable validation=IsExecutable]
		UnitFeed OnTrue;

		[Editable validation=IsExecutable]
		UnitFeed OnFalse;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm is null)
				return null;

			auto building = gm.m_town.GetBuilding(ID);
			if (building is null)
			{
				PrintError("Building with ID \"" + ID + "\" was not found in town!");
				return null;
			}

			bool result = false;

			switch(Function)
			{
				case CompareFunc::Equal: result = building.m_level == Value; break;
				case CompareFunc::Greater: result = building.m_level > Value; break;
				case CompareFunc::Less: result = building.m_level < Value; break;
				case CompareFunc::GreaterOrEqual: result = building.m_level >= Value; break;
				case CompareFunc::LessOrEqual: result = building.m_level <= Value; break;
				case CompareFunc::NotEqual: result = building.m_level != Value; break;
			}

			array<UnitPtr>@ toExec;
			if (result)
				@toExec = OnTrue.FetchAll();
			else
				@toExec = OnFalse.FetchAll();

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();

			return null;
		}
	}
}
