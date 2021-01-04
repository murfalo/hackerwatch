namespace WorldScript
{
	[WorldScript color="176 196 222" icon="system/icons.png;384;128;32;32"]
	class CheckSpawnDistance
	{
		vec3 Position;
	
		[Editable type=enum default=3]
		CompareFunc Function;
	
		[Editable default=100]
		uint Value;
		
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
			uint ds = uint(dist(g_spawnPos, xy(Position)));
			
			bool result = false;
			switch(Function)
			{
				case CompareFunc::Equal:
					result = ds == Value;
					break;
				case CompareFunc::Greater:
					result = ds > Value;
					break;
				case CompareFunc::Less:
					result = ds < Value;
					break;
				case CompareFunc::GreaterOrEqual:
					result = ds >= Value;
					break;
				case CompareFunc::LessOrEqual:
					result = ds <= Value;
					break;
				case CompareFunc::NotEqual:
					result = ds != Value;
					break;
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