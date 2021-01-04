[Generator]
class DesertGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	
	[Editable default=false]
	bool Prefabs;
	
	
	void Generate(Scene@ scene) override
	{
		int w = Width / 16;
		int h = Height / 16;
		ivec2 startPos = ivec2(w/2 + randi(w/10) - w/20, h-1);
		int p = 20;
		
		while (true)
		{
			print("Generating level...");
			
		
			MakeBrush();
			m_brush.Initialize(w, h, vec2(-Width / 2, -Height / 2));
	
			//PlotRect(ivec2(1, 1), ivec2(w-2, h-2), Cell::Floor);
			PlotRect(ivec2(0, 0), ivec2(w-1, h-1), Cell::Floor);
	
			
			auto wlk = Pattern::Walkable;
			auto nwl = Pattern::NotWall;
			auto wll = Pattern::Wall;
			auto nwk = Pattern::NotWalkable;
			auto any = Pattern::Anything;
			auto nth = Pattern::Nothing;
			
			
			PatternMatcher ptrnMtch;
			//ptrnMtch.RemoveDiagonals(m_brush);
			
			m_startPos = vec2(16 * startPos.x + m_brush.m_posOffset.x, 16 * startPos.y + m_brush.m_posOffset.y + 384);
			g_spawnPos = m_startPos;
			
			ConsumeRect(ivec2(0, 1), p, p);
			ConsumeRect(ivec2(w-1, 1), -p, p);
			ConsumeRect(ivec2(0, h), p, -p);
			ConsumeRect(ivec2(w-1, h), -p, -p);
		
			PrefabPlacement placer(m_brush, ptrnMtch);
			
			if (m_placeActShortcut)
				placer.PlacePrefab(PointOfInterestType::PrefabActShortcut, 1);
			
			if (Prefabs)
			{
				%PROFILE_START Prefabs
				
				if (!PlacePrefabs(placer))
					continue;

				%PROFILE_STOP
			}
			
			PlaceBreakables();
			
			m_brush.GenerateNothingness();
			PlaceEnemies(scene, startPos);
			
			
			break;
		}
		
		m_brush.Build(scene);
		
		
		array<PrefabToSpawn@> pfbs;
		string pfs = "prefabs/desert/";
		
		Resources::GetPrefab(pfs+"entrance.pfb").Fabricate(scene, vec3(16 * startPos.x + m_brush.m_posOffset.x, 16 * startPos.y + m_brush.m_posOffset.y, 0));
		PlotSide(pfbs, scene, ivec2(0, 1+p), ivec2(0, 1), h-p*2, Resources::GetPrefab(pfs+"1xwest.pfb"), Resources::GetPrefab(pfs+"2xwest.pfb"), Resources::GetPrefab(pfs+"10xwest.pfb"), Resources::GetPrefab(pfs+"20xwest.pfb"), Resources::GetPrefab(pfs+"50xwest.pfb"));
		PlotSide(pfbs, scene, ivec2(w-1, 1+p), ivec2(0, 1), h-p*2, Resources::GetPrefab(pfs+"1xeast.pfb"), Resources::GetPrefab(pfs+"2xeast.pfb"), Resources::GetPrefab(pfs+"10xeast.pfb"), Resources::GetPrefab(pfs+"20xeast.pfb"), Resources::GetPrefab(pfs+"50xeast.pfb"));
		PlotSide(pfbs, scene, ivec2(1+p, -1), ivec2(1, 0), w-2-p*2, Resources::GetPrefab(pfs+"1xnorth.pfb"), Resources::GetPrefab(pfs+"2xnorth.pfb"), Resources::GetPrefab(pfs+"10xnorth.pfb"), Resources::GetPrefab(pfs+"20xnorth.pfb"), Resources::GetPrefab(pfs+"50xnorth.pfb"));
		
		PlotSide(pfbs, scene, ivec2(1+p, h), ivec2(1, 0), startPos.x - 10 -p, Resources::GetPrefab(pfs+"1xsouth.pfb"), Resources::GetPrefab(pfs+"2xsouth.pfb"), Resources::GetPrefab(pfs+"10xsouth.pfb"), Resources::GetPrefab(pfs+"20xsouth.pfb"), Resources::GetPrefab(pfs+"50xsouth.pfb"));
		PlotSide(pfbs, scene, ivec2(startPos.x + 10, h), ivec2(1, 0), w - startPos.x - 10 -1-p, Resources::GetPrefab(pfs+"1xsouth.pfb"), Resources::GetPrefab(pfs+"2xsouth.pfb"), Resources::GetPrefab(pfs+"10xsouth.pfb"), Resources::GetPrefab(pfs+"20xsouth.pfb"), Resources::GetPrefab(pfs+"50xsouth.pfb"));

		pfbs.insertLast(PrefabToSpawn(Resources::GetPrefab(pfs+"nw.pfb"), xyz(vec2(16 * (0), 16 * (-1)) + m_brush.m_posOffset)));
		pfbs.insertLast(PrefabToSpawn(Resources::GetPrefab(pfs+"ne.pfb"), xyz(vec2(16 * (w-1), 16 * (-1)) + m_brush.m_posOffset)));
		pfbs.insertLast(PrefabToSpawn(Resources::GetPrefab(pfs+"sw.pfb"), xyz(vec2(16 * (0), 16 * (h)) + m_brush.m_posOffset)));
		pfbs.insertLast(PrefabToSpawn(Resources::GetPrefab(pfs+"se.pfb"), xyz(vec2(16 * (w-1), 16 * (h)) + m_brush.m_posOffset)));		
		
		while (pfbs.length() > 0)
		{
			int i = randi(pfbs.length());
			//pfbs[i].pfb.Fabricate(scene, pfbs[i].pos);
			g_prefabsToSpawn.insertLast(pfbs[i]);
			pfbs.removeAt(i);
		}
	}
	
	void ConsumeRect(ivec2 pos, int w, int h)
	{
		if (w < 0)
		{
			pos.x += w;
			w *= -1;
		}
		
		if (h < 0)
		{
			pos.y += h;
			h *= -1;
		}
	
		for (int y = 0; y < h; y++)
			for (int x = 0; x < w; x++)
				m_brush.SetConsumed(pos.x + x, pos.y + y);
	}
	
	void PlotSide(array<PrefabToSpawn@>@ pfbs, Scene@ scene, ivec2 start, ivec2 d, int num, Prefab@ sz1, Prefab@ sz2, Prefab@ sz10, Prefab@ sz20, Prefab@ sz50)
	{
		array<uint8> wall;
	
		if (sz50 !is null)
		{
			int n50 = int(num / 50.0f / 1.05f);
			for (int i = 0; i < n50; i++)
				wall.insertAt(randi(wall.length()), 50);
			num -= n50 * 50;
		}
		
		if (sz20 !is null)
		{
			int n20 = int(num / 20.0f / 1.05f);
			for (int i = 0; i < n20; i++)
				wall.insertAt(randi(wall.length()), 20);
			num -= n20 * 20;
		}

		if (sz10 !is null)
		{
			int n10 = int(num / 10.0f);
			for (int i = 0; i < n10; i++)
				wall.insertAt(randi(wall.length()), 10);
			num -= n10 * 10;
		}
		
		if (sz2 !is null)
		{
			int n2 = num / 2 / 2;
			for (int i = 0; i < n2; i++)
				wall.insertAt(randi(wall.length()), 2);
			num -= n2 * 2;
		}
		
		for (int i = 0; i < num; i++)
			wall.insertAt(randi(wall.length()), 1);
		
		
		vec3 offset1;
		if (d.y != 0)
			offset1.y = -16;
		
		int p = 0;
		for (uint i = 0; i < wall.length(); i++)
		{
			vec3 pos = vec3(16 * (start.x + d.x * p) + m_brush.m_posOffset.x, 16 * (start.y + d.y * p) + m_brush.m_posOffset.y, 0);
			switch(wall[i])
			{
			case 50:
				pfbs.insertLast(PrefabToSpawn(sz50, pos));
				break;
			case 20:
				pfbs.insertLast(PrefabToSpawn(sz20, pos));
				break;
			case 10:
				pfbs.insertLast(PrefabToSpawn(sz10, pos));
				break;
			case 2:
				pfbs.insertLast(PrefabToSpawn(sz2, pos));
				break;
			case 1:
				pfbs.insertLast(PrefabToSpawn(sz1, pos + offset1));
				break;
			}		
		
			p += wall[i];
		}
	}
	
	void PlaceBreakables()
	{
	}
	
	bool PlacePrefabs(PrefabPlacement@ placer)
	{
		for (int i = 0; i < 3; i++)
		{
			placer.PlacePrefab(PointOfInterestType::Prefab35x35Block, 1);
			placer.PlacePrefab(PointOfInterestType::Prefab21x21Block, 3);
			placer.PlacePrefab(PointOfInterestType::Prefab13x13Block, 4);
			placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 5);
		}
		
		for (int i = 0; i < 3; i++)
		{
			placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 5);
			placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 6);
			placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 7);
		}
		
		return true;
	}
}


