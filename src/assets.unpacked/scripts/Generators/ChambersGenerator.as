class ChambersRoom
{
	int x, y, z, w;
	array<ChambersRoom@> connections;
	bool isReachable;

	ChambersRoom(ivec4 size)
	{
		isReachable = false;
		
		x = size.x;
		y = size.y;
		z = size.z;
		w = size.w;
	}
	
	void FloodFill()
	{
		if (isReachable)
			return;
			
		isReachable = true;
		for (uint i = 0; i < connections.length(); i++)
			connections[i].FloodFill();
	}
}

[Generator]
class ChambersGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	[Editable default=10]
	int Splits;
	
	[Editable default=false]
	bool Prefabs;
	
	[Editable default=8]
	int Padding;
	
	
	bool close(int a, int b)
	{
		return abs(a - b) < 3;
	}
	
	int getx(int ax1, int ax2, int bx1, int bx2)
	{
		int x = (max(ax1, bx1) + min(ax2, bx2)) / 2;
		
		if (x <= ax1 || x <= bx1 || x >= ax2 || x >= bx2)
			return -1;
		
		return x;
	}
	
	ivec4 FindDoorway(ChambersRoom@ a, ChambersRoom@ b)
	{
		int w = 1;
	
		if (close(a.y, b.y + b.w))
		{
			int x = getx(a.x, a.x+a.z, b.x, b.x+b.z);
			if (x < 0)
				return ivec4(-1);
			return ivec4(x - w, a.y - w, x + w, a.y + w);
		}
		else if (close(b.y, a.y + a.w))
		{
			int x = getx(a.x, a.x+a.z, b.x, b.x+b.z);
			if (x < 0)
				return ivec4(-1);
			return ivec4(x - w, b.y - w, x + w, b.y + w);
		}
		else if (close(a.x, b.x + b.z))
		{
			int y = getx(a.y, a.y+a.w, b.y, b.y+b.w);
			if (y < 0)
				return ivec4(-1);
			return ivec4(a.x - w, y - w, a.x + w, y + w);
		}
		else if (close(b.x, a.x + a.z))
		{
			int y = getx(a.y, a.y+a.w, b.y, b.y+b.w);
			if (y < 0)
				return ivec4(-1);
			return ivec4(b.x - w, y - w, b.x + w, y + w);
		}
		
		return ivec4(-1);
	}
	
	bool IsValidPos(array<ivec4>& doorways, int x, int y, int w, int h)
	{
		for (uint i = 0; i < doorways.length(); i++)
		{
			auto dw = doorways[i];
			if (!(dw.x > (x + w) || dw.z < x || dw.y > (y + h) || dw.w < y))
				return false;
		}
		
		return true;
	}

	ivec2 GetRandomPos(int roomx, int roomy, int roomw, int roomh, array<ivec4>& doorways, int w, int h)
	{
		if (roomw <= w || roomh <= h)
			return ivec2(-1, -1);
	
		for (int i = 0; i < 10; i++)
		{
			int x = randi(roomw - 2 - w) + roomx + 1;
			int y = randi(roomh - 2 - h) + roomy + 1;

			if (IsValidPos(doorways, x, y, w, h))
				return ivec2(x, y);
		}
	
		return ivec2(-1, -1);
	}
	
	void PlacePrefab(array<ivec4>& doorways, ivec2 pos, int w, int h, PointOfInterestType prefab)
	{
		if (pos.x <= 0)
			return;
	
		doorways.insertLast(ivec4(pos.x -2, pos.y -2, pos.x + w +4, pos.y + h +4));

		for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++)
		{
			m_brush.SetCell(pos.x + x, pos.y + y, Cell::Reserved);
			m_brush.SetConsumed(pos.x + x, pos.y + y);
		}
		
		if (prefab == PointOfInterestType::None)
			return;
		
		m_brush.AddPointOfInterest(prefab, pos.x, pos.y);
	}
	
	
	void FillRoom(int x, int y, int w, int h, array<ivec4>& doorways, PointOfInterestType type)
	{
		if (!Prefabs)
			return;
	
		for (int i = 0; i < 5; i++)
		{
			ivec2 pfbPos;
			
			pfbPos = GetRandomPos(x, y, w, h, doorways, 25, 27);
			if (pfbPos.x >= 0)
			{
				PlacePrefab(doorways, pfbPos + ivec2(2, 3), 21, 21, Prefab21x21Block);
				continue;
			}
			
			pfbPos = GetRandomPos(x, y, w, h, doorways, 17, 22);
			if (pfbPos.x >= 0)
			{
				PlacePrefab(doorways, pfbPos + ivec2(2, 3), 13, 13, Prefab13x13Block);
				continue;
			}
			
			pfbPos = GetRandomPos(x, y, w, h, doorways, 13, 15);
			if (pfbPos.x >= 0)
			{
				PlacePrefab(doorways, pfbPos + ivec2(2, 3), 9, 9, Prefab9x9Block);
				continue;
			}
			
			pfbPos = GetRandomPos(x, y, w, h, doorways, 7, 9);
			if (pfbPos.x >= 0)
			{
				PlacePrefab(doorways, pfbPos + ivec2(2, 3), 3, 3, Prefab3x3Block);
				continue;
			}
		}
	}
	
	ivec2 m_topRoom;
	ivec2 m_botRoom;

	void MakeRoom(array<ChambersRoom@>& rooms, uint i)
	{
		auto room = rooms[i];
		
		PlotRect(ivec2(room.x +1, room.y +1), ivec2(room.x + room.z -1, room.y + room.w -1), Cell::Floor);
		array<ivec4> doorways;
		
		bool openAll = false;
		auto type = PointOfInterestType::None;

		if (i > 0)
		{
			auto prev = rooms[i -1];
			
			auto doorway = FindDoorway(room, prev);
			if (doorway.x >= 0)
			{
				room.connections.insertLast(prev);
				doorways.insertLast(doorway);
				PlotRect(ivec2(doorway.x, doorway.y), ivec2(doorway.z, doorway.w), Cell::Floor);
			}			
			else
				openAll = true;
		}
		//else
		//	type = PointOfInterestType::Entry;
		
		if (i < rooms.length() - 1)
		{
			auto next = rooms[i +1];
			
			auto doorway = FindDoorway(room, next);
			if (doorway.x >= 0)
			{
				room.connections.insertLast(next);
				doorways.insertLast(doorway);
				PlotRect(ivec2(doorway.x, doorway.y), ivec2(doorway.z, doorway.w), Cell::Floor);
			}			
			else
				openAll = true;
		}
		//else
		//	type = PointOfInterestType::Exit;
			
		if (openAll)
		{
			for (uint j = 0; j < rooms.length(); j++)
			{
				if (i == j)
					continue;
			
				auto doorway = FindDoorway(room, rooms[j]);
				if (doorway.x >= 0)
				{
					room.connections.insertLast(rooms[j]);
					doorways.insertLast(doorway);
					PlotRect(ivec2(doorway.x, doorway.y), ivec2(doorway.z, doorway.w), Cell::Floor);
				}
			}	
		}
		
		if (room.y < m_topRoom.y)
			m_topRoom = ivec2(room.x + room.z / 2, room.y);
		if ((room.y + room.w) > m_botRoom.y)
			m_botRoom = ivec2(room.x + room.z / 2, room.y + room.w);
		
		FillRoom(room.x, room.y, room.z, room.w, doorways, type);
	}
	
	void SplitRoom(array<ivec4>& rooms, uint idx)
	{
		if (idx >= rooms.length())
			return;
	
		auto room = rooms[idx];
		
		ivec4 a, b;
		if ((room.z > room.w) || (randi(100) <= 22))
		{
			if (room.z <= 9 * 2)
				return;
		
			a = ivec4(room.x, room.y, room.z / 2 - randi(1) - 1, room.w);
			b = ivec4(room.x + room.z / 2, room.y, (room.z +1) / 2, room.w);
		}
		else
		{
			if (room.w <= 9 * 2)
				return;
				
			a = ivec4(room.x, room.y, room.z, room.w / 2 - randi(1) - 1);
			b = ivec4(room.x, room.y + room.w / 2, room.z, (room.w +1) / 2);
		}
		

		rooms.removeAt(idx);
		rooms.insertAt(idx, b);
		rooms.insertAt(idx, a);
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
	
			int spacing = 300 / 16;
			int padding = Padding;
			array<ivec4> rooms = { ivec4(padding, padding + spacing, w - padding * 2, h - padding * 2 - spacing * 2) };
			
			m_topRoom = ivec2(0, 100000);
			m_botRoom = ivec2(0, -100000);
			
			SplitRoom(rooms, 0);
			SplitRoom(rooms, 1);
			SplitRoom(rooms, 0);
			
			for (int i = 0; i < Splits - 3; i++)
				SplitRoom(rooms, randi(rooms.length()));
			
			for (uint i = 0; i < rooms.length(); i++)
			{
				auto room = rooms[i];
				
				if (room.x == padding)
				{
					int d = randi(padding/3 -1);
					room.x -= d;
					room.z += d;
				}
				if (room.y == padding)
				{
					int d = randi(padding/3 -1);
					room.y -= d;
					room.w += d;
				}
				
				if (room.x + room.z == w - padding)
					room.z += randi(padding/3 -1);
				if (room.y + room.w == h - padding)
					room.w += randi(padding/3 -1);
				
				rooms[i] = room;
			}
			
			rooms.removeAt(rooms.length() -1);
			rooms.removeAt(0);
			
			
			array<ChambersRoom@> roomCs;
			for (uint i = 0; i < rooms.length(); i++)
				roomCs.insertLast(ChambersRoom(rooms[i]));
			
			for (int i = roomCs.length() - 1; i >= 0; i--)
				MakeRoom(roomCs, i);
			
				
			bool failed = false;
			roomCs[0].FloodFill();
			for (uint i = 0; i < roomCs.length(); i++)
			{
				if (!roomCs[i].isReachable)
				{
					failed = true;
					break;
				}
			}
			
			if (failed)
				continue;
				
				
			int corridorLen = 34;
			int sideCorridorLen = 40;

			PlotLine(ivec2(m_topRoom.x + 3, m_topRoom.y), ivec2(m_topRoom.x + 3, m_topRoom.y - corridorLen), 10, Cell::Floor);
			PlotLine(ivec2(m_botRoom.x + 3, m_botRoom.y), ivec2(m_botRoom.x + 3, m_botRoom.y + corridorLen), 10, Cell::Floor);
			
			ivec2 topMid(m_topRoom.x, m_topRoom.y - corridorLen / 2);
			ivec2 botMid(m_botRoom.x, m_botRoom.y + corridorLen / 2);
			
			
			int sideX = topMid.x + sideCorridorLen * (topMid.x < (w / 2) ? 1 : -1);
			PlotLine(topMid, ivec2(sideX, topMid.y), 6, Cell::Floor);
			PlotLine(ivec2(sideX, m_topRoom.y - corridorLen), ivec2(sideX, topMid.y + 10), 6, Cell::Floor);
			
			sideX = botMid.x + sideCorridorLen * (botMid.x < (w / 2) ? 1 : -1);
			PlotLine(botMid, ivec2(sideX, botMid.y), 6, Cell::Floor);
			PlotLine(ivec2(sideX, m_botRoom.y + corridorLen), ivec2(sideX, botMid.y - 13), 6, Cell::Floor);
			
			//PlotRect(ivec2(m_topRoom.x - 12, m_topRoom.y - corridorLen - 24), ivec2(m_topRoom.x + 12, m_topRoom.y - corridorLen), Cell::Floor);
			PlotRect(ivec2(m_botRoom.x - 32, m_botRoom.y + corridorLen), ivec2(m_botRoom.x + 4, m_botRoom.y + corridorLen + 13), Cell::Reserved, true);
			
			
			//PlotPoint(ivec2(sideX, m_botRoom.y + corridorLen), ivec2(sideX, botMid.y - 13), 6, Cell::Wall);
			PlotPoint(m_botRoom.x + 4, m_botRoom.y + corridorLen, Cell::Wall);
			PlotPoint(m_botRoom.x - 3, m_botRoom.y + corridorLen, Cell::Wall);
			
			
//			PlotPoint(x, y, cellType);
//			m_brush.SetConsumed(x, y);
			
			
			
			ivec2 startPos = ivec2(m_botRoom.x - 32, m_botRoom.y + corridorLen -1);
			ivec2 exitPos = ivec2(m_topRoom.x, m_topRoom.y - corridorLen - 10 - 3);
			
			
			array<ivec4> doorways;
			PlacePrefab(doorways, startPos, 7, 7, PointOfInterestType::Entry);
			PlacePrefab(doorways, exitPos - ivec2(11, 11), 24, 24, PointOfInterestType::Exit);
			
			for (int y = 0; y < 26; y++)
				for (int x = 0; x < 26; x++)
					m_brush.SetConsumed(exitPos.x - 12 + x, exitPos.y - 12 + y);
		
			
			startPos += ivec2(2, 1);
			m_startPos = vec2(float(startPos.x), float(startPos.y));
			g_spawnPos = vec2(16 * startPos.x + m_brush.m_posOffset.x + 16, 16 * startPos.y + m_brush.m_posOffset.y + 24);
			

			//MakeCliffs(MaxCliffNum, 400);
			
			if (Prefabs)
			{
				PatternMatcher ptrnMtch;
				PrefabPlacement placer(m_brush, ptrnMtch);

				placer.PlacePrefab(PointOfInterestType::Prefab6x12Path, 2);
				placer.PlacePrefab(PointOfInterestType::Prefab6x8Path, 2);
				placer.PlacePrefab(PointOfInterestType::Prefab8x4Path, 2);
				placer.PlacePrefab(PointOfInterestType::Prefab6x4Path, 2);
				
				
				placer.PlacePrefab(PointOfInterestType::Prefab14x14North2, 3);
				placer.PlacePrefab(PointOfInterestType::Prefab14x14South2, 3);
				placer.PlacePrefab(PointOfInterestType::Prefab13x13East, 3);
				placer.PlacePrefab(PointOfInterestType::Prefab13x13West, 3);
				
				
				placer.PlacePrefab(PointOfInterestType::Prefab10x10North2, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab10x10South2, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab5x5North, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab13x13North, 5);
				
								
				
				// 10x10 blocks now
				
				
				placer.PlacePrefab(PointOfInterestType::Prefab5x5BlockNorth, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab5x5BlockSouth, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab5x6BlockEast, 5);
				placer.PlacePrefab(PointOfInterestType::Prefab5x6BlockWest, 5);
			}
			
			PlaceCrateBreakables(w, h);
			
			m_brush.GenerateNothingness();
			PlaceEnemies(scene, ivec2(int(m_startPos.x), int(m_startPos.y)));
			
			break;
		}
		
		m_brush.Build(scene);
		
		
		int numBatSpawners = 3 + m_numPlrs;
		int dist = int(sqrt(Width * Width + Height * Height) / 2.0f * 0.9f);
		auto batSpawner = Resources::GetPrefab("prefabs/chambers/bat_spawner.pfb");
		
		for (int i = 0; i < numBatSpawners; i++)
		{
			float ang = (i + 0.5f) * (PI * 2 / numBatSpawners);
			vec3 pos(m_brush.m_posOffset.x + Width / 2 + cos(ang) * dist, m_brush.m_posOffset.y + Height / 2 + sin(ang) * dist, 0);

			g_prefabsToSpawn.insertLast(PrefabToSpawn(batSpawner, pos));
			//batSpawner.Fabricate(scene, pos);
		}
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
		auto w = Pattern::Wall;
		auto f = Pattern::Floor;
			
		array<array<Pattern>> ptrnA = {
			{w, w},
			{w, f},
			{w, f},
			{w, f},
			{w, f},
			{w, w}
		};
		
		array<array<Pattern>> ptrnB = {
			{w, w},
			{f, w},
			{f, w},
			{f, w},
			{f, w},
			{w, w}
		};
			
	
		for (int i = 0; i < numFill; i++)
		{
			bool filled = false;
			filled = FillDeadEnd(matcher, brush, ptrnA, ivec2(1, 1), 1, 4) || filled;
			filled = FillDeadEnd(matcher, brush, ptrnB, ivec2(0, 1), 1, 4) || filled;
			
			if (!filled)
				break;
		}
	}
}
