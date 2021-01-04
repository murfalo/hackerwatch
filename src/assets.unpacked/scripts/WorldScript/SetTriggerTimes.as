namespace WorldScript
{
	[WorldScript color="#eee8aa" icon="system/icons.png;384;384;32;32"]
	class SetTriggerTimes
	{
		[Editable min=-1 max=999999 default=-1]
		int TriggerTimes;
	
		[Editable validation=IsValid]
		UnitFeed Scripts;
		
		bool IsValid(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}
		
		SValue@ ServerExecute()
		{
			auto scripts = Scripts.FetchAll();
			for (uint i = 0; i < scripts.length(); i++)
				GetWorldScript(scripts[i]).SetTriggerTimes(TriggerTimes);
				
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}