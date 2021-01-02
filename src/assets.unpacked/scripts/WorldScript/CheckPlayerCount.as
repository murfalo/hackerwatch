namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;416;384;32;32"]
	class CheckPlayerCount
	{
		[Editable type=enum default=1]
		CompareFunc Function;
	
		[Editable default=1]
		int Value;
	
		[Editable default=true]
		bool IncludeDead;
		
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
			int num = 0;
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255)
					continue;
				
				if (!IncludeDead && g_players[i].IsDead())
					continue;
				
				num++;
			}
			
			if (IncludeDead)
				num += max(0, GetVarInt("g_extra_players"));
			
			bool result = false;
			switch(Function)
			{
				case CompareFunc::Equal:
					result = num == Value;
					break;
				case CompareFunc::Greater:
					result = num > Value;
					break;
				case CompareFunc::Less:
					result = num < Value;
					break;
				case CompareFunc::GreaterOrEqual:
					result = num >= Value;
					break;
				case CompareFunc::LessOrEqual:
					result = num <= Value;
					break;
				case CompareFunc::NotEqual:
					result = num != Value;
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