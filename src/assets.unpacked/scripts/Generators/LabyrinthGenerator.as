[Generator]
class LabyrinthGenerator : DungeonGenerator
{
	[Editable default="moon_temple_poor"]
	string Set;

	[Editable default="temple_poor"]
	string ColorTheme;
	
	[Editable default=25]
	int RoomSections;

	[Editable default=0.2]
	float ReserveSections;
	
	[Editable default=0.3]
	float DoorwaysMin;
	[Editable default=0.3]
	float DoorwaysMax;
	
	
	int RoomSectionHeightLimit = -1;
	int RoomSectionWidthLimit = -1;
	float RoomSectionTightnessLimit = 2.5f;
	
	
	int m_width;
	int m_height;
	ivec2 m_padding;
	
	array<array<uint8>>@ m_grid;
	array<array<uint8>>@ m_gridPlaced;
	array<array<uint8>>@ m_gridForced;
	array<array<uint8>>@ m_gridForcedPlaced;
	array<LabyrinthDoorway@> m_doorways;
	array<vec2> m_startPositions;
	array<PlacedLabyrinthRoom@> m_placedRooms;
	
	int m_posSumX;
	int m_posSumY;
	int m_posSum;
	
	bool AddRoom(LabyrinthSetRoom@ room, int x, int y)
	{
		vec2 pos(256 * (x - m_width / 2) + room.m_offset.x, 256 * (y - m_height / 2) + room.m_offset.y);
		g_prefabsToSpawn.insertLast(PrefabToSpawn(room.m_prefab, xyz(pos), true));
		room.m_reqs.m_tmpInUse++;
		//print("Placing room '" + room.m_prefab.GetDebugName() + "' nr " + room.m_reqs.m_tmpInUse + ", min: " + room.m_reqs.m_tmpRequired + ", max: " + room.m_reqs.m_tmpMax);
		m_placedRooms.insertLast(PlacedLabyrinthRoom(room, ivec2(x, y)));
		
		for (uint i = 0; i < room.m_startPos.length(); i++)
			m_startPositions.insertLast(pos + room.m_startPos[i]);
		
		uint preNumDoorways = m_doorways.length();
		
		array<LabyrinthDoorway@> doorways;
		for (uint i = 0; i < room.m_sections.length(); i++)
		{
			auto@ section = room.m_sections[i];
			
			int xs = x + section.x;
			int ys = y + section.y;
			vec2 soffset(section.x * 256, section.y * 256);
			
			m_posSumX += xs;
			m_posSumY += ys;
			m_posSum++;

			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0 && (m_gridPlaced[xs][ys - 1] & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0)
			{
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0 || (m_gridForcedPlaced[xs][ys - 1] & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0)
					m_doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(128, 0), room));
				else
					doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(128, 0), room.m_hidden));
			}
			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0 && (m_gridPlaced[xs][ys + 1] & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0)
			{
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0 || (m_gridForcedPlaced[xs][ys + 1] & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0)
					m_doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(128, 256), room));
				else
					doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(128, 256), room.m_hidden));
			}

			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0 && (m_gridPlaced[xs - 1][ys] & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0)
			{
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0 || (m_gridForcedPlaced[xs - 1][ys] & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0)
					m_doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(0, 128), room));
				else
					doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(0, 128), room.m_hidden));
			}
			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0 && (m_gridPlaced[xs + 1][ys] & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0)
			{
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0 || (m_gridForcedPlaced[xs + 1][ys] & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0)
					m_doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(256, 128), room));
				else
					doorways.insertLast(LabyrinthDoorway(pos + soffset + vec2(256, 128), room.m_hidden));
			}
			

			m_grid[xs][ys] = uint8(LabyrinthSetRoomSectionInfo::InUse);
			m_gridPlaced[xs][ys] = section.doors;
			m_gridForcedPlaced[xs][ys] = section.doorsForced;

			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0)
				m_grid[xs][ys - 1] |= uint8(LabyrinthSetRoomSectionInfo::SouthDoor);
			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0)
				m_grid[xs][ys + 1] |= uint8(LabyrinthSetRoomSectionInfo::NorthDoor);
				
			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0)
				m_grid[xs - 1][ys] |= uint8(LabyrinthSetRoomSectionInfo::EastDoor);
			if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0)
				m_grid[xs + 1][ys] |= uint8(LabyrinthSetRoomSectionInfo::WestDoor);
				
			
			if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0)
				m_gridForced[xs][ys - 1] |= uint8(LabyrinthSetRoomSectionInfo::SouthDoor);
			if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0)
				m_gridForced[xs][ys + 1] |= uint8(LabyrinthSetRoomSectionInfo::NorthDoor);
				
			if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0)
				m_gridForced[xs - 1][ys] |= uint8(LabyrinthSetRoomSectionInfo::EastDoor);
			if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0)
				m_gridForced[xs + 1][ys] |= uint8(LabyrinthSetRoomSectionInfo::WestDoor);
		}

		int numDoorways = min(doorways.length(), max(1, int(doorways.length() * lerp(DoorwaysMin, DoorwaysMax, randf()))));
		for (int i = 0; i < numDoorways; i++)
		{
			int idx = randi(doorways.length());
			m_doorways.insertLast(doorways[idx]);
			doorways.removeAt(idx);
		}

		return room.m_disconnected || (m_doorways.length() > preNumDoorways);
	}
	
	
	
	LabyrinthSetRoom@ PickRequiredRoom(array<LabyrinthSetRoom@>@ rooms)
	{
		int totRoomChance = 0;
		int noChance = 0;
		
		for (uint i = 0; i < rooms.length(); i++)
		{
			if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
				continue;
			
			if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpRequired)
				continue;

			if (rooms[i].m_chance <= 0)
				noChance++;
			else
				totRoomChance += rooms[i].m_chance;
		}
		
		if (totRoomChance > 0)
		{
			int r = randi(totRoomChance);
			for (uint i = 0; i < rooms.length(); i++)
			{
				if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
					continue;
				
				if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpRequired)
					continue;
			
				r -= rooms[i].m_chance;
				if (r <= 0)
					return rooms[i];
			}
		}
		
		if (noChance > 0)
		{
			int r = randi(noChance);
			for (uint i = 0; i < rooms.length(); i++)
			{
				if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
					continue;
				
				if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpRequired)
					continue;
			
				if (rooms[i].m_chance > 0)
					continue;
					
				r--;
				if (r <= 0)
					return rooms[i];
			}
		
		}
		
		return null;
	}
	
	
	LabyrinthSetRoom@ PickRoom(array<LabyrinthSetRoom@>@ rooms, LabyrinthSetRoom@ lowPrioRoom = null)
	{
		int totRoomChance = 0;
		for (uint i = 0; i < rooms.length(); i++)
		{
			if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
				continue;
				
			if (rooms[i] is lowPrioRoom)
				totRoomChance += rooms[i].m_chance / 3;
			else
				totRoomChance += rooms[i].m_chance;
		}

		int r = randi(totRoomChance);
		for (uint i = 0; i < rooms.length(); i++)
		{
			if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
				continue;

			if (rooms[i] is lowPrioRoom)
				r -= rooms[i].m_chance / 3;
			else
				r -= rooms[i].m_chance;
				
			if (r <= 0)
				return rooms[i];
		}
		
		return null;
	}
	
	
	int GetPositionWeight(LabyrinthSetRoom@ room, int x, int y, bool mustExpand)
	{
		bool checkBonusExpandScore = false;
		bool valid = room.m_disconnected;
		int weight = 1;
		
		for (uint i = 0; i < room.m_sections.length(); i++)
		{
			auto@ section = room.m_sections[i];
			int xs = x + section.x;
			int ys = y + section.y;
			
			if (m_grid[xs][ys] & uint8(LabyrinthSetRoomSectionInfo::InUse) != 0)
				return -1;

			if (m_gridForced[xs][ys] != 0)
			{
				if (room.m_hidden)
					return -1;

				if ((m_gridForced[xs][ys] & section.doors) != m_gridForced[xs][ys])
					return -1;
				
				weight += 4;
				
				if (mustExpand)
				{
					mustExpand = false;
					checkBonusExpandScore = true;
				}
			}

			if (section.doorsForced != 0)
			{
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0 && (m_grid[xs][ys - 1] & uint8(LabyrinthSetRoomSectionInfo::InUse)) != 0 
					&& m_grid[xs][ys] & uint8(LabyrinthSetRoomSectionInfo::NorthDoor) == 0)
					return -1;
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0 && (m_grid[xs][ys + 1] & uint8(LabyrinthSetRoomSectionInfo::InUse)) != 0 
					&& m_grid[xs][ys] & uint8(LabyrinthSetRoomSectionInfo::SouthDoor) == 0)
					return -1;
					
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0 && (m_grid[xs - 1][ys] & uint8(LabyrinthSetRoomSectionInfo::InUse)) != 0 
					&& m_grid[xs][ys] & uint8(LabyrinthSetRoomSectionInfo::WestDoor) == 0)
					return -1;
				if ((section.doorsForced & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0 && (m_grid[xs + 1][ys] & uint8(LabyrinthSetRoomSectionInfo::InUse)) != 0 
					&& m_grid[xs][ys] & uint8(LabyrinthSetRoomSectionInfo::EastDoor) == 0)
					return -1;
					
				weight += 2;
			}

			if ((m_grid[xs][ys] & section.doors) != 0)
				valid = true;
		}
		
		if (!valid)
			return -1;
			
		if (room.m_disconnected)
			return 1;
		
		if (mustExpand || checkBonusExpandScore)
		{
			int possibleDoorways = 0;
			for (uint i = 0; i < room.m_sections.length(); i++)
			{
				auto@ section = room.m_sections[i];
				int xs = x + section.x;
				int ys = y + section.y;

				if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::NorthDoor)) != 0 && (m_grid[xs][ys - 1] & uint8(LabyrinthSetRoomSectionInfo::InUse)) == 0)
					possibleDoorways++;
				if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::SouthDoor)) != 0 && (m_grid[xs][ys + 1] & uint8(LabyrinthSetRoomSectionInfo::InUse)) == 0)
					possibleDoorways++;
				if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::WestDoor)) != 0 && (m_grid[xs - 1][ys] & uint8(LabyrinthSetRoomSectionInfo::InUse)) == 0)
					possibleDoorways++;
				if ((section.doors & uint8(LabyrinthSetRoomSectionInfo::EastDoor)) != 0 && (m_grid[xs + 1][ys] & uint8(LabyrinthSetRoomSectionInfo::InUse)) == 0)
					possibleDoorways++;

				uint8 g = m_grid[xs][ys];
				if (g & uint8(LabyrinthSetRoomSectionInfo::NorthDoor) != 0)
					possibleDoorways--;
				if (g & uint8(LabyrinthSetRoomSectionInfo::SouthDoor) != 0)
					possibleDoorways--;
				if (g & uint8(LabyrinthSetRoomSectionInfo::WestDoor) != 0)
					possibleDoorways--;
				if (g & uint8(LabyrinthSetRoomSectionInfo::EastDoor) != 0)
					possibleDoorways--;
			}
			
			if (mustExpand && possibleDoorways < 0)
				return -1;

			if (possibleDoorways > 1)
				weight *= 3;
		}
	
		return weight;
	}
	
	bool CheckRoomConstraints(LabyrinthSetRoom@ room, int x, int y)
	{
		array<LabyrinthSetRoomConstraint@>@ constr = room.m_reqs.m_constraints;
	
		for (uint c = 0; c < constr.length(); c++)
		{
			for (uint r = 0; r < m_placedRooms.length(); r++)
			{
				if (constr[c].m_roomReq !is m_placedRooms[r].m_room.m_reqs)
					continue;
				
				float xd = (m_placedRooms[r].m_pos.x - m_placedRooms[r].m_room.m_size.x / 2.0f) - (x - 0.5f);
				float yd = (m_placedRooms[r].m_pos.y - m_placedRooms[r].m_room.m_size.y / 2.0f) - (y - 0.5f);
				float distSq = xd * xd + yd * yd;
				
				if (distSq < constr[c].m_minDistSq)
					return false;
				
				if (distSq > constr[c].m_maxDistSq)
					return false;
			}
		
		}
	
		return true;
	}
	
	
	ivec2 FindPosition(LabyrinthSetRoom@ room, bool mustExpand)
	{
		ivec2 bestPos(-1, -1);
		int bestScore = 10000;

		int midX = m_width / 2 + m_padding.x;
		int midY = m_height / 2 + m_padding.y;
		
		if (m_posSum > 0)
		{
			midX = m_posSumX / m_posSum;
			midY = m_posSumY / m_posSum;
		}

		switch(room.m_placement)
		{
		case LabyrinthRoomPlacementStrategy::Top:
			for (int x = m_padding.x; x < m_width - m_padding.x; x++)
			{
				for (int y = m_padding.y; y < midY; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(0, m_height - y);
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;
		
		case LabyrinthRoomPlacementStrategy::Left:
			for (int x = m_padding.x; x < midX; x++)
			{
				for (int y = m_padding.y; y < m_height - m_padding.y; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(m_width - x, 0);
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;
		
		case LabyrinthRoomPlacementStrategy::Middle:
			for (int x = m_padding.x; x < m_width - m_padding.x; x++)
			{
				for (int y = m_padding.y; y < m_height - m_padding.y; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(m_width / 2 - x, m_height / 2 - y);
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;
			
		case LabyrinthRoomPlacementStrategy::Right:
			for (int x = midX; x < m_width - m_padding.x; x++)
			{
				for (int y = m_padding.y; y < m_height - m_padding.y; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(0, x);
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;
		
		case LabyrinthRoomPlacementStrategy::Bottom:
			for (int x = m_padding.x; x < m_width - m_padding.x; x++)
			{
				for (int y = midY; y < m_height - m_padding.y; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(0, y);
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;

		case LabyrinthRoomPlacementStrategy::Spread:
			for (int x = m_padding.x; x < m_width - m_padding.x; x++)
			{
				for (int y = m_padding.y; y < m_height - m_padding.y; y++)
				{
					int w = GetPositionWeight(room, x, y, mustExpand);
					if (w > 0)
					{
						ivec2 d(max(x, m_width - x), max(y, m_height - y));
						int score = int((d.x * d.x + d.y * d.y) * (randf() + 0.5f) / w);
						
						if (score < bestScore && CheckRoomConstraints(room, x, y))
						{
							bestScore = score;
							bestPos = ivec2(x, y);
						}
					}
				}
			}
			break;
		}

		return bestPos;
	}
	
	void CalcDimensions()
	{
		if (RoomSectionWidthLimit > 0)
		{
			print("RoomSectionWidthLimit: " + RoomSectionWidthLimit);
			m_width = RoomSectionWidthLimit + m_padding.x * 2;
			m_height = int(ceil(RoomSectionTightnessLimit * RoomSectionTightnessLimit * RoomSections / RoomSectionWidthLimit)) + m_padding.y * 2;
		}
		else if (RoomSectionHeightLimit > 0)
		{
			print("RoomSectionHeightLimit: " + RoomSectionHeightLimit);
			m_height = RoomSectionHeightLimit + m_padding.y * 2;
			m_width = int(ceil(RoomSectionTightnessLimit * RoomSectionTightnessLimit * RoomSections / RoomSectionHeightLimit)) + m_padding.x * 2;
		}
		else
		{
			print("RoomSectionTightnessLimit: " + RoomSectionTightnessLimit);
			m_width = m_height = int(ceil(sqrt(RoomSections) * RoomSectionTightnessLimit));
			m_width += m_padding.x * 2;
			m_height += m_padding.y * 2;
		}
		
		print("sz: " + m_width + "x" + m_height);
	}
	
	
	void Generate(Scene@ scene) override
	{
		LabyrinthSet@ labSet = null;
		g_labyrinthSets.get(Set, @labSet);
		
		if (labSet is null)
		{
			print("Couldn't find labyrinth set " + Set);
			return;
		}

		auto@ rooms = labSet.m_rooms;
		for (uint i = 0; i < rooms.length(); i++)
		{
			m_padding.x = max(m_padding.x, rooms[i].m_size.x);
			m_padding.y = max(m_padding.y, rooms[i].m_size.y);
			
			rooms[i].m_reqs.m_tmpRequired = rooms[i].m_reqs.m_required;
			rooms[i].m_reqs.m_tmpMax = rooms[i].m_reqs.m_max;
		}

		
		array<string>@ reqKeys = labSet.m_roomReqs.getKeys();
		for (uint i = 0; i < reqKeys.length(); i++)
		{
			LabyrinthSetRoomReq@ req;
			labSet.m_roomReqs.get(reqKeys[i], @req);

			if (req is null)
				continue;

			//req.m_tmpRequired = req.m_required;
			//req.m_tmpMax = req.m_max;

			for (uint j = 0; j < req.m_mods.length(); j++)
			{
				if (!g_flags.IsSet(req.m_mods[j].m_flag))
					continue;
				
				req.m_tmpRequired += req.m_mods[j].m_required;
				req.m_tmpMax += req.m_mods[j].m_max;
			}
		}
		/*
		for (uint i = 0; i < reqKeys.length(); i++)
		{
			LabyrinthSetRoomReq@ req;
			labSet.m_roomReqs.get(reqKeys[i], @req);

			if (req is null)
				continue;
			
			print("req: " + reqKeys[i] + ": " + req.m_tmpRequired + " - " + req.m_tmpMax);
		}
		*/
		
		CalcDimensions();
		
		array<ivec2> reserved;
		int counter = 0;
		int roomPlaceAttempts = RoomSections * 10;
		
		int totAttempts = 0;
		while (true)
		{
			print("Generating level...");
			
			totAttempts++;
			if (counter++ > 15)
			{
				counter = 0;
				RoomSectionTightnessLimit = max(1.0f, RoomSectionTightnessLimit * 1.1f);
				ReserveSections *= 0.9f;
				// roomPlaceAttempts = int((roomPlaceAttempts + 5) * 1.1f);
				CalcDimensions();
			}
			
			for (uint i = 0; i < rooms.length(); i++)
				rooms[i].m_reqs.m_tmpInUse = 0;
			
			
			@m_grid = array<array<uint8>>(m_width, array<uint8>(m_height, 0));
			@m_gridPlaced = array<array<uint8>>(m_width, array<uint8>(m_height, 0));
			@m_gridForced = array<array<uint8>>(m_width, array<uint8>(m_height, 0));
			@m_gridForcedPlaced = array<array<uint8>>(m_width, array<uint8>(m_height, 0));
			
			g_prefabsToSpawn.removeRange(0, g_prefabsToSpawn.length());
			m_doorways.removeRange(0, m_doorways.length());
			m_startPositions.removeRange(0, m_startPositions.length());
			m_placedRooms.removeRange(0, m_placedRooms.length());
			reserved.removeRange(0, reserved.length());
			
			bool invalid = false;
			
			m_posSumX = 0;
			m_posSumY = 0;
			m_posSum = 0;



			LabyrinthSetRoom@ initRoom = null;
			for (uint i = 0; i < 100; i++)
			{
				@initRoom = PickRoom(rooms);
				if (initRoom !is null && !initRoom.m_hidden)
					break;
			}
			
			AddRoom(initRoom, (m_width - initRoom.m_size.x) / 2, (m_height - initRoom.m_size.y) / 2);
			
			
			int reserve = int((m_width - m_padding.x * 2) * (m_height - m_padding.y * 2) * ReserveSections);
			for (int i = 0; i < reserve; i++)
			{
				int x = randi(m_width - m_padding.x * 2) + m_padding.x;
				int y = randi(m_height - m_padding.y * 2) + m_padding.y;
			
				if (m_grid[x][y] & uint8(LabyrinthSetRoomSectionInfo::InUse) != 0)
					continue;
			
				m_grid[x][y] = uint8(LabyrinthSetRoomSectionInfo::InUse);
				reserved.insertLast(ivec2(x, y));
			}			
			
			int expandCounter = 0;
			int sects = RoomSections;
			LabyrinthSetRoom@ lastRoom = null;
			for (int i = 0; i < roomPlaceAttempts; i++)
			{
				//auto@ room = randf() < 0.5f ? PickRoom(rooms, lastRoom) : PickRequiredRoom(rooms);
				auto@ room = PickRoom(rooms, lastRoom);
				@lastRoom = room;
				if (room is null)
				{
					//print("Room is null");
					continue;
				}
				
				ivec2 pos = FindPosition(room, --expandCounter > 0);
				if (pos.x < 0)
				{
					// print("No position : " + room.m_prefab.GetDebugName());
					continue;
				}
				
				if (!AddRoom(room, pos.x, pos.y))
				{
					invalid = true;
					print("AddRoom failed");
				}
				else
					expandCounter = 3;
				
				sects -= room.m_sections.length();
				if (sects <= 0)
					break;
			}
			
			int breakCount = 25;
			while (true)
			{
				if (breakCount <= 0)
				{
					for (uint i = 0; i < rooms.length(); i++)
					{
						if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpMax)
							continue;
						
						if (rooms[i].m_reqs.m_tmpInUse >= rooms[i].m_reqs.m_tmpRequired)
							continue;
						
						ivec2 pos = FindPosition(rooms[i], false);
						if (pos.x < 0)
							continue;
						
						if (AddRoom(rooms[i], pos.x, pos.y))
						{
							breakCount = 25;
							break;
						}
						else
						{
							invalid = true;
							print("AddRoom failed");
						}
					}
				
					if (breakCount <= 0)
					{
						print("Failed placing all required rooms:");
						for (uint i = 0; i < rooms.length(); i++)
						{
							int use = rooms[i].m_reqs.m_tmpInUse;
							int max = rooms[i].m_reqs.m_tmpMax;
							if (use >= max)
								continue;
							
							int req = rooms[i].m_reqs.m_tmpRequired;
							if (use >= req)
								continue;
								
							print("  " + rooms[i].m_prefab.GetDebugName() + "(" + req + " < " + use + " < " + max + ", " + rooms[i].m_reqs.m_name + ")");
						}
						
						invalid = true;
					}
					
					break;
				}
			
				auto room = PickRequiredRoom(rooms);
				if (room is null)
					break;

				ivec2 pos = FindPosition(room, --expandCounter > 0);
				if (pos.x < 0)
				{
					breakCount--;
					continue;
				}
				
				if (!AddRoom(room, pos.x, pos.y))
				{
					print("AddRoom failed");
					invalid = true;
					break;
				}
				else
					expandCounter = 2;
					
				sects -= room.m_sections.length();
			}

			if (sects > (RoomSections / 15))
			{
				print("Failed to place all room sections, missing " + sects);
				continue;
			}

			for (uint i = 0; i < rooms.length(); i++)
			{
				if (rooms[i].m_reqs.m_tmpInUse > rooms[i].m_reqs.m_tmpMax)
				{
					print("Too many of room " + rooms[i].m_prefab.GetDebugName());
					invalid = true;
					break;
				}
				
				if (rooms[i].m_reqs.m_tmpInUse < rooms[i].m_reqs.m_tmpRequired)
				{
					print("Too few of room " + rooms[i].m_prefab.GetDebugName());
					invalid = true;
					break;
				}
			}
			
			if (invalid)
			{
				print("inv 1");
				continue;
			}

			int numSections = 0;
			for (int x = 0; x < m_width && !invalid; x++)
			{
				for (int y = 0; y < m_height; y++)
				{
					if (m_grid[x][y] & uint8(LabyrinthSetRoomSectionInfo::InUse) != 0)
					{
						numSections++;
						continue;
					}
				
					if (m_gridForced[x][y] != 0)
					{
						print("Forced slot");
						invalid = true;
						break;
					}
				}
			}

			for (uint i = 0; i < reserved.length() && !invalid; i++)
			{
				int x = reserved[i].x;
				int y = reserved[i].y;
				
				if (m_gridForced[x][y] != 0)
				{
					print("Reserved forced slot");
					invalid = true;
				}
			}
			
			if (m_startPositions.length() <= 0)
			{
				print("No start positions");
				invalid = true;
			}
			
			if (invalid)
			{
				print("inv 2");
				continue;
			}

			print("Level size: " + (numSections - reserved.length()));
			print("Took " + totAttempts + " attempts");
			
			break;
		}
		
		/// todo: shuffle g_prefabsToSpawn
		
		
		//auto t_default = Resources::GetTileset("tilesets/temples_tiles_poor.tileset");
		//g_scene.PaintTileset(t_default, vec2(0, 0), uint(max(m_width * 256, m_height * 256) * 2.0) + 2000);
		
		auto colorPiece = Resources::GetUnitProducer("doodads/special/color_" + ColorTheme + "_256.unit");
		
		for (int x = 0; x < m_width; x++)
		{
			for (int y = 0; y < m_height; y++)
			{
				if (m_grid[x][y] & uint8(LabyrinthSetRoomSectionInfo::InUse) != 0)
					continue;
					
				vec3 pos(256 * (x - m_width / 2), 256 * (y - m_height / 2) + 256 - 24, 0); // - vec3(8, 8 - 32, 0)
				colorPiece.Produce(scene, pos);
			}
		}
		
		for (uint i = 0; i < reserved.length(); i++)
		{
			int x = reserved[i].x;
			int y = reserved[i].y;
			
			vec3 pos(256 * (x - m_width / 2), 256 * (y - m_height / 2) + 256 - 24, 0); // - vec3(8, 8 - 32, 0)
			colorPiece.Produce(scene, pos);
		}
		
		QueuedTasks::Queue(1, OpenLabyrinthDoorwaysTask(m_doorways));
		g_spawnPos = m_startPositions[randi(m_startPositions.length())];
		
	}
}

class PlacedLabyrinthRoom
{
	LabyrinthSetRoom@ m_room;
	ivec2 m_pos;
	
	PlacedLabyrinthRoom(LabyrinthSetRoom@ room,	ivec2 pos)
	{
		@m_room = room;
		m_pos = pos;
	}
}

class LabyrinthDoorway
{
	vec2 m_pos;
	bool m_hidden;
	
	LabyrinthDoorway(vec2 pos, bool hidden)
	{
		m_pos = pos;
	    m_hidden = hidden;
	}
	
	LabyrinthDoorway(vec2 pos, LabyrinthSetRoom@ room)
	{
		m_pos = pos;
	    m_hidden = room.m_hidden;
		
		//print("Door [" + pos.x + ", " + pos.y + "]: " + (m_hidden ? "hidden" : "not hidden") + " : " + room.m_prefab.GetDebugName());
	}
}

class OpenLabyrinthDoorwaysTask : QueuedTasks::QueuedTask
{
	OpenLabyrinthDoorwaysTask(array<LabyrinthDoorway@>@ doorways)
	{
		@m_doorways = doorways;
	}

	void Execute() override
	{
		//print("== Opening " + m_doorways.length() + " doorways");
	
		for (uint d = 0; d < m_doorways.length(); d++)
		{
			auto res = g_scene.FetchWorldScripts("GlobalEventTrigger", m_doorways[d].m_pos, 32);
			string eventName = m_doorways[d].m_hidden ? "create_door_hidden" : "create_door";
			
			//print("== Doorway [" + m_doorways[d].x + ", " + m_doorways[d].y + "]: " + res.length());
			
			for (uint i = 0; i < res.length(); i++)
			{
				auto script = res[i];
				if (!script.IsEnabled())
					continue;

				auto trigger = cast<WorldScript::GlobalEventTrigger>(script.GetUnit().GetScriptBehavior());
				if (trigger is null)
					continue;

				if (trigger.EventName != eventName)
					continue;

				script.Execute();
			}
		}
	}
	
	array<LabyrinthDoorway@>@ m_doorways;
}

