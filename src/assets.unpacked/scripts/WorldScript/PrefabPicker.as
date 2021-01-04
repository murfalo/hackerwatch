namespace WorldScript
{
	[WorldScript color="50 50 255" icon="system/icons.png;256;0;32;32"]
	class PrefabPicker
	{
		vec3 Position;
	
		[Editable validation=IsPickedPrefab]
		UnitFeed PickedPrefabs;
		
		[Editable default=false]
		bool IncludeTilesets;		
		
		
		bool IsPickedPrefab(UnitPtr unit)
		{
			return cast<PickedPrefab>(unit.GetScriptBehavior()) !is null;
		}
		
		SValue@ ServerExecute()
		{
			array<PickedPrefab@> scripts;
		
			int totChance = 0;
			auto pfbs = PickedPrefabs.FetchAll();
			for (uint i = 0; i < pfbs.length(); i++)
			{
				WorldScript@ script = WorldScript::GetWorldScript(pfbs[i]);
				if (script !is null && script.CanExecuteNow())
				{
					auto prefab = cast<PickedPrefab>(pfbs[i].GetScriptBehavior());
					if (prefab.Prefab is null)
						continue;
					
					if (prefab.Flag == "" || !g_flags.IsSet(prefab.Flag))
					{
						scripts.insertLast(prefab);
						totChance += prefab.Chance;
					}
				}
			}

			if (scripts.length() <= 0)
				return null;

			int n = randi(totChance);
			for (uint i = 0; i < scripts.length(); i++)
			{
				n -= scripts[i].Chance;
				if (n < 0)
				{
					if (scripts[i].Flag != "")
						g_flags.Set(scripts[i].Flag, FlagState::Level);
				
					scripts[i].Prefab.Fabricate(g_scene, Position, IncludeTilesets);
					WorldScript::GetWorldScript(g_scene, scripts[i]).Execute();
					break;
				}
			}
			
			return null;
		}
	}
}