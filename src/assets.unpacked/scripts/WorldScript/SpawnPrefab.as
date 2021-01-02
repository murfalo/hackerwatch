namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;256;0;32;32"]
	class SpawnPrefab : SpawnPrefabBase
	{
		vec3 Position;
	
		void Initialize()
		{
			Initialize(UnitPtr(), null);
		}
		
		SValue@ ServerExecute()
		{
			SpawnPrefab(xy(Position) + CalcJitter());
			return null;
		}
	}
}