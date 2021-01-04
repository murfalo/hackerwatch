namespace WorldScript
{
	[WorldScript color="176 196 222" icon="system/icons.png;320;384;32;32"]
	class CheckSwitch
	{
		[Editable]
		string Switch;
		
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
			array<UnitPtr>@ toExec;
			if (Resources::GetAssetDefine("MOD_" + Switch))
				@toExec = OnTrue.FetchAll();
			else
				@toExec = OnFalse.FetchAll();
				
			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			
			return null;
		}
	}
}