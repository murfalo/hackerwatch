namespace WorldScript
{
	[WorldScript color="#eee8aa" icon="system/icons.png;64;64;32;32"]
	class ToggleImmortality
	{
		[Editable type=enum default=1]
		ToggleState State;
	
		[Editable validation=IsValid]
		UnitFeed Units;
		
		bool IsValid(UnitPtr unit)
		{
			return cast<Actor>(unit.GetScriptBehavior()) !is null;
		}
		
		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
		
			switch(State)
			{
			case ToggleState::Enable:
				for (uint i = 0; i < units.length(); i++)
					cast<Actor>(units[i].GetScriptBehavior()).SetImmortal(true);
				break;
			case ToggleState::Disable:
				for (uint i = 0; i < units.length(); i++)
					cast<Actor>(units[i].GetScriptBehavior()).SetImmortal(false);
				break;
		
			case ToggleState::Toggle:
				for (uint i = 0; i < units.length(); i++)
				{
					auto actor = cast<Actor>(units[i].GetScriptBehavior());
					actor.SetImmortal(!actor.IsImmortal(true));
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