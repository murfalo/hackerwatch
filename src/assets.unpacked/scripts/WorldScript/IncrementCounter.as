namespace WorldScript
{
	[WorldScript color="#B0C4DE" icon="system/icons.png;320;192;32;32"]
	class IncrementCounter
	{
		[Editable validation=IsExecutable]
		UnitFeed Counters;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			auto units = Counters.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto b = cast<Counter>(units[i].GetScriptBehavior());
				if (b is null)
					continue;
				b.m_currCount--;
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
		}
	}
}
