namespace WorldScript
{
	[WorldScript color="138 132 170" icon="system/icons.png;256;0;32;32"]
	class SpawnUnitAsLoot : SpawnUnitBase
	{
		[Editable]
		UnitFeed SpawnOn;
		
		UnitSource LastSpawned;
		UnitSource AllSpawned;
		
		
		void Initialize()
		{
			Initialize(UnitPtr(), null);
		}
		
		SValue@ ServerExecute()
		{
			LastSpawned.Clear();

			auto units = SpawnOn.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				vec2 pos = xy(units[i].GetPosition());
				UnitPtr u = SpawnUnit(pos + CalcJitter(), null, 1.0);
				
				if (u.IsValid())
				{
					LastSpawned.Replace(u);
					AllSpawned.Add(u);
				}
			}
			
			return null;
		}
	}
}