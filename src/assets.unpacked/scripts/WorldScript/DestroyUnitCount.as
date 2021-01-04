namespace WorldScript
{
	[WorldScript color="50 50 255" icon="system/icons.png;224;288;32;32"]
	class DestroyUnitCount
	{
		[Editable validation=IsValid]
		UnitFeed Units;
		
		[Editable default=1 min=1 max=100000]
		uint NumToDestroy;

		
		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		SValue@ ServerExecute()
		{
			SValueBuilder sval;
			sval.PushArray();
		
			auto units = Units.FetchAll();
			
			uint num = NumToDestroy;
			while (units.length() > 0 && num > 0)
			{
				uint i = randi(units.length());
				
				if (!IsNetsyncedExistance(units[i].GetUnitProducer().GetNetSyncMode()))
					sval.PushInteger(units[i].GetId());
				
				units[i].Destroy();
				units.removeAt(i);
				num--;
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