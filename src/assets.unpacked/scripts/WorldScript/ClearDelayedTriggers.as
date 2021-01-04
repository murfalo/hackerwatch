namespace WorldScript
{
	[WorldScript color="222 160 140" icon="system/icons.png;448;128;32;32"]
	class ClearDelayedTriggers
	{
		[Editable validation=IsExecutable]
		UnitFeed Scripts;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			return (script !is null && script.IsExecutable());
		}

		SValue@ ServerExecute()
		{
			array<WorldScript@> arr;

			auto units = Scripts.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto ws = WorldScript::GetWorldScript(units[i]);
				if (ws !is null)
					arr.insertLast(ws);
			}

			g_scene.ClearDelayedScriptExecution(arr);
			return null;
		}
	}
}
