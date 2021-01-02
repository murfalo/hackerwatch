namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;256;96;32;32"]
	class DestroyUnits
	{
		[Editable validation=IsValid]
		UnitFeed Units;

		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
				units[i].Destroy();

			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto@ up = units[i].GetUnitProducer();
				if (up !is null && !IsNetsyncedExistance(up.GetNetSyncMode()))
					units[i].Destroy();
			}
		}
	}
}