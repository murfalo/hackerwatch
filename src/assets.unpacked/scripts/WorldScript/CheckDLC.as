namespace WorldScript
{
	[WorldScript color="176 196 222" icon="system/icons.png;320;384;32;32"]
	class CheckDLC
	{
		[Editable default="pop"]
		string DLC;
		
		[Editable validation=IsExecutable]
		UnitFeed IsOwned;
		
		[Editable validation=IsExecutable]
		UnitFeed IsNotOwned;

		
		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}
		
		SValue@ ServerExecute()
		{
			array<UnitPtr>@ toExec;
			if (Platform::HasDLC(DLC))
				@toExec = IsOwned.FetchAll();
			else
				@toExec = IsNotOwned.FetchAll();
				
			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			
			return null;
		}
	}
}