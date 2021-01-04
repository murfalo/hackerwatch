[Generator]
class PyramidGenerator : MinesGenerator
{
	void FinalizeRoom(ivec2 tl, ivec2 br) override
	{
	}

	void PlaceBreakables() override
	{
		int w = Width / 16;
		int h = Height / 16;
		
		PlaceCrateBreakables(w, h);
	}
	
	array<ivec2> GetPathDirections() override { return { ivec2(0, -8), ivec2(0, 8), ivec2(-10, 0), ivec2(10, 0) }; }
	bool TryMakeRoom(array<ivec2>@ junctions, ivec2 pos, int w, int h, bool force = false) override
	{
		if (!MinesGenerator::TryMakeRoom(junctions, pos, w, h, force))
			return false;

		junctions.insertLast(ivec2(pos.x - (w / 2), pos.y));
		junctions.insertLast(ivec2(pos.x + (w / 2), pos.y));
		
		return true;
	}
	
	ivec2 jitterIVec2(ivec2 v, int spread)
	{
		return ivec2(v.x + randi(spread) - spread / 2, v.y + randi(spread) - spread / 2);
	}
	
	void FinalizeState(array<ivec2>@ junctions, array<ivec2>@ rooms) override
	{
		for (uint i = 0; i < rooms.length() * 3; i++)
		{
			int a = randi(rooms.length());
			int b = randi(rooms.length());
			
			if (a == b)
				continue;
				
			auto ar = jitterIVec2(rooms[a], 4);
			auto br = jitterIVec2(rooms[b], 4);
			
			if (abs(ar.x - br.x) > 22)
				continue;
			if (abs(ar.y - br.y) > 22)
				continue;
		
			PlotLine(ivec2(ar.x, br.y), ar, 2, Cell::Floor);
			PlotLine(ivec2(ar.x, br.y), br, 4, Cell::Floor);
		}
	}

	float MakeInitialState(array<ivec2>@ junctions, array<ivec2>@ rooms) override
	{
		int w = Width / 16;
		int h = Height / 16;
	
		TryMakeRoom(junctions, ivec2(w / 2, h / 2), 10, 12);
		rooms.insertLast(ivec2(w / 2, h / 2));
		
		return 1.f;
	}
	
	bool PlacePrefabs(PrefabPlacement@ placer) override
	{
		array<PointOfInterestType> specials = { 
			PointOfInterestType::Prefab13x13North,
			PointOfInterestType::Prefab9x9North,
			PointOfInterestType::Prefab5x5North,
			PointOfInterestType::Prefab3x3North
			
			//PointOfInterestType::Prefab9x9South,
			//PointOfInterestType::Prefab5x5South
		};

		placer.PlacePrefabs(specials, 3);
	
	
	
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
		
		placer.PlacePrefabs(rooms, 11, 3);
		
		placer.PlacePrefab(PointOfInterestType::Prefab13x13Block, 2);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 2);
		
		placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 3 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 4 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 8 + int(g_ngp));
		
		array<PointOfInterestType> wallBlocks = { 
			PointOfInterestType::Prefab5x5BlockNorth,
			PointOfInterestType::Prefab5x5BlockSouth,
			PointOfInterestType::Prefab5x6BlockEast,
			PointOfInterestType::Prefab5x6BlockWest
		};

		placer.PlacePrefabs(wallBlocks, 8 + int(g_ngp) * 2, 3 + int(g_ngp));
		
		FillDeadEnds(placer.m_ptrnMtch, m_brush, NumDeadEndsFill);
		
		placer.PlacePrefabs(wallBlocks, 12 + int(g_ngp) * 4, 6 + int(g_ngp) * 2);
		
		placer.PlacePrefab(PointOfInterestType::Prefab2x6Path, 4 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab6x3Path, 4 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab2x3Junction, 4 + int(g_ngp));
		
		
		
		if (randi(2) == 0)
			placer.PlacePrefab(PointOfInterestType::Prefab9x3Cliff, 1);
		else
			placer.PlacePrefab(PointOfInterestType::Prefab3x9Cliff, 1);
		
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Cliff, 3);
		
		return true;
	}
}