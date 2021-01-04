[Generator]
class PyramidFancyGenerator : ArmoryGenerator
{
	[Editable default=10]
	int LoopNum;
	
	
	bool MakeInitialState() override
	{
		m_requireStatues = false;
		int w = Width / 16;
		int h = Height / 16;
		int padding = RoomSize + 12;
		
		int dx = (randi(15) + 1) * (randi(100) < 50 ? 1 : -1);
		int dy = (randi(15) + 1) * (randi(100) < 50 ? 1 : -1);
		
		ivec2 rpos(w / 2 - dx, h / 2 - dy);
		ivec2 rsz(clamp(dx * 1000, -(w / 2 - padding), w / 2 - padding), clamp(dy * 1000, -(h / 2 - padding), h / 2 - padding));
		
//		MakeRoomRect(rpos.x, rpos.y, rsz.x, rsz.y);
//		MakeRoomRect(rpos.x + rsz.x / 2, rpos.y + rsz.y / 2, -rsz.x, -rsz.y);

		ivec4 prevRect = MakeCorridorRect(rpos.x, rpos.y, rsz.x, rsz.y, 12);
		ivec4 origRect = prevRect;
		
		bool prevFlag = false;
		for (int i = 2 + LoopNum; i > 2; i--)
		{
			int thickness = randi(2) == 0 ? 12 : 8;
		
			int rw = randi(w/6) + 4 + thickness * 2;
			int rh = randi(h/6) + 4 + thickness * 2;
			
			int rx = (randi(2) == 0) ? (prevRect.x - rw) : (prevRect.x + prevRect.z);
			int ry = (randi(2) == 0) ? (prevRect.y - rh) : (prevRect.y + prevRect.w);
			
			if (rx < padding || ry < padding || (rx + rw) >= (w - padding) || (ry + rh) >= (h - padding))
			{
				i++;
				continue;
			}
			
			prevRect = MakeCorridorRect(rx, ry, rw, rh, thickness);
			if (!prevFlag && randi(100) <= 75)
			{
				prevRect = origRect;
				prevFlag = true;
			}
			else
				prevFlag = false;
		}
		
		//MakeCorridorRect(rpos.x, rpos.y, rsz.x, rsz.y, 6);
		//MakeCorridorRect(rpos.x - rsz.x / 2, rpos.y - rsz.y / 2, rsz.x, rsz.y, 4);

		return true;
	}
	
	float GetMinEntranceDist(int w, int h) override
	{
		return min(w, h) / 5.f;
	}
	
	ivec4 MakeCorridorRect(int x, int y, int w, int h, int thickness = 2)
	{
		if (w < 0)
		{
			x += w;
			w *= -1;
		}
		
		if (h < 0)
		{
			y += h;
			h *= -1;
		}
		
		x -= x % 2;
		y -= y % 2;
		w += w % 2;
		h += h % 2;
	
		int d = (thickness + 2) / 2;
		
		PlotLine(ivec2(x, y), ivec2(x + w, y), 2 + thickness, Cell::Floor);
		PlotLine(ivec2(x, y - d), ivec2(x, y + h), thickness, Cell::Floor);
		PlotLine(ivec2(x + w, y + h), ivec2(x, y + h), 2 + thickness, Cell::Floor);
		PlotLine(ivec2(x + w, y + h), ivec2(x + w, y - d), thickness, Cell::Floor);
		
		return ivec4(x, y, w, h);
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
			
			PrefabPlacement placer(m_brush, ptrnMtch);
			
			
			ivec2 startPos;
			
			{
				auto pattern = placer.CreatePrefabPattern(PointOfInterestType::Prefab13x13Block);
				if (pattern is null)
					continue;
				
				auto poses = ptrnMtch.ReservePrefabs(m_brush, pattern.m_pattern, pattern.m_command, 1);
				if (poses.length() <= 0)
					continue;
				
				auto pos = poses[0] + pattern.m_placementOffset;
				m_brush.AddPointOfInterest(PointOfInterestType::Entry, pos.x, pos.y);
			
				startPos = ivec2(pos.x + 5, pos.y + 5);
				m_startPos = vec2(16 * startPos.x + m_brush.m_posOffset.x + 24, 16 * startPos.y + m_brush.m_posOffset.y + 24);
				g_spawnPos = m_startPos;
			
			}
			
			
			print("Make cliffs:");
			MakeCliffs(MaxCliffNum, 400);
			
			if (m_placeActShortcut)
				placer.PlacePrefab(PointOfInterestType::PrefabActShortcut, 1);
			
			if (Prefabs)
			{
				%PROFILE_START Prefabs
				
				print("Place prefabs:");
				PlacePrefabs(placer);

				%PROFILE_STOP
			}
			
			if (m_requireStatues && placer.PlacePrefab(PointOfInterestType::Prefab2x2Block, 3) < 3)
				continue;
			
			print("Place crates:");
			PlaceCrateBreakables(w, h);
			
			print("Make nothing:");
			m_brush.GenerateNothingness();
			
			print("Place enemies:");
			PlaceEnemies(scene, startPos);
			
			break;
		}
		
		m_brush.Build(scene);
	}
	
	
	void CleanupPatterns(PatternMatcher@ ptrnMtch) override
	{
		ptrnMtch.RemoveDiagonals(m_brush);
		
		
		array<array<Pattern>> ptrn = {
			{Pattern::Walkable, Pattern::Wall, Pattern::Walkable},
			{Pattern::Walkable, Pattern::Wall, Pattern::Walkable},
			{Pattern::Walkable, Pattern::Wall, Pattern::Walkable}
		};

		auto res = ptrnMtch.FindAllPatterns(m_brush, ptrn);
	
		for (uint i = 0; i < res.length(); i++)
		{
			m_brush.SetCell(res[i].x + 1, res[i].y + 0, Cell::Floor);
			m_brush.SetCell(res[i].x + 1, res[i].y + 1, Cell::Floor);
			m_brush.SetCell(res[i].x + 1, res[i].y + 2, Cell::Floor);
		}
	}
	
	void PlacePrefabs(PrefabPlacement@ placer) override
	{
		array<PointOfInterestType> specials = { 
			PointOfInterestType::Prefab13x13North,
			PointOfInterestType::Prefab9x9North,
			PointOfInterestType::Prefab5x5North,
			PointOfInterestType::Prefab3x3North
			
			//PointOfInterestType::Prefab9x9South,
			//PointOfInterestType::Prefab5x5South
		};

		placer.PlacePrefabs(specials, 4);
	

		array<PointOfInterestType> megaChestSpots = {
			PointOfInterestType::Prefab22x22North2,
			PointOfInterestType::Prefab22x22South2,
			PointOfInterestType::Prefab21x21East,
			PointOfInterestType::Prefab21x21West
		};
		
		placer.PlacePrefabs(megaChestSpots, 2, 1);

	
		array<PointOfInterestType> chestSpots = {
			PointOfInterestType::Prefab14x14North2, 
			PointOfInterestType::Prefab14x14South2, 
			PointOfInterestType::Prefab13x13West, 
			PointOfInterestType::Prefab13x13East
		};
		
		placer.PlacePrefabs(chestSpots, 4);
	
	
		array<PointOfInterestType> rooms = {
			PointOfInterestType::Prefab10x10North2,
			PointOfInterestType::Prefab10x10South2,
			PointOfInterestType::Prefab6x6North2,
			PointOfInterestType::Prefab6x6South2,
			PointOfInterestType::Prefab9x9East,
			PointOfInterestType::Prefab5x5East,
			PointOfInterestType::Prefab9x9West,
			PointOfInterestType::Prefab5x5West
		};
		
		placer.PlacePrefabs(rooms, 20, 5);

		
		placer.PlacePrefab(PointOfInterestType::Prefab21x21Block, 3);
		placer.PlacePrefab(PointOfInterestType::Prefab13x13Block, 4);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 3);
		
		placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 5);
		placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 6);
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 7);

		for (int i = 0; i < 3; i++)
		{
			placer.PlacePrefab(PointOfInterestType::Prefab7x12Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab6x12Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab5x12Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab6x8Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab12x8Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab12x6Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab8x4Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab6x4Path, 2);
			placer.PlacePrefab(PointOfInterestType::Prefab4x6Path, 2);
		}
		
		placer.PlacePrefab(PointOfInterestType::Prefab13x13Cliff, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9Cliff, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab9x3Cliff, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab3x9Cliff, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Cliff, 5);
		
		
		
		array<PointOfInterestType> wallBlocks;
		
		wallBlocks = {
			PointOfInterestType::Prefab12x7BlockNorthInverted,
			PointOfInterestType::Prefab12x7BlockSouthInverted,
			PointOfInterestType::Prefab7x12BlockEastInverted,
			PointOfInterestType::Prefab7x12BlockWestInverted
		};

		for (int i = 0; i < 2; i++)
			placer.PlacePrefabs(wallBlocks, 8, 3);
			
			
		wallBlocks = {
			PointOfInterestType::Prefab12x5BlockNorth,
			PointOfInterestType::Prefab12x5BlockSouth,
			PointOfInterestType::Prefab5x12BlockEast,
			PointOfInterestType::Prefab5x12BlockWest
		};

		for (int i = 0; i < 3; i++)
			placer.PlacePrefabs(wallBlocks, 8 + int(g_ngp) * 2, 3 + int(g_ngp));
			
			
		wallBlocks = {
			PointOfInterestType::Prefab5x5BlockNorth,
			PointOfInterestType::Prefab5x5BlockSouth,
			PointOfInterestType::Prefab5x6BlockEast,
			PointOfInterestType::Prefab5x6BlockWest
		};

		for (int i = 0; i < 3; i++)
			placer.PlacePrefabs(wallBlocks, 8 + int(g_ngp) * 2, 3 + int(g_ngp));
			
		for (int i = 0; i < 3; i++)	
			placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 3);
	}
}