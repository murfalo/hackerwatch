dictionary g_labyrinthSets;

void LoadLabyrinthSet(SValue@ sv)
{
	UnitPtr u;

	auto theme = GetParamString(u, sv, "theme", true);

	LabyrinthSet@ labSet = null;
	g_labyrinthSets.get(theme, @labSet);
	
	if (labSet is null)
		@labSet = LabyrinthSet();
	
	auto arrReqs = GetParamArray(u, sv, "reqs", false);
	if (arrReqs !is null)
	{
		for (uint i = 0; i < arrReqs.length(); i++)
		{
			auto reqSv = arrReqs[i];

			LabyrinthSetRoomReq reqs;
		
			reqs.m_required = GetParamInt(u, reqSv, "required", false, 0);
			reqs.m_max = GetParamInt(u, reqSv, "max", false, 100000);
			reqs.m_name = GetParamString(u, reqSv, "name", true, "");
			
			auto arrMods = GetParamArray(u, reqSv, "modifiers", false);
			if (arrMods !is null)
			{
				for (uint j = 0; j < arrMods.length(); j++)
				{
					auto modSv = arrMods[j];
					reqs.m_mods.insertLast(LabyrinthSetRoomReqMod(
						GetParamString(u, modSv, "flag", true, ""),
						GetParamInt(u, modSv, "required", false, 0),
						GetParamInt(u, modSv, "max", false, 0)
					));
				}
			}
			
			labSet.m_roomReqs.set(reqs.m_name, @reqs);
		}
	}
	
	
	auto arrRooms = GetParamArray(u, sv, "rooms");
	for (uint i = 0; i < arrRooms.length(); i++)
	{
		auto roomSv = arrRooms[i];
		
		auto prefab = Resources::GetPrefab(GetParamString(u, roomSv, "prefab", true));
		if (prefab is null)
			continue;
	
		LabyrinthSetRoomReq@ reqs;
	
		string reqsName = GetParamString(u, roomSv, "reqs", false, "");
		if (reqsName != "")
			labSet.m_roomReqs.get(reqsName, @reqs);
	
		if (reqs is null)
		{
			@reqs = LabyrinthSetRoomReq();
		
			reqs.m_required = GetParamInt(u, roomSv, "required", false, 0);
			reqs.m_max = GetParamInt(u, roomSv, "max", false, 100000);
			reqs.m_name = "non-named";
		}
		
		int chance = max(1, GetParamInt(u, roomSv, "chance", false, 1));
		vec2 offset = GetParamVec2(u, roomSv, "offset", false);
		bool hidden = GetParamBool(u, roomSv, "hidden", false, false);
		auto placement = ParsePlacement(GetParamString(u, roomSv, "placement", false, ""));


		array<vec2> startPos;
		
		SValue@ sPos = roomSv.GetDictionaryEntry("start-pos");
		if (sPos !is null)
		{
			if (sPos.GetType() == SValueType::Array)
			{
				auto arr = sPos.GetArray();
				for (uint k = 0; k < arr.length(); k++)
					startPos.insertLast(arr[k].GetVector2());
			}
			else if (sPos.GetType() == SValueType::Vector2)
				startPos.insertLast(sPos.GetVector2());		
		}	

		
		LabyrinthSetRoom@ room = LabyrinthSetRoom(prefab, reqs, chance, offset, startPos, hidden, placement);
	
		auto arrLayoutY = GetParamArray(u, roomSv, "layout");
		for (uint y = 0; y < arrLayoutY.length(); y++)
		{
			auto arrLayoutX = arrLayoutY[y].GetArray();
			for (uint x = 0; x < arrLayoutX.length(); x++)
			{
				if (arrLayoutX[x].GetType() != SValueType::String)
					continue;
			
				auto sectStr = arrLayoutX[x].GetString();
				if (sectStr.isEmpty())
					continue;

				LabyrinthSetRoomSection sect;
				sect.x = x;
				sect.y = y;

				if (sectStr.findFirstOf("n") >= 0)
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::NorthDoor);
				if (sectStr.findFirstOf("s") >= 0)
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::SouthDoor);
				if (sectStr.findFirstOf("w") >= 0)
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::WestDoor);
				if (sectStr.findFirstOf("e") >= 0)
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::EastDoor);

				if (sectStr.findFirstOf("N") >= 0)
				{
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::NorthDoor);
					sect.doorsForced |= uint8(LabyrinthSetRoomSectionInfo::NorthDoor);
				}
				
				if (sectStr.findFirstOf("S") >= 0)
				{
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::SouthDoor);
					sect.doorsForced |= uint8(LabyrinthSetRoomSectionInfo::SouthDoor);
				}
				
				if (sectStr.findFirstOf("W") >= 0)
				{
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::WestDoor);
					sect.doorsForced |= uint8(LabyrinthSetRoomSectionInfo::WestDoor);
				}
				
				if (sectStr.findFirstOf("E") >= 0)
				{
					sect.doors |= uint8(LabyrinthSetRoomSectionInfo::EastDoor);
					sect.doorsForced |= uint8(LabyrinthSetRoomSectionInfo::EastDoor);
				}

				room.AddSection(sect);
			}
		}
		
		room.Finalize();
		labSet.AddRoom(room);
	}
	
	auto arrConstr = GetParamArray(u, sv, "constraints", false);
	if (arrConstr !is null)
	{
		for (uint j = 0; j < arrConstr.length(); j++)
		{
			auto constrSv = arrConstr[j];


			LabyrinthSetRoomReq@ a;
			LabyrinthSetRoomReq@ b;

			labSet.m_roomReqs.get(GetParamString(u, constrSv, "a", true), @a);
			labSet.m_roomReqs.get(GetParamString(u, constrSv, "b", false), @b);
			
			if (b is null)
				@b = a;
				
			if (a is null)
				continue;

			float minDistSq = GetParamInt(u, constrSv, "min-dist", false, 0) / 256.0f;
			float maxDistSq = GetParamInt(u, constrSv, "max-dist", false, 10000) / 256.0f;
			minDistSq *= minDistSq;
			maxDistSq *= maxDistSq;

			a.m_constraints.insertLast(LabyrinthSetRoomConstraint(b, minDistSq, maxDistSq));
			if (b !is a)
				b.m_constraints.insertLast(LabyrinthSetRoomConstraint(a, minDistSq, maxDistSq));



/*
			auto pfbA = Resources::GetPrefab(GetParamString(u, constrSv, "a", true));
			auto pfbB = Resources::GetPrefab(GetParamString(u, constrSv, "b", true));
			auto roomA = labSet.FindRoom(pfbA);
			auto roomB = labSet.FindRoom(pfbB);
		
			float minDistSq = GetParamInt(u, constrSv, "min-dist", false, 0) / 256.0f;
			float maxDistSq = GetParamInt(u, constrSv, "max-dist", false, 10000) / 256.0f;
			minDistSq *= minDistSq;
			maxDistSq *= maxDistSq;

			if (roomA is null || roomB is null)
				continue;

			roomA.m_constraints.insertLast(LabyrinthSetRoomConstraint(pfbB, minDistSq, maxDistSq));
			if (roomB !is roomA)
				roomB.m_constraints.insertLast(LabyrinthSetRoomConstraint(pfbA, minDistSq, maxDistSq));
*/
		}
	}
	
	g_labyrinthSets.set(theme, @labSet);
}

LabyrinthRoomPlacementStrategy ParsePlacement(string str)
{
	if (str == "" || str == "middle")
		return LabyrinthRoomPlacementStrategy::Middle;

	if (str == "top")
		return LabyrinthRoomPlacementStrategy::Top;

	if (str == "left")
		return LabyrinthRoomPlacementStrategy::Left;

	if (str == "right")
		return LabyrinthRoomPlacementStrategy::Right;
		
	if (str == "bottom")
		return LabyrinthRoomPlacementStrategy::Bottom;
		
	if (str == "spread")
		return LabyrinthRoomPlacementStrategy::Spread;

	return LabyrinthRoomPlacementStrategy::Middle;
}

class LabyrinthSet
{
	array<LabyrinthSetRoom@> m_rooms;
	dictionary m_roomReqs;
	
	LabyrinthSet()
	{
	}

	void AddRoom(LabyrinthSetRoom@ room)
	{
		m_rooms.insertLast(room);
	}
	
	LabyrinthSetRoom@ FindRoom(Prefab@ pfb)
	{
		if (pfb is null)
			return null;
	
		for (uint i = 0; i < m_rooms.length(); i++)
			if (m_rooms[i].m_prefab is pfb)
				return m_rooms[i];
		
		return null;
	}
}

enum LabyrinthSetRoomSectionInfo
{
	NorthDoor = 1,
	SouthDoor = 2,
	WestDoor = 4,
	EastDoor = 8,
	
	InUse = 16
}

class LabyrinthSetRoomSection
{
	int x;
	int y;
	uint8 doors;
	uint8 doorsForced;
}

class LabyrinthSetRoomReq
{
	int m_required;
	int m_max;
	array<LabyrinthSetRoomReqMod@> m_mods;
	array<LabyrinthSetRoomConstraint@> m_constraints;
	string m_name;
	
	int m_tmpInUse;
	int m_tmpRequired;
	int m_tmpMax;
	
	/*
	LabyrinthSetRoomReq(){}
    LabyrinthSetRoomReq(const LabyrinthSetRoomReq &in other)
    {
		DumpStack();
    }
	*/
}

class LabyrinthSetRoomReqMod
{
	string m_flag;
	int m_required;
	int m_max;
	
	LabyrinthSetRoomReqMod(const string &in flag, int req, int max)
	{
		m_flag = flag;
		m_required = req;
		m_max = max;
	}
}

enum LabyrinthRoomPlacementStrategy
{
	Top,
	Left,
	Middle,
	Right,
	Bottom,
	Spread
}

class LabyrinthSetRoomConstraint
{
	LabyrinthSetRoomReq@ m_roomReq;
	float m_minDistSq;
	float m_maxDistSq;

	LabyrinthSetRoomConstraint(LabyrinthSetRoomReq@ roomReq, float minDistSq, float maxDistSq)
	{
		@m_roomReq = roomReq;
		m_minDistSq = minDistSq;
		m_maxDistSq = maxDistSq;
	}
}

class LabyrinthSetRoom
{
	Prefab@ m_prefab;
	int m_chance;
	vec2 m_offset;
	array<LabyrinthSetRoomSection@> m_sections;
	LabyrinthSetRoomReq@ m_reqs;
	
	array<vec2> m_startPos;
	LabyrinthRoomPlacementStrategy m_placement;

	bool m_hidden;
	bool m_disconnected;
	
	ivec2 m_size;
	

	LabyrinthSetRoom(Prefab@ pfb, LabyrinthSetRoomReq@ roomReq, int chance, vec2 offset, array<vec2> startPos, bool hidden, LabyrinthRoomPlacementStrategy placement)
	{
		@m_prefab = pfb;
		m_chance = chance;
		m_offset = offset;
		m_startPos = startPos;
		m_hidden = hidden;
		m_placement = placement;
		
		@m_reqs = roomReq;
	}
	
	void AddSection(LabyrinthSetRoomSection@ sect)
	{
		m_sections.insertLast(sect);
	}
	
		
	void Finalize()
	{
		m_disconnected = true;
		
		for (uint i = 0; i < m_sections.length(); i++)
		{
			m_size.x = max(m_size.x, m_sections[i].x + 1);
			m_size.y = max(m_size.y, m_sections[i].y + 1);
		
			if (m_sections[i].doors != 0)
				m_disconnected = false;
		}
	}
}



