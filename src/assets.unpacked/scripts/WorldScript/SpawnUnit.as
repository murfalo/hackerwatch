namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;256;0;32;32"]
	class SpawnUnit : SpawnUnitBase
	{
		vec3 Position;

		UnitSource LastSpawned;
		UnitSource AllSpawned;

		[Editable]
		bool SafeSpawn;

		void Initialize()
		{
			Initialize(UnitPtr(), null);
		}

		SValue@ ServerExecute()
		{
			vec2 pos = xy(Position);
			pos += CalcJitter();

			if (SafeSpawn)
			{
				auto res = g_scene.QueryRect(pos, 1, 1, ~0, RaycastType::Any);
				if (res.length() > 0)
				{
					LastSpawned.Clear();
					return null;
				}
			}

			UnitPtr u = SpawnUnit(pos, null, 1.0);
			if (u.IsValid())
			{
				LastSpawned.Replace(u);
				AllSpawned.Add(u);
			}

			return null;
		}
	}
}
