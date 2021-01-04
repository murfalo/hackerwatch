namespace WorldScript
{
	[WorldScript color="#eee8aa" icon="system/icons.png;352;352;32;32"]
	class ToggleJammable
	{
		[Editable type=enum default=1]
		ToggleState State;

		[Editable validation=IsJammable]
		UnitFeed Units;

		bool IsJammable(UnitPtr unit)
		{
			return (cast<JammableBehavior>(unit.GetScriptBehavior()) !is null);
		}

		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();

			for (uint i = 0; i < units.length(); i++)
			{
				JammableBehavior@ jammable = cast<JammableBehavior>(units[i].GetScriptBehavior());
				if (jammable is null)
					continue;

				switch (State)
				{
					case ToggleState::Enable: jammable.m_active = true; break;
					case ToggleState::Disable: jammable.m_active = false; break;
					case ToggleState::Toggle: jammable.m_active = !jammable.m_active; break;
				}
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
