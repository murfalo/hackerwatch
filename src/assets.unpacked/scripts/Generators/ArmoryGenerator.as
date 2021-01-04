[Generator]
class ArmoryGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	[Editable default=12]
	int RoomSize;
	
	[Editable default=3]
	int MaxCliffNum;
	
	[Editable default=false]
	bool Prefabs;
	
	bool m_requireStatues;

	void MakeRoom(ivec2 pos, int w, int h, bool randSize = false)
	{
		if (randSize)
		{
			if (randi(100) > (m_numPlrs * 30))
				w = int(w * 0.66);
			if (randi(100) > (m_numPlrs * 30))
				h = int(h * 0.66);	
		}
	
		ivec2 tl(pos.x - (w / 2), pos.y - (h / 2));
		ivec2 br(pos.x + (w - w / 2), pos.y + (h - h / 2));
		
		PlotRect(tl, br, Cell::Floor);
		FinalizeRoom(tl, br);
	}
	
	void FinalizeRoom(ivec2 tl, ivec2 br)
	{
	}
	
	void MakeRoomLine(ivec2 from, ivec2 to, int thickness)
	{
		MakeRoom(from, 5 + randi(RoomSize - 5), 5 + randi(RoomSize - 5), true);
		MakeRoom(to, 5 + randi(RoomSize - 5), 5 + randi(RoomSize - 5), true);
	
		float d = sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2));
		int segments = max(1, int(d / RoomSize));
		ivec2 dt = (to - from) / segments;
		ivec2 side(sign(-dt.y), sign(dt.x));
		bool horizontal = abs(dt.x) > abs(dt.y);
		
		for (int i = 0; i < segments; i++)
		{
			ivec2 t = from + dt;
			PlotLine(from, t, thickness, Cell::Floor);
			ivec2 roomSz((horizontal ? 5 : 4) + randi(RoomSize - 4), (horizontal ? 4 : 5) + randi(RoomSize - 4));
			MakeRoom(t, roomSz.x, roomSz.y);
			
			from = t + ivec2(side.x * (randi(roomSz.x) - roomSz.x / 2), side.y * (randi(roomSz.y) - roomSz.y / 2));
		}
	
		PlotLine(from, to, thickness, Cell::Floor);
	}

	void MakeRoomRect(int x, int y, int w, int h)
	{
		MakeRoomLine(ivec2(x, y), ivec2(x + w, y), 6);
		MakeRoomLine(ivec2(x, y), ivec2(x, y + h), 6);
		MakeRoomLine(ivec2(x + w, y + h), ivec2(x + w, y), 6);
		MakeRoomLine(ivec2(x + w, y + h), ivec2(x, y + h), 6);
	}
	
	bool MakeInitialState()
	{
		m_requireStatues = true;
		int w = Width / 16;
		int h = Height / 16;
		int padding = RoomSize + 12;
		
		int dx = (randi(20) + 1) * (randi(100) < 50 ? 1 : -1);
		int dy = (randi(20) + 1) * (randi(100) < 50 ? 1 : -1);
		
		ivec2 rpos(w / 2 - dx, h / 2 - dy);
		ivec2 rsz(clamp(dx * 1000, -(w / 2 - padding), w / 2 - padding), clamp(dy * 1000, -(h / 2 - padding), h / 2 - padding));
		
		MakeRoomRect(rpos.x, rpos.y, rsz.x, rsz.y);
		MakeRoomRect(rpos.x + rsz.x / 2, rpos.y + rsz.y / 2, -rsz.x, -rsz.y);
		
		return true;
	}
	
	float GetMinEntranceDist(int w, int h)
	{
		return min(w, h) / 4.f;
	}
	
	void CleanupPatterns(PatternMatcher@ ptrnMtch)
	{
		ptrnMtch.RemoveDiagonals(m_brush);
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
	
	
			if (!MakeInitialState())
				continue;
			
			
			auto wlk = Pattern::Walkable;
			auto nwl = Pattern::NotWall;
			auto wll = Pattern::Wall;
			auto nwk = Pattern::NotWalkable;
			auto any = Pattern::Anything;
			auto nth = Pattern::Nothing;
			
			
			PatternMatcher ptrnMtch;
			
			ptrnMtch.RemoveDiagonals(m_brush);
			CleanupPatterns(ptrnMtch);
			
			
			
			ivec2 startPos;
			
			{
				array<array<Pattern>> ptrn = {
					{any, any, wll, wll, any, any},
					{wll, wll, wll, wll, wll, wll},
					{wll, wll, wll, wll, wll, wll},
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
				
				float minDist = GetMinEntranceDist(w, h);
				
				for (uint i = 0; i < allExits.length(); i++)
				{
					for (uint j = 0; j < allExits.length(); j++)
					{
						auto d = allExits[i] - allExits[j];
						float dist = float(d.x) * float(d.x) + float(d.y) * float(d.y) * (randf() + 0.5);
						if (dist > longestDist && dist > minDist)
						{
							longestDist = dist;
							points = ivec2(i, j);
							
							if (randi(100) < 10)
							{
								i = 10000;
								j = 10000;
								break;
							}
						}
					}
				}
				
				if (longestDist < minDist * minDist)
					continue;
				
				auto pos = allExits[points.x] + ivec2(1, 2);
				m_brush.AddPointOfInterest(PointOfInterestType::Entry, pos.x + 1, pos.y + 1);
				for (int i = 0; i < 7; i++)
				{
					m_brush.SetCell(pos.x + 1, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 1, pos.y + i);
					m_brush.SetCell(pos.x + 2, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 2, pos.y + i);
				}
				
				startPos = ivec2(pos.x + 1, pos.y + 4);
				
				for (int y = 2; y <= 7; y++)
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
				for (int i = 0; i < 7; i++)
				{
					m_brush.SetCell(pos.x + 1, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 1, pos.y + i);
					m_brush.SetCell(pos.x + 2, pos.y + i, Cell::Reserved);
					m_brush.SetConsumed(pos.x + 2, pos.y + i);
				}
			}
			
			MakeCliffs(MaxCliffNum, 400);
			
			PrefabPlacement placer(m_brush, ptrnMtch);
			
			if (m_placeActShortcut)
				placer.PlacePrefab(PointOfInterestType::PrefabActShortcut, 1);
			
			if (Prefabs)
			{
				%PROFILE_START Prefabs
				
				PlacePrefabs(placer);

				%PROFILE_STOP
			}
			
			if (m_requireStatues && placer.PlacePrefab(PointOfInterestType::Prefab2x2Block, 3) < 3)
				continue;
			
			PlaceCrateBreakables(w, h);
			
			m_brush.GenerateNothingness();
			
			PlaceEnemies(scene, startPos);
			
			break;
		}
		
		m_brush.Build(scene);
	}
	
	
	void PlacePrefabs(PrefabPlacement@ placer)
	{
		array<PointOfInterestType> specials = { 
			PointOfInterestType::Prefab13x13North,
			PointOfInterestType::Prefab9x9North,
			PointOfInterestType::Prefab5x5North,
			PointOfInterestType::Prefab3x3North
			
			//PointOfInterestType::Prefab9x9South,
			//PointOfInterestType::Prefab5x5South,
		};

		placer.PlacePrefabs(specials, 2);
		

		
		array<PointOfInterestType> chestSpots = { 
			PointOfInterestType::Prefab14x14North2, 
			PointOfInterestType::Prefab14x14South2, 
			PointOfInterestType::Prefab13x13West, 
			PointOfInterestType::Prefab13x13East, 
			PointOfInterestType::Prefab13x13Block 
		};
		
		placer.PlacePrefabs(chestSpots, 2);


		
		placer.PlacePrefab(PointOfInterestType::Prefab10x10North2, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab10x10South2, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab6x6North2, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab6x6South2, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9East, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9West, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab5x5East, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab5x5West, 2);
		
		placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 1);
		placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 3);
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 4);
		
		placer.PlacePrefab(PointOfInterestType::Prefab4x6Path, 3);
		placer.PlacePrefab(PointOfInterestType::Prefab6x4Path, 3);
		
		if (randi(2) == 0)
			placer.PlacePrefab(PointOfInterestType::Prefab9x3Cliff, 1);
		else
			placer.PlacePrefab(PointOfInterestType::Prefab3x9Cliff, 1);
		
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Cliff, 5);
	}
}