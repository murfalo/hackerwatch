namespace WorldScript
{
	[WorldScript color="176 196 222" icon="system/icons.png;96;96;32;32"]
	class RandomLoot
	{
		vec3 Position;
		
		[Editable default=false]
		bool Forced;
	
		SValue@ ServerExecute()
		{
			RandomLootManager::AddLootPoint(this);
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}