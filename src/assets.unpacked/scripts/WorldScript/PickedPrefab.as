namespace WorldScript
{
	[WorldScript color="#FF0000" icon="system/icons.png;256;0;32;32"]
	class PickedPrefab
	{
		[Editable]
		Prefab@ Prefab;
	
		[Editable]
		string Flag;
		
		[Editable default=10]
		uint Chance;
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
