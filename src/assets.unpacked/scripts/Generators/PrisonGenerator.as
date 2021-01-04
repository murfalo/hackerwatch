[Generator]
class PrisonGenerator : MinesGenerator
{
	void FinalizeRoom(ivec2 tl, ivec2 br) override
	{
		int xpos = (tl.x + br.x) / 2;
		if ((xpos - tl.x) >= 3 && (br.x - xpos) >= 3 && randi(100) < 75)
		{
			m_brush.SetCell(xpos, tl.y, Cell::Wall);
			m_brush.SetCell(xpos, br.y, Cell::Wall);
			
			if (randi(100) < 50)
			{
				m_brush.SetCell(xpos, tl.y + 1, Cell::Wall);
				m_brush.SetCell(xpos, br.y - 1, Cell::Wall);
			}
			
			return;
		}
		
		int ypos = (tl.y + br.y) / 2;
		if ((ypos - tl.y) >= 3 && (br.y - ypos) >= 3 && randi(100) < 75)
		{
			m_brush.SetCell(tl.x, ypos, Cell::Wall);
			m_brush.SetCell(br.x, ypos, Cell::Wall);
			
			if (randi(100) < 50)
			{
				m_brush.SetCell(tl.x + 1, ypos, Cell::Wall);
				m_brush.SetCell(br.x - 1, ypos, Cell::Wall);
			}
			
			return;
		}
	}

	void PlaceBreakables() override
	{
		int w = Width / 16;
		int h = Height / 16;
		
		PlaceCrateBreakables(w, h);
	}

	float MakeInitialState(array<ivec2>@ junctions, array<ivec2>@ rooms) override
	{
		int w = Width / 16;
		int h = Height / 16;
	
		TryMakeRoom(junctions, ivec2(w / 2, h / 2), 12, 14);
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

		placer.PlacePrefabs(specials, 2);
	
	
	
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
		
		placer.PlacePrefab(PointOfInterestType::Prefab13x13Block, 1);
		placer.PlacePrefab(PointOfInterestType::Prefab9x9Block, 1);
		
		bool valid = false;
		
		valid = (placer.PlacePrefab(PointOfInterestType::Prefab7x7Block, 2 + int(g_ngp)) > 0) || valid;
		valid = (placer.PlacePrefab(PointOfInterestType::Prefab5x5Block, 3 + int(g_ngp)) > 0) || valid;
		valid = (placer.PlacePrefab(PointOfInterestType::Prefab3x3Block, 4 + int(g_ngp)) > 0) || valid;
		
		if (!m_brush.HasPointOfInterest(PointOfInterestType::Prefab7x7Block) &&
			!m_brush.HasPointOfInterest(PointOfInterestType::Prefab5x5Block) &&
			!m_brush.HasPointOfInterest(PointOfInterestType::Prefab3x3Block))
			valid = true;
		
		if (!valid)
			return false;
		
		FillDeadEnds(placer.m_ptrnMtch, m_brush, NumDeadEndsFill);
		
		placer.PlacePrefab(PointOfInterestType::Prefab2x6Path, 3 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab6x3Path, 3 + int(g_ngp));
		placer.PlacePrefab(PointOfInterestType::Prefab2x3Junction, 3 + int(g_ngp));
		
		array<PointOfInterestType> wallBlocks = { 
			PointOfInterestType::Prefab5x5BlockNorth,
			PointOfInterestType::Prefab5x5BlockSouth,
			PointOfInterestType::Prefab5x6BlockEast,
			PointOfInterestType::Prefab5x6BlockWest
		};

		placer.PlacePrefabs(wallBlocks, 6 + int(g_ngp) * 2, 2 + int(g_ngp));
		
		if (randi(2) == 0)
			placer.PlacePrefab(PointOfInterestType::Prefab9x3Cliff, 1);
		else
			placer.PlacePrefab(PointOfInterestType::Prefab3x9Cliff, 1);
		
		placer.PlacePrefab(PointOfInterestType::Prefab3x3Cliff, 3);
		
		return true;
	}
}