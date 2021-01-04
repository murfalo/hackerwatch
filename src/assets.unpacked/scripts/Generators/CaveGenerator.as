[Generator]
class CaveGenerator : DungeonGenerator
{
	[Editable default=3000]
	int Width;
	[Editable default=2000]
	int Height;
	
	[Editable default=1]
	int Thickness;
	
	[Editable default=3]
	int RoomSize;
	
	[Editable default=4]
	int Erosion;

	[Editable default=100]
	int Density;
	
	[Editable default=5]
	int Cleanup;
	
	[Editable default=6]
	int Breakables;
	
	[Editable default=false]
	bool River;
	
	[Editable default=true]
	bool Prefabs;
	
	
	void Generate(Scene@ scene) override
	{
		while (true)
		{
			print("Generating level...");
		
			int w = Width / 16;
			int h = Height / 16;
		
			MakeBrush();
			m_brush.Initialize(w, h, vec2(-Width / 2, -Height / 2));
			
			array<ivec2> riverPoints;
			if (River)
			{
				riverPoints.insertLast(ivec2((w + randi(w)) / 3, 0));
				riverPoints.insertLast(ivec2((w + randi(w)) / 3, h));
				
				while(riverPoints.length() < uint(h / 10))
				{
					for (uint i = 0; i < riverPoints.length() - 1;)
					{
						ivec2 d = riverPoints[i] - riverPoints[i + 1];
						int dt = int(sqrt(d.x * d.x + d.y * d.y)) / 3;
						
						ivec2 mid = (riverPoints[i] + riverPoints[i + 1]) / 2;
											
						mid.x += randi(dt) - dt / 2;
						mid.y += randi(dt / 2) - dt / 4;
						
						riverPoints.insertAt(i + 1, mid);
						i += 2;
					}
				}

				for (uint i = 0; i < riverPoints.length() - 1; i++)
					PlotLine(riverPoints[i], riverPoints[i + 1], randi(3) + 2, Cell::Cliff);
			}
	
	
			int padding = Thickness + Erosion + Cleanup + 10;
			int numKeypoints = max(3, int(sqrt(w * h) / 1000.0f * Density));
			
			array<ivec2> keypoints;
			for (int i = 0; i < numKeypoints;)
			{
				ivec2 kp(randi(w), randi(h));
				bool isValid = true;
				
				for (uint j = 0; j < riverPoints.length(); j++)
				{
					auto dt = riverPoints[j] - kp;
					if (dt.x * dt.x + dt.y * dt.y < 15 * 15)
					{
						isValid = false;
						break;
					}
				}
				
				if (isValid)
				{
					keypoints.insertLast(kp);
					i++;
				}
			}


			for (int i = 0; i < numKeypoints; i++)
			{
				vec2 force;
				int num = 0;
			
				for (int j = 0; j < numKeypoints; j++)
				{
					if (i == j)
						continue;
				
					vec2 d(float(keypoints[j].x - keypoints[i].x), float(keypoints[j].y - keypoints[i].y));
					if (lengthsq(d) < Thickness * Thickness * 10 * 10)
					{
						force += normalize(d);
						num++;
					}
				}
				
				if (num > 0)
					force = (force / num) * Thickness * 10;
					
				ivec2 newPt(keypoints[i].x - int(force.x), keypoints[i].y - int(force.y));
				
				newPt.x = clamp(newPt.x, padding, w - padding);
				newPt.y = clamp(newPt.y, padding, h - padding);
				
				keypoints[i] = newPt;
			}
			
			for (int i = 0; i < numKeypoints; i++)
			{
				if (i > 0)
				{
					int drawTo = i;
					while (drawTo == i)
						drawTo = randi(i);
				
					PlotLine(keypoints[i], keypoints[drawTo], randi(Thickness - 1) + 1, Cell::Floor);
				}
				
				int rpn = randi(6) + 5;
				for (int j = 0; j < rpn; j++)
				{
					ivec2 rpos = keypoints[i] + ivec2(randi(RoomSize * 2) - RoomSize, randi(RoomSize * 2) - RoomSize);
					rpos.x = clamp(rpos.x, padding, w - padding);
					rpos.y = clamp(rpos.y, padding, h - padding);
					
					PlotLine(keypoints[i], rpos, Thickness, Cell::Floor);
				}
			}
			
			for (int i = 0; i < Erosion; i++)
			{
				for (int y = 0; y < h; y++)
				{
					for (int x = 0; x < w; x++)
					{
						if (randi(100) > 25)
							continue;
					
						if (m_brush.GetCell(x, y) == Cell::Wall)
						{
							if (m_brush.GetCell(x - 1, y) == Cell::Floor || 
								m_brush.GetCell(x + 1, y) == Cell::Floor || 
								m_brush.GetCell(x, y - 1) == Cell::Floor || 
								m_brush.GetCell(x, y + 1) == Cell::Floor)
								m_brush.SetCell(x, y, Cell::Floor);
						}
						else if (m_brush.GetCell(x, y) == Cell::Floor)
						{
							int wl = 0;
							if (IsWall(m_brush.GetCell(x, y - 1))) wl++;
							if (IsWall(m_brush.GetCell(x - 1, y))) wl++;
							if (IsWall(m_brush.GetCell(x + 1, y))) wl++;
							if (IsWall(m_brush.GetCell(x, y + 1))) wl++;
							
							if (wl == 1)
								m_brush.SetCell(x, y, Cell::Wall);
						}
					}
				}
			}
			
			// Widen H-paths
			for (int y = 0; y < h; y++)
			{
				for (int x = 0; x < w; x++)
				{
					if (m_brush.GetCell(x, y) == Cell::Floor)
					{
						if (IsWall(m_brush.GetCell(x, y - 1)) && 
							IsWall(m_brush.GetCell(x, y + 1)))
						{
							if (randi(100) < 50)
								m_brush.SetCell(x, y - 1, Cell::Floor);
							else
								m_brush.SetCell(x, y + 1, Cell::Floor);
						}
					}
				}
			}
			
			
			for (int i = 0; i < Cleanup; i++)
			{
				for (int y = 0; y < h; y++)
				{
					for (int x = 0; x < w; x++)
					{
						int wl = 0;
						if (IsWall(m_brush.GetCell(x - 1, y - 1))) wl++;
						if (IsWall(m_brush.GetCell(x, y - 1))) wl++;
						if (IsWall(m_brush.GetCell(x + 1, y - 1))) wl++;
						if (IsWall(m_brush.GetCell(x - 1, y))) wl++;
						if (IsWall(m_brush.GetCell(x + 1, y))) wl++;
						if (IsWall(m_brush.GetCell(x - 1, y + 1))) wl++;
						if (IsWall(m_brush.GetCell(x, y + 1))) wl++;
						if (IsWall(m_brush.GetCell(x + 1, y + 1))) wl++;
						
						if (m_brush.GetCell(x, y) == Cell::Wall)
						{
							if ((wl == 0 && randi(100) < 50) ||
								(wl == 2 && randi(100) < 66) ||
								(wl == 3 && randi(100) < 20) ||
								 wl == 1)
								m_brush.SetCell(x, y, Cell::Floor);
						}
						/*
						else if (m_brush.GetCell(x, y) == Cell::Floor)
						{
							if ((wl == 6 && randi(100) < 33) ||
								(wl == 7 && randi(100) < 50) ||
								 wl == 8)
								m_brush.SetCell(x, y, Cell::Wall);
						}
						*/
					}
				}
			}
			
			
			
			
			if (Breakables > 0)
			{
				for (int i = 0; i < numKeypoints; i++)
				{
					for (int j = 0; j < Breakables; j++)
					{
						auto dir = ivec2(randi(8) - 4, randi(8) - 6);
						if (dir.x == 0 && dir.y == 0)
							continue;
					
						auto pos = FindWall(keypoints[i], dir);
						
						for (int y = -1; y <= 1; y++)
						{
							for (int x = -1; x <= 1; x++)
							{
								if (randi(100) < 50)
									continue;
										
								if (m_brush.GetCell(pos.x + x, pos.y + y) == Cell::Floor)
									m_brush.SetCell(pos.x + x, pos.y + y, Cell::Breakables);
							}
						}
					}
				}

			
				// Spread
				for (int y = 0; y < h; y++)
				{
					for (int x = 0; x < w; x++)
					{
						int spreadS = -2;
						int spreadE = 2;
						
						if (m_brush.GetCell(x, y) == Cell::Floor)
						{
							if (m_brush.GetCell(x, y - 1) == Cell::Wall && randi(100) < (20 + Breakables))
								m_brush.SetCell(x, y, Cell::Breakables);
						
							spreadS = 0;
							spreadE = 1;
						}
						
						if (m_brush.GetCell(x, y) == Cell::Breakables)
						{
							if (randi(100) < 33)
							{
								m_brush.SetCell(x, y, Cell::Floor);
								continue;
							}
						
							for (int y2 = spreadS; y2 <= spreadE; y2++)
							{
								for (int x2 = spreadS; x2 <= spreadE; x2++)
								{
									if (randi(100) < 85)
										continue;
								
									if (m_brush.GetCell(x + x2, y + y2) == Cell::Floor)
										m_brush.SetCell(x + x2, y + y2, Cell::Breakables);
								}
							}
						}
					}
				}
				
				// Cleanup
				for (int y = 0; y < h; y++)
				{
					for (int x = 0; x < w; x++)
					{
						if (m_brush.GetCell(x, y) == Cell::Breakables)
						{
							if (m_brush.GetCell(x, y + 1) == Cell::Wall || m_brush.GetCell(x, y + 2) == Cell::Wall)
								m_brush.SetCell(x, y, Cell::Floor);
						}
					}
				}
			}
			
			
			auto wlk = Pattern::Walkable;
			auto nwl = Pattern::NotWall;
			auto wll = Pattern::Wall;
			auto nwk = Pattern::NotWalkable;
			auto any = Pattern::Anything;
			auto nth = Pattern::Nothing;
			
			
			PatternMatcher ptrnMtch;
			
			ptrnMtch.RemoveDiagonals(m_brush);
			
			
			
			
			ivec2 startPos;
			
			{
				array<array<Pattern>> ptrn = {
					{any, wll, wll, any},
					{wll, wll, wll, wll},
					{any, wlk, wlk, any},
					{any, wlk, wlk, any},
					{any, wlk, wlk, any}
				};

				auto allExits = ptrnMtch.FindAllPatterns(m_brush, ptrn);
				if (allExits.length() < 2)
					continue;
					
				
				float longestDist = 0;
				ivec2 points;
				
				for (uint i = 0; i < allExits.length(); i++)
				{
					for (uint j = 0; j < allExits.length(); j++)
					{
						auto d = allExits[i] - allExits[j];
						float dist = float(d.x) * float(d.x) + float(d.y) * float(d.y);
						if (dist > longestDist)
						{
							longestDist = dist;
							points = ivec2(i, j);
						}
					}
				}
				
				float minDist = (w + h) / 4.f;
				if (longestDist < minDist * minDist)
					continue;
				
				auto pos = allExits[points.x];
				m_brush.SetConsumed(pos.x + 1, pos.y + 1);
				m_brush.SetConsumed(pos.x + 2, pos.y + 1);
				m_brush.SetConsumed(pos.x + 1, pos.y + 2);
				m_brush.SetConsumed(pos.x + 2, pos.y + 2);
				m_brush.AddPointOfInterest(PointOfInterestType::Entry, pos.x + 1, pos.y + 1);
				startPos = ivec2(pos.x + 1, pos.y + 1);
				
				for (int y = 2; y <= 5; y++)
				{
					for (int x = -2; x <= 2; x++)
					{
						if (m_brush.GetCell(pos.x + x, pos.x + y) == Cell::Breakables)
							m_brush.SetCell(pos.x + x, pos.x + y, Cell::Floor);
					}
				}
				
				m_startPos = vec2(16 * startPos.x + m_brush.m_posOffset.x + 16, 16 * startPos.y + m_brush.m_posOffset.y + 24);
				g_spawnPos = m_startPos;
				
				
				pos = allExits[points.y];
				m_brush.SetConsumed(pos.x + 1, pos.y + 1);
				m_brush.SetConsumed(pos.x + 2, pos.y + 1);
				m_brush.SetConsumed(pos.x + 1, pos.y + 2);
				m_brush.SetConsumed(pos.x + 2, pos.y + 2);
				m_brush.AddPointOfInterest(PointOfInterestType::Exit, pos.x + 1, pos.y + 1);
			}
			
			
			
			
			
			if (Prefabs)
			{
				%PROFILE_START Prefabs
	
				auto cig = PatternCommand::Ignore;
				auto crs = PatternCommand::Reserve;
				auto crw = PatternCommand::ReserveWall;
				auto cwl = PatternCommand::Wall;
				auto cfl = PatternCommand::Floor;
	
				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab9x9North))
				{
					array<array<Pattern>> ptrn = {
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
					
					array<array<PatternCommand>> repl = {
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
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 2);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab9x9North, pos[i].x + 1, pos[i].y + 1);
				}

				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab5x5North))
				{
					array<array<Pattern>> ptrn = {
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
					
					array<array<PatternCommand>> repl = {
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
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 3);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab5x5North, pos[i].x + 1, pos[i].y + 1);
				}

				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab3x3North))
				{
					array<array<Pattern>> ptrn = {
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
					
					array<array<PatternCommand>> repl = {
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
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 4);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab3x3North, pos[i].x + 1, pos[i].y + 1);
				}

				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab7x7Block))
				{
					array<array<Pattern>> ptrn = {
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
					
					array<array<PatternCommand>> repl = {
						{cig, cig, cig, cig, cig, cig, cig, cig, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, crs, crs, cig},
						{cig, cig, cig, cig, cig, cig, cig, cig, cig},
						{cig, cig, cig, cig, cig, cig, cig, cig, cig}
					};
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 4);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab7x7Block, pos[i].x + 1, pos[i].y + 1);
				}
				
				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab5x5Block))
				{
					array<array<Pattern>> ptrn = {
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk, wlk, wlk}
					};
					
					array<array<PatternCommand>> repl = {
						{cig, cig, cig, cig, cig, cig, cig},
						{cig, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, cig},
						{cig, crs, crs, crs, crs, crs, cig},
						{cig, cig, cig, cig, cig, cig, cig},
						{cig, cig, cig, cig, cig, cig, cig}
					};
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 4);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab5x5Block, pos[i].x + 1, pos[i].y + 1);
				}
				/*
				if (m_brush.HasPointOfInterest(PointOfInterestType::Prefab3x3Block))
				{
					array<array<Pattern>> ptrn = {
						{wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk},
						{wlk, wlk, wlk, wlk, wlk}
					};
					
					array<array<PatternCommand>> repl = {
						{cig, cig, cig, cig, cig},
						{cig, crs, crs, crs, cig},
						{cig, crs, crs, crs, cig},
						{cig, crs, crs, crs, cig},
						{cig, cig, cig, cig, cig},
						{cig, cig, cig, cig, cig}
					};
					
					auto pos = ptrnMtch.ReservePrefabs(m_brush, ptrn, repl, 6);
					for (uint i = 0; i < pos.length(); i++)
						m_brush.AddPointOfInterest(PointOfInterestType::Prefab3x3Block, pos[i].x + 1, pos[i].y + 1);
				}
				*/
				%PROFILE_STOP
			}
			
			m_brush.GenerateNothingness();
			PlaceEnemies(scene, startPos);
			
			break;
		}
		
		m_brush.Build(scene);
	}
	
	
	
	bool IsWall(Cell cell)
	{
		return (cell == Cell::Wall || cell == Cell::Nothing || cell == Cell::Outside);
	}
	
	
	ivec2 FindWall(ivec2 start, ivec2 delta)
	{
		int dx = abs(delta.x);
		int dy = abs(delta.y);
		int sx = delta.x < 0 ? 1 : -1;
		int sy = delta.y < 0 ? 1 : -1;
		int err = (dx > dy ? dx : -dy) / 2;
	 
		for(;;)
		{
			ivec2 prevPt = start;

			int e2 = err;
			if (e2 > -dx) 
			{ 
				err -= dy; 
				start.x += sx; 
			}

			if (e2 < dy) 
			{ 
				err += dx; 
				start.y += sy;
			}
			
			if (IsWall(m_brush.GetCell(start.x, start.y)))
				return prevPt;
		}
		
		return start;
	}
}


