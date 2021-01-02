enum Pattern
{
	Nothing		= 1,
	Floor		= 2,
	NotFloor	= 3,
	Breakable	= 4,
	Wall		= 5,
	NotWall		= 6,
	Walkable	= 7,
	NotWalkable	= 8,
	Cliff		= 9,
	Anything	= 10
}

enum PatternCommand
{
	Ignore,
	Reserve,
	ReserveWall,
	ReserveFloor,
	ReservedWall,
	ReserveCliff,
	Wall,
	Floor,
}


class PatternMatcher
{
	void RemoveDiagonals(DungeonBrush@ brush)
	{
		%PROFILE_START RemoveDiagonals
		{
			array<array<Pattern>> ptrn = {
				{Pattern::Wall, Pattern::Walkable},
				{Pattern::Walkable, Pattern::Wall}
			};

			auto diags = FindAllPatterns(brush, ptrn);
		
			for (uint i = 0; i < diags.length(); i++)
				brush.SetCell(diags[i].x, diags[i].y, Cell::Floor);
		}
		
		{
			array<array<Pattern>> ptrn = {
				{Pattern::Walkable, Pattern::Wall},
				{Pattern::Wall, Pattern::Walkable}
			};

			auto diags = FindAllPatterns(brush, ptrn);
		
			for (uint i = 0; i < diags.length(); i++)
				brush.SetCell(diags[i].x + 1, diags[i].y, Cell::Floor);
		
		}
		
		{
			array<array<Pattern>> ptrn = {
				{Pattern::Wall, Pattern::Walkable},
				{Pattern::Walkable, Pattern::Walkable},
				{Pattern::Walkable, Pattern::Wall}
			};

			auto diags = FindAllPatterns(brush, ptrn);
		
			for (uint i = 0; i < diags.length(); i++)
				brush.SetCell(diags[i].x, diags[i].y, Cell::Floor);
		}
		
		{
			array<array<Pattern>> ptrn = {
				{Pattern::Walkable, Pattern::Wall},
				{Pattern::Walkable, Pattern::Walkable},
				{Pattern::Wall, Pattern::Walkable}
			};

			auto diags = FindAllPatterns(brush, ptrn);			
		
			for (uint i = 0; i < diags.length(); i++)
				brush.SetCell(diags[i].x + 1, diags[i].y, Cell::Floor);
		}
		%PROFILE_STOP
	}
	/*
	void RemovePits(DungeonBrush@ brush)
	{
		%PROFILE_START RemovePits
		
		{
			array<array<Pattern>> ptrn = {
				{Pattern::NotWalkable, Pattern::NotWalkable},
				{Pattern::NotWalkable, Pattern::Walkable},
				{Pattern::NotWalkable, Pattern::NotWalkable}
			};

			auto pits = FindAllPatterns(brush, ptrn);
			print("Pits found: " + pits.length());
		
			for (uint i = 0; i < pits.length(); i++)
			{
				auto pit = pits[i];
				
				for (int j = 2; j < 5; j++)
				{
					if (brush.IsConsumed(pit.x + 1, pit.y + j))
						{ print("Consumed!"); break; }
						
					if (!brush.IsOpen(pit.x + 2, pit.y + j))
						{ print("Not open!"); break; }
						
					brush.SetCell(pit.x + 1, pit.y + j, Cell::Floor);
				}
				
				for (int j = 0; j >= -3; j--)
				{
					if (brush.IsConsumed(pit.x + 1, pit.y + j))
						{ print("Consumed!"); break; }
						
					if (!brush.IsOpen(pit.x + 2, pit.y + j))
						{ print("Not open!"); break; }
						
					brush.SetCell(pit.x + 1, pit.y + j, Cell::Floor);
				}
			}
		}

		{
			array<array<Pattern>> ptrn = {
				{Pattern::NotWalkable, Pattern::NotWalkable},
				{Pattern::Walkable, Pattern::NotWalkable},
				{Pattern::NotWalkable, Pattern::NotWalkable}
			};

			auto pits = FindAllPatterns(brush, ptrn);
			print("Pits found: " + pits.length());
		
			for (uint i = 0; i < pits.length(); i++)
			{
				auto pit = pits[i];
				
				for (int j = 2; j < 5; j++)
				{
					if (brush.IsConsumed(pit.x, pit.y + j))
					{ print("Consumed!"); break; }
						
					if (!brush.IsOpen(pit.x -1, pit.y + j))
					{ print("Not open!"); break; }
						
					brush.SetCell(pit.x, pit.y + j, Cell::Floor);
				}
				
				for (int j = 0; j >= -3; j--)
				{
					if (brush.IsConsumed(pit.x, pit.y + j))
					{ print("Consumed!"); break; }
						
					if (!brush.IsOpen(pit.x -1, pit.y + j))
					{ print("Not open!"); break; }
						
					brush.SetCell(pit.x, pit.y + j, Cell::Floor);
				}
			}
		}
		
		%PROFILE_STOP
	}
	*/
	array<ivec2> ReservePrefabs(DungeonBrush@ brush, array<array<Pattern>>@ pattern, array<array<PatternCommand>>@ commands, int count)
	{
		int pHeight = commands.length();
		int pWidth = commands[0].length();
		
		int maxDistSq = (pHeight + pWidth) * 2;
		maxDistSq *= maxDistSq;
		
		auto found = FindAllPatterns(brush, pattern);
	
		array<ivec2> places;
		for (int num = 0; num < count; num++)
		{
			if (found.length() <= 0)
				break;
		
			auto pos = found[randi(found.length())];
			places.insertLast(pos);

			for (int y = 0; y < pHeight; y++)
			{
				for (int x = 0; x < pWidth; x++)
				{
					auto cmd = commands[y][x];
					if (cmd == PatternCommand::Ignore)
						continue;
						
					switch (cmd)
					{
					case PatternCommand::Reserve:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Reserved);
						brush.SetConsumed(pos.x + x, pos.y + y);
						break;
					case PatternCommand::ReserveWall:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Wall);
						brush.SetConsumed(pos.x + x, pos.y + y);
						break;
					case PatternCommand::ReserveFloor:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Floor);
						brush.SetConsumed(pos.x + x, pos.y + y);
						break;	
					case PatternCommand::ReserveCliff:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Cliff);
						brush.SetConsumed(pos.x + x, pos.y + y);
						break;
					case PatternCommand::Wall:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Wall);
						break;
					case PatternCommand::ReservedWall:
						brush.SetCell(pos.x + x, pos.y + y, Cell::ReservedWall);
						break;
					case PatternCommand::Floor:
						brush.SetCell(pos.x + x, pos.y + y, Cell::Floor);
						break;
					}
				}
			}
			
			for (uint i = 0; i < found.length();)
			{
				ivec2 d = found[i] - pos;
				if ((d.x*d.x + d.y*d.y) < maxDistSq)
					found.removeAt(i);
				else
					i++;
			}
		}
		
		return places;
	}
	
	array<ivec2> FindAllPatterns(DungeonBrush@ brush, array<array<Pattern>>@ pattern)
	{
		%PROFILE_START FindAllPatterns
		
		array<ivec2> matches = OPT_FindAllPatterns(pattern, brush.m_grid, brush.m_gridConsumed);
		
/*
		array<ivec2> matches;
		int pHeight = pattern.length();
		int pWidth = pattern[0].length();

		int sHeight = brush.m_height - pHeight - 1;
		int sWidth = brush.m_width - pWidth - 1;
		
		auto@ grid = brush.m_grid;
		auto@ gridConsumed = brush.m_gridConsumed;

		for (int y = 1; y < sHeight; y++)
		{
			for (int x = 1; x < sWidth; x++)
			{
				bool match = true;
				for (int px = 0; px < pWidth; px++)
				{
					for (int py = 0; py < pHeight; py++)
					{
						auto cell = grid[x + px][y + py];
						
						switch (pattern[py][px])
						{
						case Pattern::Nothing:
							if (cell != Cell::Nothing)
								match = false;
							break;
						
						case Pattern::Wall:
							if (cell != Cell::Wall)
								match = false;
							break;
							
						case Pattern::NotWall:
							if (cell == Cell::Wall)
								match = false;
							break;
							
						case Pattern::Breakable:
							if (cell != Cell::Breakables)
								match = false;
							break;
							
						case Pattern::Floor:
							if (cell != Cell::Floor)
								match = false;
							break;
							
						case Pattern::NotFloor:
							if (cell == Cell::Floor)
								match = false;
							break;
							
						case Pattern::Walkable:
							if (!(cell == Cell::Floor || cell == Cell::Breakables))
								match = false;
							break;
							
						case Pattern::NotWalkable:
							if (cell == Cell::Floor || cell == Cell::Breakables)
								match = false;
							break;
						}
						
						if (match && gridConsumed[x + px][y + py])
							match = false;

					
						if (!match)
							break;
					}
					
					if (!match)
						break;
				}
				
				if (match)
					matches.insertLast(ivec2(x, y));
			}
		}
*/

		%PROFILE_STOP
		
		return matches;
	}

}