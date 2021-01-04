enum ToggleState
{
	Enable = 1,
	Disable,
	Toggle
}

namespace WorldScript
{
	[WorldScript color="#eee8aa" icon="system/icons.png;352;352;32;32"]
	class ToggleScripts
	{
		[Editable type=enum default=1]
		ToggleState State;
	
		[Editable validation=IsValid]
		UnitFeed Scripts;


		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) !is null;
		}
		
		SValue@ ServerExecute()
		{
			auto scripts = Scripts.FetchAll();
		
			switch(State)
			{
			case ToggleState::Enable:
				for (uint i = 0; i < scripts.length(); i++)
					GetWorldScript(scripts[i]).SetEnabled(true);
				break;
			case ToggleState::Disable:
				for (uint i = 0; i < scripts.length(); i++)
					GetWorldScript(scripts[i]).SetEnabled(false);
				break;
		
			case ToggleState::Toggle:
				for (uint i = 0; i < scripts.length(); i++)
				{
					WorldScript@ script = GetWorldScript(scripts[i]);
					script.SetEnabled(!script.IsEnabled());
				}
				break;
			}
			
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}