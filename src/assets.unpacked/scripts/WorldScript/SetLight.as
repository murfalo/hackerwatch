namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;160;288;32;32"]
	class SetLight
	{
		[Editable type=enum default=1]
		HideState State;

		[Editable validation=IsLight lights=true]
		UnitFeed Units;

		bool IsLight(UnitPtr unit)
		{
			return unit.IsLight();
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
