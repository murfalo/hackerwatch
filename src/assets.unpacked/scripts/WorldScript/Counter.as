namespace WorldScript
{
	[WorldScript color="#B0C4DE" icon="system/icons.png;320;192;32;32"]
	class Counter
	{
		[Editable]
		int Count;

		[Editable validation=IsExecutable]
		UnitFeed ToExecute;

		int m_currCount;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			m_currCount++;

			if (m_currCount >= Count)
			{
				auto toExec = ToExecute.FetchAll();
				for (uint i = 0; i < toExec.length(); i++)
					WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
		}
	}
}
