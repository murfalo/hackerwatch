class ArchivesBrush : DungeonBrush
{
	UnitProducer@ m_torch;
	UnitProducer@ m_deco_books_16;
	UnitProducer@ m_deco_books_32;
	
	array<UnitProducer@> m_deco_wall;
	array<UnitProducer@> m_deco_books;
	
	array<UnitProducer@> m_breakables;
	array<UnitProducer@> m_coins;
	
	array<UnitPtr> m_spawnedDeco;
	array<UnitPtr> m_spawnedTorches;
	
	array<array<bool>>@ m_gridBooks;
	


	ArchivesBrush()
	{
		super();
		
		@m_torch = Resources::GetUnitProducer("doodads/generic/lamp_torch.unit");
		
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_square_blue.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_square_green.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_square_red.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_square_yellow.unit"));
		
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_1.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_pillar_2.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_blackboard.unit"));
		
		m_deco_books.insertLast(Resources::GetUnitProducer("doodads/walls/archives/_deco_ladder.unit"));
		
		
		@m_deco_books_16 = Resources::GetUnitProducer("doodads/walls/archives/_deco_books_16.unit");
		@m_deco_books_32 = Resources::GetUnitProducer("doodads/walls/archives/_deco_books_32.unit");
		
		
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_barrel_b.unit"));
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_crate_b.unit"));
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_vase.unit"));
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_vase.unit"));
		
		
		m_coins.insertLast(Resources::GetUnitProducer("items/money_copper_1.unit"));
		m_coins.insertLast(Resources::GetUnitProducer("items/money_silver_1.unit"));
		m_coins.insertLast(Resources::GetUnitProducer("items/money_silver_2.unit"));
		m_coins.insertLast(Resources::GetUnitProducer("items/money_gold_1.unit"));
		
		
		LoadPrefabs("archives");
	}
	
	bool SpawnTorchDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return false;
			
		if (randi(100) < 66)
			return false;
			
		m_spawnedTorches.insertLast(m_torch.Produce(scene, pos + vec3(0, 16 + 0.1, 0)));

		return true;
	}
	
	void SpawnBreakable(Scene@ scene, vec3 pos)
	{
		if (randi(100) < 75)
			m_breakables[randi(m_breakables.length())].Produce(scene, pos);
		else
			m_coins[randi(m_coins.length())].Produce(scene, pos + MakeSpread(2, 2));
	}
	
	void SpawnHorizontalWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return;
	
		if (SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y))
			return;

		if (randi(100) < 75)
		{
			m_deco_books_16.Produce(scene, pos + vec3(0, 16, 0));
			m_gridBooks[x][y] = true;
			
			if (randi(100) < 20)
				m_spawnedDeco.insertLast(m_deco_books[randi(m_deco_books.length())].Produce(scene, pos + vec3(8, 16 + 1, 0)));
		}
		else
		{
			if (!m_gridBooks[x -1][y] && !m_gridBooks[x +1][y])
				m_spawnedDeco.insertLast(m_deco_wall[randi(m_deco_wall.length())].Produce(scene, pos + vec3(8, 16, 0)));
		}
	}
	
	void SpawnHorizontalWall2Deco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return;
			
		if (randi(100) < 50 && SpawnTorchDeco(scene, pos + vec3(16, 0, 0), x, y))
			return;
		
		if (randi(100) < 75)
		{
			m_deco_books_32.Produce(scene, pos + vec3(16, 16, 0));
			m_gridBooks[x][y] = true;
			m_gridBooks[x + 1][y] = true;
			
			if (randi(100) < 20)
				m_spawnedDeco.insertLast(m_deco_books[randi(m_deco_books.length())].Produce(scene, pos + vec3(8, 16 + 1, 0)));
		}
		else
		{
			if (!m_gridBooks[x -1][y] && !m_gridBooks[x +1][y])
				m_spawnedDeco.insertLast(m_deco_wall[randi(m_deco_wall.length())].Produce(scene, pos + vec3(16, 16, 0)));
		}
	}
	
	void SpawnCornerSEWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
		//SpawnHorizontalWallDeco(scene, pos, x, y);
	}
	
	void SpawnCornerSWWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
		//SpawnHorizontalWallDeco(scene, pos, x, y);
	}
	
	bool CanUseBreakables(int x, int y)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return false;
		return !m_gridConsumed[x][y] && m_grid[x][y] == Cell::Breakables;
	}
	
	bool IsFloorOrBreakables(int x, int y)
	{
		auto cell = GetCell(x, y);
		return cell == Cell::Breakables || cell == Cell::Floor;
	}
		
	void Build(Scene@ scene) override
	{
		auto bt = LoadBaseBrushTiles("archives");
		
		auto arch = Resources::GetUnitProducer("doodads/walls/archives/_deco_ceiling_support.unit");
		auto reserved = Resources::GetUnitProducer("doodads/special/color_prison_16.unit");
	
	
		SpawnPointsOfInterest(scene);
		
		
		auto t_default = Resources::GetTileset("tilesets/archives_tiles_red.tileset");
		auto t_dirt = Resources::GetTileset("tilesets/archives_dirt.tileset");
		auto t_moss = Resources::GetTileset("tilesets/archives_moss.tileset");
		auto t_grass = Resources::GetTileset("tilesets/prison_grass_tall.tileset");
		
		
		scene.PaintTileset(t_default, m_posOffset + vec2(m_width * 8, m_height * 8), uint(max(m_width * 16, m_height * 16) * 1.5));
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				vec2 pos(16 * x + m_posOffset.x, 16 * y + m_posOffset.y);
			
				auto cell = m_grid[x][y];
				if(cell == Cell::Enemies || cell == Cell::MaggotEnemies)
				{
					if (randi(100) < 50)
						scene.PaintTileset(t_dirt, pos, 24 + randi(16));
				}
				else if(cell == Cell::Reserved)
				{
					if (randi(100) < 15)
						scene.PaintTileset(t_moss, pos, 16);
					else if (randi(100) < 10)
						scene.PaintTileset(t_dirt, pos, 24 + randi(16));
				}
				else if(cell == Cell::Floor || cell == Cell::Breakables)
				{
					if (randi(100) < 25)
						scene.PaintTileset(t_dirt, pos, 16 + randi(16));
						
					if (IsCliff(x -1, y) || IsCliff(x +1, y) || IsCliff(x, y -1) || IsCliff(x, y +1))
						continue;
				
					int wl = 1;
					if (CanUseBreakables(x - 1, y - 1)) wl++;
					if (CanUseBreakables(x, y - 1)) wl++;
					if (CanUseBreakables(x + 1, y - 1)) wl++;
					if (CanUseBreakables(x - 1, y)) wl++;
					if (CanUseBreakables(x + 1, y)) wl++;
					if (CanUseBreakables(x - 1, y + 1)) wl++;
					if (CanUseBreakables(x, y + 1)) wl++;
					if (CanUseBreakables(x + 1, y + 1)) wl++;
					if (CanUseBreakables(x + 2, y)) wl++;
					if (CanUseBreakables(x - 2, y)) wl++;
					if (CanUseBreakables(x, y + 2)) wl++;
					if (CanUseBreakables(x, y - 2)) wl++;

					if (randi(100) < (25 + wl * 15))
					{
						scene.PaintTileset(t_moss, pos, 24 + randi(28));

						if (randi(100) < 25)
							scene.PaintTileset(t_grass, pos, 20 + randi(16));
					}
				}
			}
		}
		
		DoLighting(scene, "archives", 80);
		
		@m_gridBooks = array<array<bool>>(m_width, array<bool>(m_height, false));

		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				if (m_gridConsumed[x][y])
					continue;
			
				auto cell = m_grid[x][y];
				
				if (cell == Cell::Nothing)
					FillCellNothing(scene, bt, x, y);
				else if (cell == Cell::Wall)
					FillCellWall(scene, bt, x, y);
				else if (cell == Cell::Cliff)
					FillCellCliff(scene, bt, x, y);
				else if (cell == Cell::MaggotEnemies)
					FillCellMaggotEnemies(scene, bt, x, y);
				
				else if (cell == Cell::Floor)
				{
					if (randi(100) < 33 && GetCell(x - 1, y) == Cell::Wall && GetCell(x + 2, y) == Cell::Wall &&
						IsFloorOrBreakables(x + 1, y) && IsFloorOrBreakables(x, y + 1) && IsFloorOrBreakables(x + 1, y + 1))
						m_spawnedDeco.insertLast(arch.Produce(scene, vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y, 0)));
						
					int wl = 0;
					if (CanUseBreakables(x - 1, y - 1)) wl++;
					if (CanUseBreakables(x, y - 1)) wl++;
					if (CanUseBreakables(x + 1, y - 1)) wl++;
					if (CanUseBreakables(x - 1, y)) wl++;
					if (CanUseBreakables(x + 1, y)) wl++;
					if (CanUseBreakables(x - 1, y + 1)) wl++;
					if (CanUseBreakables(x, y + 1)) wl++;
					if (CanUseBreakables(x + 1, y + 1)) wl++;

					if (wl > 0 && randi(100) < (20 + wl * 15))
					{
						vec3 pos = vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y + 16, 0) + MakeSpread(4, 4);
						m_coins[randi(m_coins.length())].Produce(scene, pos);
					}

					m_gridConsumed[x][y] = true;
				}
				else if(cell == Cell::Breakables)
				{
					bool q1, q2, q3, q4;
					q1 = q2 = q3 = q4 = false;
				
					if (IsWallOrBreakable(x, y -1))
						q1 = q2 = true;
					if (IsWallOrBreakable(x, y +1))
						q3 = q4 = true;
					if (IsWallOrBreakable(x -1, y))
						q1 = q3 = true;
					if (IsWallOrBreakable(x +1, y))
						q2 = q4 = true;
					
					m_gridConsumed[x][y] = true;
					
					
					vec3 midPos = vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8, 0);
					
					if (!q1 && !q2 && !q3 && !q4)
						SpawnBreakable(scene, midPos + MakeSpread(4, 4));
					
					if (randi(100) < 50)
					{
						if (q1 != q2 || (randi(100) < 30 && q1))
							SpawnBreakable(scene, midPos + vec3(-3, -4, 0) + MakeSpread(2, 0));
						else if (q1)
						{
							SpawnBreakable(scene, midPos + vec3(-4, -4, 0));
							SpawnBreakable(scene, midPos + vec3(4, -4, 0));
						}	
							
						if (q3 != q4 || (randi(100) < 30 && q3))
							SpawnBreakable(scene, midPos + vec3(3, 4, 0) + MakeSpread(2, 0));
						else if (q3)
						{
							SpawnBreakable(scene, midPos + vec3(-4, 4, 0));
							SpawnBreakable(scene, midPos + vec3(4, 4, 0));
						}
					}
					else
					{
						if (q1 != q3 || (randi(100) < 30 && q1))
							SpawnBreakable(scene, midPos + vec3(-4, -3, 0) + MakeSpread(0, 2));
						else if (q1)
						{
							SpawnBreakable(scene, midPos + vec3(-4, -4, 0));
							SpawnBreakable(scene, midPos + vec3(-4, 4, 0));
						}	
							
						if (q2 != q4 || (randi(100) < 30 && q3))
							SpawnBreakable(scene, midPos + vec3(4, 3, 0) + MakeSpread(0, 2));
						else if (q2)
						{
							SpawnBreakable(scene, midPos + vec3(4, -4, 0));
							SpawnBreakable(scene, midPos + vec3(4, 4, 0));
						}
					}
				}
				else if (cell == Cell::Bridge)
				{
					/*
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					reserved.Produce(scene, pos);
					*/
				
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::Reserved)
				{
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					reserved.Produce(scene, pos);
					
				
					m_gridConsumed[x][y] = true;
				}
			}
		}
		

		auto capL = Resources::GetUnitProducer("doodads/walls/archives/_deco_books_cap_l.unit");
		auto capR = Resources::GetUnitProducer("doodads/walls/archives/_deco_books_cap_r.unit");
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				if (m_grid[x][y] != Cell::Wall)
					continue;

				if (!IsOpen(x, y + 1))
					continue;
			
				if (m_gridBooks[x][y])
					continue;
					
					
				auto r = m_gridBooks[x + 1][y];
				auto l = m_gridBooks[x - 1][y];
				
				if (r)
					capL.Produce(scene, vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y + 16, 0));
				if (l)
					capR.Produce(scene, vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y + 16, 0));
			}
		}
		
		PlacePaddingColor(scene, bt);
		
		
		RemoveNearbySame(m_spawnedDeco, 50);
		m_spawnedDeco = array<UnitPtr>();
		
		RemoveNearby(m_spawnedTorches, 125);
		m_spawnedTorches = array<UnitPtr>();
	}
}
