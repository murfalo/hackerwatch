namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;224;288;32;32"]
	class DestroyUnitChance
	{
		[Editable validation=IsValid]
		UnitFeed Units;
		
		[Editable default=0.5 min=0 max=1]
		float ChanceToDestroy;
		

		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		
		SValue@ ServerExecute()
		{
			SValueBuilder sval;
			sval.PushArray();
		
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				if (randf() <= ChanceToDestroy)
				{
					auto prod = units[i].GetUnitProducer();
					if (prod !is null && !IsNetsyncedExistance(prod.GetNetSyncMode()))
						sval.PushInteger(units[i].GetId());
						
					units[i].Destroy();
				}
			}
			
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			array<SValue@>@ units = val.GetArray();
			for (uint i = 0; i < units.length(); i++)
				g_scene.GetUnit(units[i].GetInteger()).Destroy();
		}
	}
}