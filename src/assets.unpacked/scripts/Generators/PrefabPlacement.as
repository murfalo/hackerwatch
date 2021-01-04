class PrefabPatternPair
{
	array<array<Pattern>>@ m_pattern;
	array<array<PatternCommand>>@ m_command;
	ivec2 m_placementOffset;
	
	PrefabPatternPair(array<array<Pattern>>@ pattern, array<array<PatternCommand>>@ command, ivec2 placementOffset)
	{
		@m_pattern = pattern;
		@m_command = command;
		m_placementOffset = placementOffset;
	}
}

class PrefabPlacement
{
	DungeonBrush@ m_brush;
	PatternMatcher@ m_ptrnMtch;
	bool m_altPatterns;
	
	PrefabPlacement(DungeonBrush@ brush, PatternMatcher@ ptrnMtch)
	{
		@m_brush = brush;
		@m_ptrnMtch = ptrnMtch;
		m_altPatterns = false;
	}
	
	int PlacePrefabs(array<PointOfInterestType> types, int maxAmount, uint maxPerType = 1)
	{
		int numPlaced = 0;
	
		while (numPlaced < maxAmount && types.length() > 0)
		{
			int tn = randi(types.length());
			auto type = types[tn];
			types.removeAt(tn);
			
			if (!m_brush.HasPointOfInterest(type))
				continue;
		
			auto pattern = CreatePrefabPattern(type);
			if (pattern is null)
				continue;
			
			auto pos = m_ptrnMtch.ReservePrefabs(m_brush, pattern.m_pattern, pattern.m_command, 1);
			for (uint i = 0; i < pos.length() && i < maxPerType && numPlaced < maxAmount; i++)
			{
				m_brush.AddPointOfInterest(type, pos[i].x + pattern.m_placementOffset.x, pos[i].y + pattern.m_placementOffset.y);
				numPlaced++;
			}
		}
		
		return numPlaced;
	}
	
	int PlacePrefab(PointOfInterestType type, int maxAmount)
	{
		if (maxAmount < 1)
			return 0;
	
		if (!m_brush.HasPointOfInterest(type))
			return 0;
	
		auto pattern = CreatePrefabPattern(type);
		if (pattern is null)
			return 0;
		
		auto pos = m_ptrnMtch.ReservePrefabs(m_brush, pattern.m_pattern, pattern.m_command, maxAmount);
		for (uint i = 0; i < pos.length(); i++)
			m_brush.AddPointOfInterest(type, pos[i].x + pattern.m_placementOffset.x, pos[i].y + pattern.m_placementOffset.y);
	
		return pos.length();
	}
	
	PrefabPatternPair@ CreatePrefabPattern(PointOfInterestType type)
	{
		auto wlk = Pattern::Walkable;
		auto nwl = Pattern::NotWall;
		auto wll = Pattern::Wall;
		auto nwk = Pattern::NotWalkable;
		auto any = Pattern::Anything;
		auto clf = Pattern::Cliff;
		auto nth = Pattern::Nothing;

		auto cig = PatternCommand::Ignore;
		auto crs = PatternCommand::Reserve;
		auto crw = PatternCommand::ReserveWall;
		auto crc = PatternCommand::ReserveCliff;
		auto cwl = PatternCommand::ReservedWall;
		auto cfl = PatternCommand::ReserveFloor;

		switch(type)
		{
		
		case PointOfInterestType::PrefabSpecialOre:
		//case PointOfInterestType::PrefabActShortcut:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, any, wlk, wlk, wlk, wlk, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cwl, crw, crs, crs, crs, crs, crw, cwl, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cfl, cig, cig, cig, cig, cfl, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab3x3Cliff:
		{
			array<array<Pattern>> pattern = {
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab9x9Cliff:
		{
			array<array<Pattern>> pattern = {
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab13x13Cliff:
		{
			array<array<Pattern>> pattern = {
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}		
		
		case PointOfInterestType::Prefab9x3Cliff:
		{
			array<array<Pattern>> pattern = {
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf, clf, clf, clf, clf, clf, clf}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, crc, crc, crc, crc, crc, crc, crc, crc, crc, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab3x9Cliff:
		{
			array<array<Pattern>> pattern = {
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf},
				{clf, clf, clf, clf, clf}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, crc, crc, crc, cig},
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}

		case PointOfInterestType::Prefab5x5BlockNorth:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x5BlockSouth:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x6BlockEast:
		{
			array<array<Pattern>> pattern = {
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x6BlockWest:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab12x5BlockNorth:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab12x5BlockSouth:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x12BlockEast:
		{
			array<array<Pattern>> pattern = {
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x12BlockWest:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}

		case PointOfInterestType::Prefab12x7BlockNorthInverted:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab12x7BlockSouthInverted:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}
		case PointOfInterestType::Prefab7x12BlockEastInverted:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll, wll}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, crs, crs, crs, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(2, 1));
		}
		case PointOfInterestType::Prefab7x12BlockWestInverted:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::PrefabMazePathN:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{any, any, wlk, wlk, any, any}
			};
			
			if (m_altPatterns)
				pattern = {
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{any, wlk, wlk, wlk, wlk, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::PrefabMazePathS:
		{
			array<array<Pattern>> pattern = {
				{any, any, wlk, wlk, any, any},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wll, wll, wll, wll, wll}
			};
			
			if (m_altPatterns)
				pattern = {
				{any, wlk, wlk, wlk, wlk, any},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::PrefabMazePathW:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, any},
				{wll, wlk, wlk, wlk, wlk, wlk, any},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wlk, wlk, wlk, wlk, wlk, any},
				{wll, wll, wll, wll, wll, wll, any}
			};
			
			if (m_altPatterns)
				pattern = {
				{wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crw, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::PrefabMazePathE:
		{
			array<array<Pattern>> pattern = {
				{any, wll, wll, wll, wll, wll, wll},
				{any, wlk, wlk, wlk, wlk, wlk, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{any, wlk, wlk, wlk, wlk, wlk, wll},
				{any, wll, wll, wll, wll, wll, wll}
			};
			
			if (m_altPatterns)
				pattern = {
				{any, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll},
				{any, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab22x22North2:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, any, any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any, any, any, any, any, any, any},
				{any, any, any, any, any, any, any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab22x22South2:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, any, any, any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any, any, any, any, any, any, any},
				{any, any, any, any, any, any, any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any, any, any, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab21x21East:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab21x21West:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any}
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab13x13North:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, any, any, wll, wll, wll, any, any, any, any, any, any, any},
				{any, any, any, any, any, any, any, any, wlk, any, any, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, crs, crs, crs, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cwl, crw, crs, crw, cwl, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cfl, cig, cfl, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab9x9North:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, wll, wll, wll, any, any, any, any, any},
				{any, any, any, any, any, any, wlk, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cwl, crw, crs, crw, cwl, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cfl, cig, cfl, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x5North:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, wll, wll, wll, any, any, any},
				{any, any, any, any, wlk, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, crs, crs, crs, cig, cig, cig},
				{cig, cig, cwl, crw, crs, crw, cwl, cig, cig},
				{cig, cig, cig, cfl, cig, cfl, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}

		case PointOfInterestType::Prefab3x3North:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll},
				{any, any, wll, wll, wll, any, any},
				{any, any, any, wlk, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, cig, crs, crs, crs, cig, cig},
				{cig, cwl, crw, crs, crw, cwl, cig},
				{cig, cig, cfl, cig, cfl, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab14x14North2:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any, any, any},
				{any, any, any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::PrefabActShortcut:
		case PointOfInterestType::Prefab10x10North2:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any},
				{any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x6North2:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{any, any, any, wll, wll, wll, wll, any, any, any},
				{any, any, any, any, wlk, wlk, any, any, any, any}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, crs, crs, crs, crs, cig, cig, cig},
				{cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig},
				{cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
				

		case PointOfInterestType::Prefab9x9South:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, any, any, wlk, any, any, any, any, any, any},
				{any, any, any, any, any, wll, wll, wll, any, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cfl, cig, cfl, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cwl, crw, crs, crw, cwl, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x5South:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wlk, any, any, any, any},
				{any, any, any, wll, wll, wll, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cfl, cig, cfl, cig, cig, cig},
				{cig, cig, cwl, crw, crs, crw, cwl, cig, cig},
				{cig, cig, cig, crs, crs, crs, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		
		case PointOfInterestType::Prefab14x14South2:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any, any, any},
				{any, any, any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab10x10South2:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, any, any, wlk, wlk, any, any, any, any, any, any},
				{any, any, any, any, any, wll, wll, wll, wll, any, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x6South2:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wlk, wlk, any, any, any, any},
				{any, any, any, wll, wll, wll, wll, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cfl, cig, cig, cfl, cig, cig, cig},
				{cig, cig, cwl, crw, crs, crs, crw, cwl, cig, cig},
				{cig, cig, cig, crs, crs, crs, crs, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab13x13East:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll }
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab9x9East:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll }
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x5East:
		{
			array<array<Pattern>> pattern = {
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{wlk, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll },
				{any, any, any, any, wll, wll, wll, wll, wll, wll, wll, wll, wll }
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crw, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cwl, cig, cig, cig, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab13x13West:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any}
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab9x9West:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any}
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cig, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab5x5West:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wlk },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, any },
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, any, any, any, any }
			};
		
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crw, cig },
				{cig, crs, crs, crs, crs, crs, crs, crs, cig, cig, cig, cwl, cig },
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig }
			};
		
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab35x35Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab21x21Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab13x13Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 2));
		}
		case PointOfInterestType::Prefab9x9Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}
		case PointOfInterestType::Prefab7x7Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}		
		case PointOfInterestType::Prefab5x5Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}		
		case PointOfInterestType::Prefab3x3Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, cig},
				{cig, crs, crs, crs, cig},
				{cig, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig},
				{cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}
		case PointOfInterestType::Prefab2x2Block:
		{
			array<array<Pattern>> pattern = {
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig},
				{cig, cig, cig, cig},
				{cig, cig, cig, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, cig, cig, cig},
				{cig, cig, cig, cig},
				{cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 3));
		}
		
		case PointOfInterestType::Prefab2x6Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll},
				{wll, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x3Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab4x6Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x4Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab8x4Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab12x6Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab12x8Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wlk},
				{wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		
		case PointOfInterestType::Prefab5x12Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x12Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab7x12Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		case PointOfInterestType::Prefab6x8Path:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll},
				{wll, wlk, wlk, wlk, wlk, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig, cig, cig, cig, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, crs, crs, crs, crs, crs, crs, cig},
				{cig, cig, cig, cig, cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		
		case PointOfInterestType::Prefab2x3Junction:
		{
			array<array<Pattern>> pattern = {
				{wll, wlk, wlk, wll},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wlk, wlk, wlk, wlk},
				{wll, wlk, wlk, wll}
			};
			
			array<array<PatternCommand>> command = {
				{cig, cig, cig, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, crs, crs, cig},
				{cig, cig, cig, cig}
			};
			
			return PrefabPatternPair(pattern, command, ivec2(1, 1));
		}
		}
		
		return null;
	}
}