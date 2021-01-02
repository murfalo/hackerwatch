namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;224;288;32;32"]
	class RandomChance
	{
		[Editable validation=IsExecutable]
		UnitFeed ToExecute;
		
		[Editable default=0.5 min=0 max=1]
		float ChanceToExecute;

		
		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}
		
		
		SValue@ ServerExecute()
		{
			auto toExec = ToExecute.FetchAll();
			for (uint i = 0; i < toExec.length(); i++)
				if (randf() <= ChanceToExecute)
					WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			
			return null;
		}
	}
}