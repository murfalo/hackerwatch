enum DungeonTileset
{
	GraniteMines,
	Prison,
	Armory,
	Archives,
	Chambers,
	Desert,
	PyramidSlum,
	PyramidFancy,
	
	SandCaves
}

class DungeonGenerator
{

	[Editable type=flags default=7]
	Enemies Enemies;
	
	[Editable default=true]
	bool EliteEnemies;
	[Editable default=true]
	bool EnemySpawners;
	[Editable default=true]
	bool MinibossEnemies;
	
	[Editable min=0 default=8]
	int MinEnemyGroups;
	[Editable min=0 default=1]
	float EnemyGroupChance;
	
	
	EnemyPlacement@ m_enemyPlacer;
	
	

	[Editable type=enum default=2]
	DungeonTileset Tileset;
	
	

	vec2 m_startPos;
	bool m_placeActShortcut;
	int m_numPlrs;
	DungeonBrush@ m_brush;

	void MakeBrush()
	{
		if (m_brush !is null)
			return;
			
		switch (Tileset)
		{
		case DungeonTileset::SandCaves:
			@m_brush = SandCaveBrush();
			break;
		case DungeonTileset::GraniteMines:
			@m_brush = GraniteMineBrush();
			break;
		case DungeonTileset::Prison:
			@m_brush = PrisonBrush();
			break;
		case DungeonTileset::Armory:
			@m_brush = ArmoryBrush();
			break;
		case DungeonTileset::Archives:
			@m_brush = ArchivesBrush();
			break;
		case DungeonTileset::Chambers:
			@m_brush = ChambersBrush();
			break;
		case DungeonTileset::Desert:
			@m_brush = DesertBrush();
			break;
		case DungeonTileset::PyramidSlum:
			@m_brush = PyramidSlumBrush();
			break;
		case DungeonTileset::PyramidFancy:
			@m_brush = PyramidFancyBrush();
			break;
		}
	}
	
	void Generate(Scene@ scene) {}
	
	void PlaceEnemies(Scene@ scene, ivec2 startPos)
	{
		if (!(Enemies & Enemies != 0) && m_enemyPlacer is null)
			return;
			
		if (MinEnemyGroups <= 0)
			return;
		
		int w = m_brush.m_width;
		int h = m_brush.m_height;
	
		auto gridDist = array<array<uint8>>(w, array<uint8>(h, 255));
		
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				Cell cell = m_brush.GetCell(x, y);
				//if (cell != Cell::Floor || m_brush.IsConsumed(x, y))
				if (cell != Cell::Floor)
					gridDist[x][y] = 1;
			}
		}
		
		uint8 grpDistLimit = 1;
		for (int y = h - 2; y > 0; y--)
		{
			for (int x = w - 2; x > 0; x--)
			{
				if (gridDist[x][y] == 255)
				{
					uint8 minDist = min(min(min(gridDist[x - 1][y], gridDist[x + 1][y]), gridDist[x][y - 1]), gridDist[x][y + 1]);
					if (minDist == 255)
						continue;
					
					minDist++;
					if (grpDistLimit < minDist)
						grpDistLimit = minDist;
					
					gridDist[x][y] = minDist;
				}
			}
		}
	
		array<array<ivec2>@> enemyGroups;
		while(enemyGroups.length() <= uint(MinEnemyGroups))
		{
			if (grpDistLimit <= 2)
				break;
		
			for (int y = 0; y < h; y++)
			{
				for (int x = 0; x < w; x++)
				{
					if (gridDist[x][y] >= grpDistLimit)
					{
						array<ivec2> group;
					
						array<ivec2> queue;
						queue.insertLast(ivec2(x, y));
						gridDist[x][y] = 0;
						
						uint8 dist = grpDistLimit - 1;
						while(!queue.isEmpty())
						{
							auto pt = queue[0];
							queue.removeAt(0);

							if (EnemyGroupChance >= 1 || randf() < EnemyGroupChance)
								group.insertLast(pt);
							
							if (m_brush.GetCell(pt.x, pt.y) != Cell::Floor)
								continue;
							
							if (pt.x + 1 < w && gridDist[pt.x + 1][pt.y] >= dist)
							{
								queue.insertLast(ivec2(pt.x + 1, pt.y));
								gridDist[pt.x + 1][pt.y] = 0;
							}
								
							if (pt.x > 0 && gridDist[pt.x - 1][pt.y] >= dist)
							{
								queue.insertLast(ivec2(pt.x - 1, pt.y));
								gridDist[pt.x - 1][pt.y] = 0;
							}
								
							if (pt.y + 1 < h && gridDist[pt.x][pt.y + 1] >= dist)
							{
								queue.insertLast(ivec2(pt.x, pt.y + 1));
								gridDist[pt.x][pt.y + 1] = 0;
							}
								
							if (pt.y > 0 && gridDist[pt.x][pt.y - 1] >= dist)
							{
								queue.insertLast(ivec2(pt.x, pt.y - 1));
								gridDist[pt.x][pt.y - 1] = 0;
							}
						}
						
						if (group.length() > 1)
							enemyGroups.insertLast(group);
					}
				}
			}
			
			grpDistLimit--;
		}
		
		if (m_enemyPlacer is null)
			@m_enemyPlacer = EnemyPlacement(Enemies, EnemySpawners, EliteEnemies, MinibossEnemies);
		
		m_enemyPlacer.Initialize(startPos);
		m_enemyPlacer.Place(scene, m_brush, enemyGroups);
	}
	
	int ReserveCliff(array<array<uint8>>@ gridTaken, int x, int y, bool fill)
	{
		int w = m_brush.m_width;
		int h = m_brush.m_height;
	
		array<ivec2> delta = { ivec2(1, 0), ivec2(-1, 0), ivec2(0, 1), ivec2(0, -1) };
	
		array<ivec2> queue;
		queue.insertLast(ivec2(x, y));
		gridTaken[x][y] = 0;

		bool valid = true;
		int num = 0;
		while(!queue.isEmpty())
		{
			auto pt = queue[0];
			queue.removeAt(0);
			
			for (int i = 0; i < 4; i++)
			{
				ivec2 p = pt + delta[i];
				
				if (p.x < 0 || p.x >= w || p.y < 0 || p.y >= h || m_brush.IsConsumed(p.x, p.y))
				{
					valid = false;
					continue;
				}
				
				if (gridTaken[p.x][p.y] != 0)
					continue;

				if (m_brush.GetCell(p.x, p.y) != Cell::Wall)
					continue;
				
				if (valid && !fill)
				{
					if (m_brush.GetCell(p.x, p.y - 1) != Cell::Wall && (m_brush.GetCell(p.x, p.y + 1) != Cell::Wall   ))//|| m_brush.GetCell(p.x, p.y + 2) != Cell::Wall))
						valid = false;
					else if (m_brush.GetCell(p.x - 1, p.y) != Cell::Wall && m_brush.GetCell(p.x + 1, p.y) != Cell::Wall)
						valid = false;
				}
				
				queue.insertLast(p);
				gridTaken[p.x][p.y] = 1;
				num++;
				
				if (fill)
					m_brush.SetCell(p.x, p.y, Cell::Cliff);
			}
		}
		
		return valid ? num : -1;
	}
	
	
	void MakeCliffs(int maxNum, int maxSize)
	{
		if (maxNum <= 0)
			return;
	
		int w = m_brush.m_width;
		int h = m_brush.m_height;
	
		auto gridTaken = array<array<uint8>>(w, array<uint8>(h, 0));
		array<ivec2> cliffGroups;
		
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				if (gridTaken[x][y] != 0)
					continue;
			
				Cell cell = m_brush.GetCell(x, y);
				if (cell == Cell::Wall && !m_brush.IsConsumed(x, y))
				{
					int size = ReserveCliff(gridTaken, x, y, false);
					if (size > 10 && size < maxSize)
						cliffGroups.insertLast(ivec2(x, y));
				}
			}
		}
		
		gridTaken = array<array<uint8>>(w, array<uint8>(h, 0));
		while(maxNum-- > 0 && cliffGroups.length() > 0)
		{
			int idx = randi(cliffGroups.length());
			auto pt = cliffGroups[idx];
			cliffGroups.removeAt(idx);
			
			ReserveCliff(gridTaken, pt.x, pt.y, true);
		}
	}
	
	
	void PlaceCrateBreakables(int w, int h)
	{
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				if (BlocksBreakable(x, y))
					continue;
				
				if (BlocksBreakable(x, y + 1))
					continue;
				
				if (BlocksBreakable(x, y + 2))
					continue;
				
				if (BlocksBreakable(x, y + 3))
					continue;
				
				if (m_brush.GetCell(x, y -1) == Cell::Floor)
					continue;

				bool noWall = true;
				int chance = 10;
				if (m_brush.GetCell(x, y -1) == Cell::Wall)
				{
					chance += 30;
					noWall = false;
				}
				else if (m_brush.GetCell(x, y -1) == Cell::Breakables)
					chance += 10;
					
				if (m_brush.GetCell(x -1, y) == Cell::Wall)
				{
					chance += 25;
					noWall = false;
				}
				else if (m_brush.GetCell(x -1, y) == Cell::Breakables)
					chance += 8;
					
				if (m_brush.GetCell(x +1, y) == Cell::Wall)
				{
					chance += 25;
					noWall = false;
				}
				else if (m_brush.GetCell(x +1, y) == Cell::Breakables)
					chance += 8;
					
				PlaceCrateBreakable(x, y, noWall, chance);
			}
		}
	}
	
	void PlaceCrateBreakable(int x, int y, bool noWall, int chance)
	{
		if (noWall)
			chance /= 2;
		
		if (randi(100) < chance)
			m_brush.SetCell(x, y, Cell::Breakables);
	}
	
	bool BlocksBreakable(int x, int y)
	{
		if (m_brush.IsConsumed(x, y))
			return true;
	
		auto cell = m_brush.GetCell(x, y);
		return (cell != Cell::Floor && cell != Cell::Breakables);
	}
	
		
	void PlotPoint(int x, int y, Cell cellType)
	{
		if (cellType == Cell::Floor)
		{
			if (m_brush.GetCell(x, y) == Cell::Cliff)
				m_brush.SetCell(x, y, Cell::Bridge);
			else
				m_brush.SetCell(x, y, Cell::Floor);
		}
		else
			m_brush.SetCell(x, y, cellType);
	}
	
	void PlotRect(ivec2 topLeft, ivec2 botRight, Cell cellType, bool consume = false)
	{
		for (int y = topLeft.y; y <= botRight.y; y++)
			for (int x = topLeft.x; x <= botRight.x; x++)
				PlotPoint(x, y, cellType);
		
		if (consume)
		{
			for (int y = topLeft.y; y <= botRight.y; y++)
				for (int x = topLeft.x; x <= botRight.x; x++)
					m_brush.SetConsumed(x, y);
		}
	}

	void PlotLine(ivec2 start, ivec2 end, float wd, Cell cellType)
	{ 
		int dx = abs(end.x - start.x);
		int dy = abs(end.y - start.y);
		int sx = start.x < end.x ? 1 : -1;
		int sy = start.y < end.y ? 1 : -1;

		int err = dx - dy;

		float ed = (dx + dy == 0) ? 1.f : sqrt(float(dx*dx) + float(dy*dy));

		wd = (wd + 1) / 2;

		while (true)
		{
			PlotPoint(start.x, start.y, cellType);

			int e2 = err; 
			int x2 = start.x;

			if (2 * e2 >= -dx)
			{
				int y2 = start.y;
				for (e2 += dy; e2 < ed*wd && (end.y != y2 || dx > dy); e2 += dx)
					PlotPoint(start.x, y2 += sy, cellType);

				if (start.x == end.x) 
					break;

				e2 = err; 
				err -= dy; 
				start.x += sx; 
			} 

			if (2 * e2 <= dy)
			{
				for (e2 = dx-e2; e2 < ed*wd && (end.x != x2 || dx < dy); e2 += dy)
					PlotPoint(x2 += sx, start.y, cellType);

				if (start.y == end.y) 
					break;

				err += dx; 
				start.y += sy; 
			}
		}
	}
	
}


