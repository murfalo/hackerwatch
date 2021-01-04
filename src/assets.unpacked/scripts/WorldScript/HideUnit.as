enum HideState
{
	Hide = 1,
	Show,
	Toggle
}

namespace WorldScript
{
	[WorldScript color="#eee8aa" icon="system/icons.png;416;256;32;32"]
	class HideUnit
	{
		[Editable type=enum default=1]
		HideState State;
	
		[Editable validation=IsValid]
		UnitFeed Units;
		
		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
		
			switch(State)
			{
			case HideState::Hide:
				for (uint i = 0; i < units.length(); i++)
					units[i].SetHidden(true);
				break;
			case HideState::Show:
				for (uint i = 0; i < units.length(); i++)
					units[i].SetHidden(false);
				break;
		
			case HideState::Toggle:
				for (uint i = 0; i < units.length(); i++)
					units[i].SetHidden(!units[i].IsHidden());
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