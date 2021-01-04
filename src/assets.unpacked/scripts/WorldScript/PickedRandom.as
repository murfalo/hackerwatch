namespace WorldScript
{
	[WorldScript color="#FF0000" icon="system/icons.png;256;0;32;32"]
	class PickedRandom
	{
		[Editable default=10]
		uint Chance;
		
		SValue@ ServerExecute()
		{	
			return null;
		}
	}
}
