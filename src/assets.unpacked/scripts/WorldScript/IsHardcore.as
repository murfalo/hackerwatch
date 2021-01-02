namespace WorldScript
{
	[WorldScript color="222 111 99" icon="system/icons.png;64;192;32;32"]
	class IsHardcore
	{
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
%if HARDCORE
			auto toExec = OnTrue.FetchAll();
%else
			auto toExec = OnFalse.FetchAll();
%endif

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();

			return null;
		}
	}
}
