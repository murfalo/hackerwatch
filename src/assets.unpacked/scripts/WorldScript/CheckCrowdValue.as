namespace WorldScript
{
	[WorldScript color="186 85 164" icon="system/icons.png;352;96;32;32"]
	class CheckCrowdValue
	{
		[Editable]
		int MinValue;

		[Editable]
		int MaxValue;

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
			auto gm = cast<Survival>(g_gameMode);
			if (gm is null)
				return null;

			bool result = (gm.m_crowdValue >= MinValue && gm.m_crowdValue <= MaxValue);

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
