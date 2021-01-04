class SpawnPrefabBase
{
	[Editable]
	Prefab@ Prefab;

	[Editable]
	float JitterX;
	[Editable]
	float JitterY;
	
	[Editable default=false]
	bool IncludeTilesets;
	
	[Editable]
	int Delay;
	
	

	void Initialize(UnitPtr unit, SValue@ params)
	{
		if (params !is null)
		{
			@Prefab = Resources::GetPrefab(GetParamString(unit, params, "prefab"));
			Delay = GetParamInt(unit, params, "delay", false, 0);
			vec2 jitter = GetParamVec2(unit, params, "jitter", false);
			JitterX = jitter.x;
			JitterY = jitter.y;
			IncludeTilesets = GetParamBool(unit, params, "include-tilesets", false, false);
		}
	}
	
	vec2 CalcJitter()
	{
		return vec2((randf() * 2.0 - 1.0) * JitterX, (randf() * 2.0 - 1.0) * JitterY);
	}
	
	void SpawnPrefab(vec2 pos)
	{
		if (Prefab is null)
			return;

		if (Delay > 0)
		{
			QueuedTasks::Queue(Delay, SpawnPrefabBaseTask(Prefab, pos, IncludeTilesets));
			return;
		}
		
		Prefab.Fabricate(g_scene, xyz(pos), IncludeTilesets);
	}
}

class SpawnPrefabBaseTask : QueuedTasks::QueuedTask
{
	SpawnPrefabBaseTask(Prefab@ prefab, vec2 pos, bool includeTilesets)
	{
		@m_prefab = prefab;
		m_pos = pos;
		m_includeTilesets = includeTilesets;
	}

	void Execute() override
	{
		m_prefab.Fabricate(g_scene, xyz(m_pos), m_includeTilesets);
	}
	
	Prefab@ m_prefab;
	vec2 m_pos;
	bool m_includeTilesets;
}