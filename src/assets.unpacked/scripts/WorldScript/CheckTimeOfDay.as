namespace WorldScript
{
	[WorldScript color="176 196 222" icon="system/icons.png;192;352;32;32"]
	class CheckTimeOfDay
	{
		[Editable validation=IsExecutable]
		UnitFeed OnDay;
		
		[Editable validation=IsExecutable]
		UnitFeed OnNight;
		
		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}
		
		SValue@ ServerExecute()
		{
%if TIME_DAY
			auto toExec = OnDay.FetchAll();
%else
			auto toExec = OnNight.FetchAll();
%endif

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			
			return null;
		}
	}
}