[Generator]
class MinesGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	[Editable default=1]
	float Density;
	
	[Editable default=0.1]
	float RoomChance;
	[Editable default=8]
	int RoomSize;
	
	[Editable default=5]
	int NumDeadEndsFill;
	[Editable default=100]
	int MaxCliffNum;
	
	[Editable default=false]
	bool Prefabs;
	
	
	
	
	bool TryMakeRoom(array<ivec2>@ junctions, ivec2 pos, int w, int h, bool force = false)
	{
		ivec2 tl(pos.x - (w / 2), pos.y - (h / 2));
		ivec2 br(pos.x + (w - w / 2), pos.y + (h - h / 2));
		
		if (m_brush.GetCell(tl.x, tl.y) == Cell::Floor &&
			m_brush.GetCell(br.x, tl.y) == Cell::Floor &&
			m_brush.GetCell(tl.x, br.y) == Cell::Floor &&
			m_brush.GetCell(br.x, br.y) == Cell::Floor && !force)
			return false;
		
		PlotRect(tl, br, Cell::Floor);
		FinalizeRoom(tl, br);
		
		junctions.insertLast(ivec2(tl.x + 2, tl.y + 2));
		junctions.insertLast(ivec2(tl.x + 2, br.y - 2));
		junctions.insertLast(ivec2(br.x - 2, tl.y + 2));
		junctions.insertLast(ivec2(br.x - 2, br.y - 2));
		
		return true;
	}
	
	void FinalizeRoom(ivec2 tl, ivec2 br)
	{
		if (randi(100) < 50)
			m_brush.SetCell(tl.x, tl.y, Cell::Wall);
		if (randi(100) < 50)
			m_brush.SetCell(tl.x, br.y, Cell::Wall);
		if (randi(100) < 50)
			m_brush.SetCell(br.x, tl.y, Cell::Wall);
		if (randi(100) < 50)
			m_brush.SetCell(br.x, br.y, Cell::Wall);
	}
	
	ivec2 jitterVec2(float x, float y, int spread)
	{
		return ivec2(int(x) + randi(spread) - spread / 2, int(y) + randi(spread) - spread / 2);
	}
	
	void FinalizeState(array<ivec2>@ junctions, array<ivec2>@ rooms) {}
	array<ivec2> GetPathDirections() { return { ivec2(0, -8), ivec2(0, 8), ivec2(-5, 0), ivec2(5, 0) }; }
	
	float MakeInitialState(array<ivec2>@ junctions, array<ivec2>@ rooms)
	{
		int w = Width / 16;
		int h = Height / 16;

		switch (randi(10))
		{
		case 0:
		{
			float div = 3.1f;
			junctions.insertLast(jitterVec2(w / div, h / div, 4));
			junctions.insertLast(jitterVec2((w*(div-1)) / div, h / div, 4));
			junctions.insertLast(jitterVec2(w / div, (h*(div-1)) / div, 4));
			junctions.insertLast(jitterVec2((w*(div-1)) / div, (h*(div-1)) / div, 4));
			
			int skip = randi(6);
			
			if (skip != 0) PlotLine(junctions[0], junctions[1], 4, Cell::Floor);
			if (skip != 1) PlotLine(junctions[2], junctions[3], 4, Cell::Floor);
			if (skip != 2) PlotLine(junctions[0], junctions[2], 2, Cell::Floor);
			if (skip != 3) PlotLine(junctions[1], junctions[3], 2, Cell::Floor);
			
			
			auto rp = jitterVec2(w / 2, h / 2, 6);
			
			int line = (skip + 1) % 4;
			if (line == 0) PlotLine((junctions[0] + junctions[1]) / 2, rp, 2, Cell::Floor);
			if (line == 1) PlotLine((junctions[2] + junctions[3]) / 2, rp, 2, Cell::Floor);
			if (line == 2) PlotLine((junctions[0] + junctions[2]) / 2, rp, 4, Cell::Floor);
			if (line == 3) PlotLine((junctions[1] + junctions[3]) / 2, rp, 4, Cell::Floor);
			
			TryMakeRoom(junctions, rp, 10, 12, true);
			rooms.insertLast(rp);
			
			return 1.f / 20.f;
		}
		case 1:
		case 2:
		{
			TryMakeRoom(junctions, ivec2(w / 2, h / 2 - 12), 10, 9);
			TryMakeRoom(junctions, ivec2(w / 2, h / 2 + 12), 10, 9);
			
			rooms.insertLast(ivec2(w / 2, h / 2 - 12));
			
			PlotLine(ivec2(w / 2, h / 2 - 12), ivec2(w / 2, h / 2 + 12), 4, Cell::Floor);
			
			return 4.0f;
		}
		case 3:
		case 4:
		{
			TryMakeRoom(junctions, ivec2(w / 2 - 12, h / 2), 8, 14);
			TryMakeRoom(junctions, ivec2(w / 2 + 12, h / 2), 8, 14);
			
			rooms.insertLast(ivec2(w / 2 - 12, h / 2));
			
			PlotLine(ivec2(w / 2 - 12, h / 2), ivec2(w / 2 + 12, h / 2), 6, Cell::Floor);
			
			return 4.0f;
		}
		default:
		{
			TryMakeRoom(junctions, ivec2(w / 2, h / 2), 10, 12);
			rooms.insertLast(ivec2(w / 2, h / 2));
			return 1.f;
		}
		}
		
		return 1.f;
	}
	
	void Generate(Scene@ scene) override
	{
		while (true)
		{
			print("Generating level...");
		
			int w = Width / 16;
			int h = Height / 16;
			
			
		
			MakeBrush();
			m_brush.Initialize(w, h, vec2(-Width / 2, -Height / 2));
	

			int padding = RoomSize + 14;
			array<ivec2> dirs = GetPathDirections();
	
			
			array<ivec2> junctions;
			array<ivec2> rooms;
			float pm = MakeInitialState(junctions, rooms);

			int attempts = 0;
			int plots = int(w * h * Density / 42 * pm);
			while (plots > 0)
			{
				if (attempts > 250)
					break;
			
				int d = randi(dirs.length());
				int j = randi(junctions.length());
				auto junction = junctions[j];
				auto to = junction + dirs[d];
				
				if (to.x < padding || to.y < padding || to.x >= w - padding || to.y >= h - padding)
				{
					attempts++;
					continue;
				}
				
				if (m_brush.GetCell(to.x, to.y) == Cell::Floor)
				{
					attempts++;
					continue;
				}
					
				bool close = false;
				for (uint r = 0; r < rooms.length(); r++)
				{
					ivec2 rd = rooms[r] - to;
					if (rd.x * rd.x + rd.y * rd.y < RoomSize * RoomSize)
					{
						close = true;
						break;
					}
				}
				
				plots--;
				
				if (close)
				{
					attempts++;
					continue;
				}

				if (randf() < RoomChance)
				{
					junctions.removeAt(j);
					
					if (TryMakeRoom(junctions, to, 4 + randi(RoomSize), 2 + randi(RoomSize)))
						rooms.insertLast(to);
				}
				
				
				junctions.insertLast(to);
				
				if (d == 3)
					junction += ivec2(-1, 0);
				
				if (d == 2)
					to += ivec2(-1, 0);
					
				PlotLine(junction, to, d <= 1 ? 2 : 4, Cell::Floor);
			}
			
			FinalizeState(junctions, rooms);
			
			
			auto wlk = Pattern::Walkable;
			auto nwl = Pattern::NotWall;
			auto wll = Pattern::Wall;
			auto nwk = Pattern::NotWalkable;
			auto any = Pattern::Anything;
			auto nth = Pattern::Nothing;
			
			
			PatternMatcher ptrnMtch;
			ptrnMtch.RemoveDiagonals(m_brush);
			
			
			ivec2 startPos;
			
			{
				array<array<Pattern>> ptrn = {
					{any, any, wll, wll, any, any},
					{wll, wll, wll, wll, wll, wll},
					{wll, wll, wll, wll, wll, wll},
					{wll, wll, wll, wll, wll, wll},
					{wll, wll, wll, wll, wll, wll},
					{wll, wll, wll, wll, wll, wll},
					{any, any, wlk, wlk, any, any},
					{any, any, wlk, wlk, any, any},
					{any, any, wlk, wlk, any, any}
				};

				auto allExits = ptrnMtch.FindAllPatterns(m_brush, ptrn);
				if (allExits.length() < 2)
					continue;
					
				
				float longestDist = 0;
				ivec2 points;
				
				for (uint i = 0; i < allExits.length(); i++)
				{
					for (uint j = 0; j < allExits.length(); j++)
					{
						auto d = allExits[i] - allExits[j];
						float dist = float(d.x) * float(d.x) + float(d.y) * float(d.y);
						if (dist > longestDist)
						{
							longestDist = dist;
							points = ivec2(i, j);
						}
					}
				}
				
				float minDist = (w + h) / 4.f;
				if (longestDist < minDist * minDist)
					continue;
				
				auto pos = allExits[points.x] + ivec2(1, 2);
				m_brush.AddPointOfInterest(PointOfInterestType::Entry, pos.x + 1, pos.y + 1);
				for (int i = 0; i < 5; i++)
				{
					m_brush.SetCell(pos.x + 1, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 1, pos.y + i);
					m_brush.SetCell(pos.x + 2, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 2, pos.y + i);
				}
				
				startPos = ivec2(pos.x + 1, pos.y + 2);
				
				for (int y = 2; y <= 5; y++)
				{
					for (int x = -2; x <= 2; x++)
					{
						if (m_brush.GetCell(pos.x + x, pos.x + y) == Cell::Breakables)
							m_brush.SetCell(pos.x + x, pos.x + y, Cell::Floor);
					}
				}
				
				m_startPos = vec2(16 * startPos.x + m_brush.m_posOffset.x + 16, 16 * startPos.y + m_brush.m_posOffset.y + 24);
				g_spawnPos = m_startPos;
				
				
				pos = allExits[points.y] + ivec2(1, 2);
				m_brush.AddPointOfInterest(PointOfInterestType::Exit, pos.x + 1, pos.y + 1);
				for (int i = 0; i < 5; i++)
				{
					m_brush.SetCell(pos.x + 1, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 1, pos.y + i);
					m_brush.SetCell(pos.x + 2, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 2, pos.y + i);
				}
			}
			
			
			PrefabPlacement placer(m_brush, ptrnMtch);
			
			if (m_brush.HasPointOfInterest(PointOfInterestType::PrefabSpecialOre) && !g_flags.IsSet("special_ore"))
			{
				if (placer.PlacePrefab(PointOfInterestType::PrefabSpecialOre, 1) < 1)
					continue;
			}
			
			if (m_placeActShortcut)
				placer.PlacePrefab(PointOfInterestType::PrefabActShortcut, 1);
			
			MakeCliffs(MaxCliffNum, 200);
			
			if (Prefabs)
			{
				%PROFILE_START Prefabs
				
				if (!PlacePrefabs(placer))
					continue;

				%PROFILE_STOP
			}
			else
				FillDeadEnds(ptrnMtch, m_brush, NumDeadEndsFill);
			
			PlaceBreakables();
			
			m_brush.GenerateNothingness();
			PlaceEnemies(scene, startPos);
			
			
			break;
		}
		
		m_brush.Build(scene);
	}
	
	void PlaceBreakables()
	{
	}
	
	bool PlacePrefabs(PrefabPlacement@ placer)
	{
		array<PointOfInterestType> specials = { 
			PointOfInterestType::Prefab13x13North,
			PointOfInterestType::Prefab9x9North,
			PointOfInterestType::Prefab9x9South
		};

		placer.PlacePrefabs(specials, 2);
		
	
	
		array<PointOfInterestType> rooms1 = { 
			PointOfInterestType::Prefab5x5North,
			PointOfInterestType::Prefab3x3North,
			PointOfInterestType::Prefab5x5South,
			PointOfInterestType::Prefab9x9East,
			PointOfInterestType::Prefab9x9West
		};

		placer.PlacePrefabs(rooms1, 3);

		
		
		array<PointOfInterestType> rooms2 = { 
			PointOfInterestType::Prefab10x10North2,
			PointOfInterestType::Prefab10x10South2,
			PointOfInterestType::Prefab6x6North2,
			PointOfInterestType::Prefab6x6South2,
			PointOfInterestType::Prefab5x5East,
			PointOfInterestType::Prefab5x5West
		};

		placer.PlacePrefabs(rooms2, 6, 2);
		
		
		
		array<PointOfInterestType> wallBlocks = { 
			PointOfInterestType::Prefab5x5BlockNorth,
			PointOfInterestType::Prefab5x5BlockSouth,
			PointOfInterestType::Prefab5x6BlockEast,
			PointOfInterestType::Prefab5x6BlockWest
		};

		placer.PlacePrefabs(wallBlocks, 6 + int(g_ngp) * 2, 2 + int(g_ngp));
		
		
		
		
		
		
		
		if (randi(100) < 50)
			placer.PlacePrefab(PointOfInterestType::Prefab13x13Block, 1);
		else
			placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 1);
		
		placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 2 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 3 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 4 + int(g_ngp));
		
		FillDeadEnds(placer.m_ptrnMtch, m_brush, NumDeadEndsFill);
		
		placer.PlacePrefab(PointOfInterestType::Prefab2x6Path, 2 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab6x3Path, 2 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab2x3Junction, 2 + int(g_ngp));
		
		return true;
	}
	
	
	bool FillDeadEnd(PatternMatcher@ matcher, DungeonBrush@ brush, array<array<Pattern>>@ pattern, ivec2 offset, int w, int h)
	{
		auto ends = matcher.FindAllPatterns(brush, pattern);
		
		for (uint i = 0; i < ends.length(); i++)
		{
			int xs = ends[i].x + offset.x;
			int ys = ends[i].y + offset.y;
		
			for (int x = 0; x < w; x++)
				for (int y = 0; y < h; y++)
					brush.SetCell(xs + x, ys + y, Cell::Wall);
		}
		
		return ends.length() > 0;
	}
	
	void FillDeadEnds(PatternMatcher@ matcher, DungeonBrush@ brush, int numFill)
	{
		for (int i = 0; i < numFill; i++)
		{
			auto w = Pattern::Wall;
			auto f = Pattern::Floor;
			
			bool filled = false;
			

			{
				array<array<Pattern>> ptrn = {
					{w, w, w, w},
					{w, f, f, w}
				};
				
				filled = FillDeadEnd(matcher, brush, ptrn, ivec2(1, 1), 2, 1) || filled;
			}
			
			{
				array<array<Pattern>> ptrn = {
					{w, f, f, w},
					{w, w, w, w}
				};
				
				filled = FillDeadEnd(matcher, brush, ptrn, ivec2(1, 0), 2, 1) || filled;
			}
			
			{
				array<array<Pattern>> ptrn = {
					{w, w},
					{w, f},
					{w, f},
					{w, f},
					{w, w}
				};
				
				filled = FillDeadEnd(matcher, brush, ptrn, ivec2(1, 1), 1, 3) || filled;
			}
			
			{
				array<array<Pattern>> ptrn = {
					{w, w},
					{f, w},
					{f, w},
					{f, w},
					{w, w}
				};
				
				filled = FillDeadEnd(matcher, brush, ptrn, ivec2(0, 1), 1, 3) || filled;
			}
			
			if (!filled)
				break;
		}
	}
}


