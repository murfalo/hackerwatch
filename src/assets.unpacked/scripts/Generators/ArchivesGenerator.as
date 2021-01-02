array<ivec2> arch_edgeDirs = { ivec2(), ivec2(1, 0), ivec2(0, 1), ivec2(-1, 0), ivec2(0, -1) };

class MazeCell
{
	bool m_inMaze;
	uint8 m_edges;
	
	MazeCell()
	{
		m_inMaze = false;
		m_edges = 0xFF;
	}

	void RemoveEdge(int e)
	{
		if (e == 0)
			return;

		if (e < 0)
		{
			e = (-e + 2) % 4;
			if (e == 0)
				e = 4;
		}
		
		m_edges &= ~(1 << e);
	}
}



[Generator]
class ArchivesGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	[Editable default=5]
	int Padding;
	[Editable default=5]
	int PathWidth;
	
	[Editable default=false]
	bool Prefabs;
	
	
	array<array<MazeCell>>@ m_mazeGrid;

	void AddCell(array<array<MazeCell>>@ grid, ivec4 blockRect, int cx, int cy, array<ivec3>@ openEdges)
	{
		if (grid[cx][cy].m_inMaze)
			return;
	
		grid[cx][cy].m_inMaze = true;
		
		for (int i = 1; i <= 4; i++)
		{
			auto p = arch_edgeDirs[i] + ivec2(cx, cy);
			/*
			if ((p.x == 0 || uint(p.x) == grid.length() -1) && (p.y == 0 || uint(p.y) == grid[0].length() -1))
				continue;
			*/
			
			if(p.x > blockRect.x && p.x < (blockRect.x + blockRect.z) && p.y > blockRect.y && p.y < (blockRect.y + blockRect.w))
				continue;

			if (p.x >= 0 && p.y >= 0 && p.x < int(grid.length()) && p.y < int(grid[0].length()) && !grid[p.x][p.y].m_inMaze)
				openEdges.insertLast(ivec3(cx, cy, i));
		}
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
	
	
			int mdx = PathWidth;
			int mdy = PathWidth + 1;
	
			int mw = (w - (Padding * 2)) / mdx;
			int mh = (h - (Padding * 2)) / mdy;
				
			auto grid = array<array<MazeCell>>(mw, array<MazeCell>(mh));
			@m_mazeGrid = grid;
			array<ivec3> openEdges;
			
			ivec4 blockRect(randi(mw -4), randi(mh -4), randi(4)+randi(4)+2, randi(4)+randi(4)+2);
			AddCell(grid, blockRect, randi(mw/2) + mw/4, randi(mh/2) + mh/4, openEdges);

			if (openEdges.isEmpty())
				continue;
				
				
			while (!openEdges.isEmpty())
			{
				int idx = randi(openEdges.length());
				auto edge = openEdges[idx];
				openEdges.removeAt(idx);
				
				ivec2 np(edge.x, edge.y);
				np += arch_edgeDirs[edge.z];
				
				for (uint i = 0; i < openEdges.length(); )
				{
					auto tmp = ivec2(openEdges[i].x, openEdges[i].y) + arch_edgeDirs[openEdges[i].z];
					if (tmp.x == np.x && tmp.y == np.y)
						openEdges.removeAt(i);
					else
						i++;
				}
				
				grid[edge.x][edge.y].RemoveEdge(edge.z);
				AddCell(grid, blockRect, np.x, np.y, openEdges);
				grid[np.x][np.y].RemoveEdge(-edge.z);
			}
			
			
			for (int y = 0; y < mh; y++)
			for (int x = 0; x < mw; x++)
			{
				auto cell = grid[x][y];
				if (!cell.m_inMaze)
					continue;
					
				int px = Padding + x * mdx;
				int py = Padding + y * mdy;

				
				for (int dy = 0; dy < (mdy - 1); dy++)
				for (int dx = 0; dx < (mdx - 1); dx++)
					m_brush.SetCell(px + dx, py + dy, Cell::Floor);

				
				if (cell.m_edges & (1 << 1) == 0)
				{
					for (int dy = 0; dy < (mdy - 1); dy++)
						m_brush.SetCell(px + mdx - 1, py + dy, Cell::Floor);
				}
				if (cell.m_edges & (1 << 2) == 0)
				{
					for (int dx = 0; dx < (mdx - 1); dx++)
						m_brush.SetCell(px + dx, py + mdy - 1, Cell::Floor);
				}
			}

			auto wlk = Pattern::Walkable;
			auto nwl = Pattern::NotWall;
			auto wll = Pattern::Wall;
			auto nwk = Pattern::NotWalkable;
			auto any = Pattern::Anything;
			auto nth = Pattern::Nothing;
			
			
			PatternMatcher ptrnMtch;
			
			//ptrnMtch.RemoveDiagonals(m_brush);
			
			
			ivec2 startPos(-1);
			//ivec2 exitPos;
			
			
			array<ivec4> rooms;
			rooms.insertLast(ivec4(Padding + blockRect.x * mdx - 2, Padding + blockRect.y * mdy - 2, blockRect.z * mdx + 4, blockRect.w * mdy + 4));


			for (uint i = 0; i < 15 && startPos.x == -1; i++)
				startPos = FindPrefabRoom(rooms, 10, 10);
			
			if (startPos.x == -1)
				continue;

			ReservePrefabRoom(rooms, startPos.x, startPos.y, 10, 10, Entry, 2, 3);
			startPos += ivec2(4, 6);
			
			m_startPos = vec2(16 * startPos.x + m_brush.m_posOffset.x + 16, 16 * startPos.y + m_brush.m_posOffset.y + 24);
			g_spawnPos = m_startPos;

			//MakeCliffs(MaxCliffNum, 450);
			

			%PROFILE_START Prefabs

			PrefabPlacement placer(m_brush, ptrnMtch);
			
			if (Prefabs)
				PlacePrefabs(placer, rooms);
			
			
			array<ivec3> toAdd;
			int numV = 0;
			
			for (int y = 0; y < mh; y++)
			for (int x = 0; x < mw; x++)
			{
				auto cell = grid[x][y];
					
				int px = Padding + x * mdx;
				int py = Padding + y * mdy;

				if (cell.m_edges == ~uint8(1 << 1) || cell.m_edges == ~uint8(1 << 3))
				{
					auto room = ivec4(px -3, py, (mdx - 1) +6, (mdy - 1));
					
					if (!IsFree(rooms, ivec2(room.x, room.y), room.z, room.w))
						continue;
				
					rooms.insertLast(room);
				
					ReservePrefabRoom(rooms, px, py, (mdx - 1), (mdy - 1), None, 1, 1, false);
					toAdd.insertLast(ivec3(px +1, py +1, 0));
					
					for (int i = 0; i < 2; i++)
					{
						int col = px -1 + i * 5;
						for (int j = 0; j < mdy -1; j++)
						{
							m_brush.SetCell(col, py + j, (j == 0 || j == mdy -2) ? Cell::Wall : Cell::Floor);
							m_brush.SetConsumed(col, py + j);
						}
					}
				}
				
				if (cell.m_edges == ~uint8(1 << 2) || cell.m_edges == ~uint8(1 << 4))
				{
					auto room = ivec4(px, py -3, (mdx - 1), (mdy - 1) +6);
				
					if (!IsFree(rooms, ivec2(room.x, room.y), room.z, room.w))
						continue;
				
					rooms.insertLast(room);
				
					ReservePrefabRoom(rooms, px, py, (mdx - 1), (mdy - 1), None, 1, 1, false);
					toAdd.insertLast(ivec3(px +1, py +1, 1));
					numV++;
					
					for (int i = 0; i < 2; i++)
					{
						int row = py -1 + i * 6;
						for (int j = 0; j < mdx -1; j++)
						{
							m_brush.SetCell(px + j, row, (j == 0 || j == mdx -2) ? Cell::Wall : Cell::Floor);
							m_brush.SetConsumed(px + j, row);
						}
					}
				}
			}
			
			if ((m_placeActShortcut && numV < 3) || numV < 2)
				continue;
			
			int idx = randi(toAdd.length());
			for (uint i = 0; i < toAdd.length(); i++)
			{
				int j = (idx + i) % toAdd.length();
				
				if (toAdd[j].z == 0)
					continue;
			
				m_brush.AddPointOfInterest(Exit, toAdd[j].x, toAdd[j].y);
				toAdd.removeAt(j);
				break;
			}
			
			if (m_placeActShortcut)
			{
				idx = randi(toAdd.length());
				for (uint i = 0; i < toAdd.length(); i++)
				{
					int j = (idx + i) % toAdd.length();
					
					if (toAdd[j].z == 0)
						continue;
				
					m_brush.AddPointOfInterest(PrefabActShortcut, toAdd[j].x, toAdd[j].y);
					toAdd.removeAt(j);
					break;
				}			
			}
			
			while(!toAdd.isEmpty())
			{
				int i = randi(toAdd.length());
				m_brush.AddPointOfInterest(toAdd[i].z == 0 ? PrefabMazePathH : PrefabMazePathV, toAdd[i].x, toAdd[i].y);
				toAdd.removeAt(i);
			}
			
			if (Prefabs)
			{
				array<PointOfInterestType> pfb = {
					PointOfInterestType::Prefab14x14North2,
					PointOfInterestType::Prefab14x14South2,
					PointOfInterestType::Prefab13x13East,
					PointOfInterestType::Prefab13x13West
				};
			
				for (uint i = 0; i < 2; i++)
					placer.PlacePrefabs(pfb, 3, 1);
				
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathN, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathS, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathW, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathE, 30);
				
				placer.m_altPatterns = true;
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathN, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathS, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathW, 30);
				placer.PlacePrefab(PointOfInterestType::PrefabMazePathE, 30);
				placer.m_altPatterns = false;

				placer.PlacePrefab(PointOfInterestType::Prefab2x2Block, 30);
			}
			%PROFILE_STOP
		
			
			
			PlaceCrateBreakables(w, h);
			
			m_brush.GenerateNothingness();
			PlaceEnemies(scene, startPos);
			
			break;
		}
		
		m_brush.Build(scene);
	}
	
	void PlaceCrateBreakable(int x, int y, bool noWall, int chance) override
	{
		int mdx = PathWidth;
		int mdy = PathWidth + 1;

		int mx = (x - Padding) / mdx;
		int my = (y - Padding) / mdy;

		auto cell = m_mazeGrid[mx][my];
		if (cell.m_edges == ~uint8(1 << 1) || cell.m_edges == ~uint8(1 << 3) || cell.m_edges == ~uint8(1 << 2) || cell.m_edges == ~uint8(1 << 4))
			chance = int(chance * 1.75f);
		else if (noWall)
			chance /= 3;
		else
			chance /= 2;
		
		if (x < Padding + 10 || y < Padding + 10 || x >= (Width / 16 - Padding - 10) || y >= (Height / 16 - Padding - 10))
			chance /= 2;
		
		if (randi(100) < chance)
			m_brush.SetCell(x, y, Cell::Breakables);
	}
	
	void ReservePrefabRoom(array<ivec4>@ rooms, int px, int py, int w, int h, PointOfInterestType prefab, int ox, int oy, bool reserve = true)
	{
		if (reserve)
		{
			rooms.insertLast(ivec4(px -2, py -2, w +4, h +4));

			for (int x = 0; x < w; x++)
				m_brush.SetCell(px + x, py, Cell::Floor);
		}
		
		for (int y = (reserve ? 1 : 0); y < h; y++)
		for (int x = 0; x < w; x++)
		{
			m_brush.SetCell(px + x, py + y, Cell::Reserved);
			m_brush.SetConsumed(px + x, py + y);
		}
		
		if (prefab == PointOfInterestType::None)
			return;
		
		m_brush.AddPointOfInterest(prefab, px + ox, py + oy);
	}
	
	bool IsFree(array<ivec4>@ rooms, ivec2 pos, int w, int h)
	{
		int pd = Padding + 3;
		if (pos.x < pd || pos.y < pd || (pos.x + w) >= (Width / 16 - pd -1) || (pos.y + h) >= (Height / 16 - pd -3))
			return false;
	
		for (uint i = 0; i < rooms.length(); i++)
		{
			auto room = rooms[i];
			if (!((room.x) > (pos.x + w) || (room.x + room.z) < (pos.x) || (room.y) > (pos.y + h) || (room.y + room.w) < (pos.y)))
				return false;
		}
		
		return true;
	}
	
	ivec2 FindPrefabRoom(array<ivec4>@ rooms, int w, int h)
	{
		int pd = Padding + 3;
	
		int tw = (m_brush.m_width - pd * 2 - w);
		int th = (m_brush.m_height - pd * 2 - h);
		
		for (int attempt = 0; attempt < 5; attempt++)
		{
			int px = randi(tw) + pd;
			int py = randi(th) + pd;
			
			if (!IsFree(rooms, ivec2(px, py), w, h))
				continue;
			
			return ivec2(px, py);
		}
		
		return ivec2(-1, -1);
	}
	
	ivec2 AddPrefabRoom(array<ivec4>@ rooms, int w, int h, PointOfInterestType prefab, int ox, int oy)
	{
		auto pos = FindPrefabRoom(rooms, w, h);
		if (pos.x >= 0)
			ReservePrefabRoom(rooms, pos.x, pos.y, w, h, prefab, ox, oy);
		
		return pos;
	}
	
	void PlacePrefabs(PrefabPlacement@ placer, array<ivec4>@ rooms)
	{
		AddPrefabRoom(rooms, 25, 27, Prefab21x21Block, 2, 3);
		// AddPrefabRoom(rooms, 17, 22, Prefab13x13Block, 2, 3);
		AddPrefabRoom(rooms, 17, 22, Prefab13x13Block, 2, 3);
		// AddPrefabRoom(rooms, 13, 15, Prefab9x9Block, 2, 3);
		AddPrefabRoom(rooms, 13, 15, Prefab9x9Block, 2, 3);
		AddPrefabRoom(rooms, 13, 15, Prefab9x9Block, 2, 3);
	}
}
