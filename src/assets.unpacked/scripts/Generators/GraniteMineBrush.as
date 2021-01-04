class GraniteMineBrush : DungeonBrush
{
	UnitProducer@ m_h_deco_wall_support;
	UnitProducer@ m_deco_floor_rock;
	
	UnitProducer@ m_torch;
	UnitProducer@ m_brk_plant;
	UnitProducer@ m_deco_vgt1;
	UnitProducer@ m_deco_vgt2;
	
	
	array<UnitPtr> m_spawnedDeco;
	array<UnitPtr> m_spawnedTorches;
	
	int m_grassChanceAdjustment;
	
	array<array<bool>>@ m_gridV2;
	
	
	GraniteMineBrush()
	{
		super();
		
		@m_torch = Resources::GetUnitProducer("doodads/generic/lamp_torch.unit");
		@m_h_deco_wall_support = Resources::GetUnitProducer("doodads/walls/mine_granite/_deco_wall_support.unit");
		@m_deco_floor_rock = Resources::GetUnitProducer("doodads/walls/mine_granite/_deco_floor_rock.unit");
		
		@m_brk_plant = Resources::GetUnitProducer("hw/items/vgt_plant.unit");
		@m_deco_vgt1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt.unit");
		@m_deco_vgt2 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_v2.unit");
		
		LoadPrefabs("mine_granite");
	}
		
	bool SpawnTorchDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return false;
			
		if (randi(100) < 66)
			return false;
			
		m_spawnedTorches.insertLast(m_torch.Produce(scene, pos + vec3(0, 16, 0)));
		return true;
	}
	
	void SpawnHorizontalWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
	}
	
	void SpawnHorizontalWall2Deco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return;
			
		if (randi(100) < 50)
		{
			SpawnTorchDeco(scene, pos + vec3(16, 0, 0), x, y);
			return;
		}
	
		m_spawnedDeco.insertLast(m_h_deco_wall_support.Produce(scene, pos + vec3(16, 16, 0)));
	}
	
	void SpawnVerticalWall2Deco(Scene@ scene, vec3 pos, int x, int y) override
	{
		m_gridV2[x][y] = true;
	}
	
	void SpawnCornerSEWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
	}
		
	void SpawnCornerSWWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
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
	
	void SpawnBreakablePlant(Scene@ scene, vec3 pos)
	{
		m_brk_plant.Produce(scene, pos);
		
		int r = randi(100);
		if (r < 66)
			m_deco_vgt1.Produce(scene, pos + xyz(randdir() * (9 + randi(3))));
		else if (r < 75)
			m_deco_vgt2.Produce(scene, pos + xyz(randdir() * (9 + randi(3))));
	}
	
	void Build(Scene@ scene) override
	{
		auto bt = LoadBaseBrushTiles("mine_granite");
	
		auto arch = Resources::GetUnitProducer("doodads/walls/mine_granite/_deco_ceiling_support.unit");
		auto floor_supp = Resources::GetUnitProducer("doodads/walls/mine_granite/_deco_floor_support.unit");
		
		auto reserved = Resources::GetUnitProducer("doodads/special/color_archives_8.unit");
		

		SpawnPointsOfInterest(scene);
		
		
		auto t_default = Resources::GetTileset("tilesets/mine_granite_sand.tileset");
		auto t_fine = Resources::GetTileset("tilesets/mine_granite_sand_rough.tileset");
		auto t_moss = Resources::GetTileset("hw/tilemaps/e_moss.tileset");
		auto t_moss_grass = Resources::GetTileset("hw/tilemaps/grass.tileset");
		auto t_default_grass = Resources::GetTileset("tilesets/mine_granite_grass_tall.tileset");
		auto t_water = Resources::GetTileset("hw/tilemaps/water.tileset");
		
		
		scene.PaintTileset(t_default, m_posOffset + vec2(m_width * 8, m_height * 8), uint(max(m_width * 16, m_height * 16) * 1.5));
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				vec2 pos(16 * x + m_posOffset.x, 16 * y + m_posOffset.y);
			
				auto cell = m_grid[x][y];
				if(cell == Cell::Breakables)
				{
					scene.PaintTileset(t_moss, pos, 32);
					if (randi(100) < 90)
						scene.PaintTileset(t_moss_grass, pos, 24);
				}
				else if(cell == Cell::Enemies || cell == Cell::MaggotEnemies)
				{
					if (randi(100) < 25)
						scene.PaintTileset(t_fine, pos, 48 + randi(64));
				}
				else if(cell == Cell::Reserved)
				{
					if (randi(100) < (20 + m_grassChanceAdjustment))
						scene.PaintTileset(t_default_grass, pos, 16);
					else if (randi(100) < 10)
						scene.PaintTileset(t_fine, pos, 48 + randi(64));
				}				
				else if(cell == Cell::Floor)
				{
					int wl = 0;
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
					
					if (randi(100) < (10 + wl * 15 + m_grassChanceAdjustment))
						scene.PaintTileset(t_default_grass, pos, 16);
					else if (randi(100) < 5)
						scene.PaintTileset(t_fine, pos, 48 + randi(64));
				}
				else if(cell == Cell::Cliff)
				{
					scene.PaintTileset(t_water, pos, 20);
				}
			}
		}
		
		DoLighting(scene, "mine_granite", 200);
		
		
		@m_gridV2 = array<array<bool>>(m_width, array<bool>(m_height, false));
		
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				if (m_gridConsumed[x][y])
					continue;
			
				auto cell = m_grid[x][y];
				
				if(cell == Cell::Nothing)
					FillCellNothing(scene, bt, x, y);
				else if(cell == Cell::Wall)
					FillCellWall(scene, bt, x, y);
				else if(cell == Cell::Cliff)
					FillCellCliff(scene, bt, x, y);
				else if (cell == Cell::MaggotEnemies)
					FillCellMaggotEnemies(scene, bt, x, y);
					
				else if (cell == Cell::Floor)
				{
					if (randi(100) < 10)
					{
						bool blocked = false;
						for (int dy = -2; dy <= 1; dy++)
						{
							for (int dx = -2; dx <= 1; dx++)
							{
								auto c = GetCell(x + dx, y + dy);
								if (!(c == Cell::Floor || c == Cell::Breakables || c == Cell::Wall || c == Cell::Enemies || c == Cell::MaggotEnemies))
								{
									blocked = true;
									break;
								}
							}
						}
					
						if (!blocked)
							floor_supp.Produce(scene, vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0));
					}
						
					m_gridConsumed[x][y] = true;
				}
				else if(cell == Cell::Breakables)
				{
					if (CanUseBreakables(x + 1, y) && CanUseBreakables(x, y + 1) && CanUseBreakables(x + 1, y + 1))
					{
						vec3 midPos = vec3(16 * (x + 1) + m_posOffset.x, 16 * (y + 1) + m_posOffset.y, 0);
					
						switch (randi(3))
						{
						case 0:
							SpawnBreakablePlant(scene, midPos + vec3(8, 0, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(-5, -8, 0) + MakeSpread(1, 2));
							SpawnBreakablePlant(scene, midPos + vec3(-6, 8, 0) + MakeSpread(2, 2));
							break;
						case 1:
							SpawnBreakablePlant(scene, midPos + vec3(-8, 0, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(4, -8, 0) + MakeSpread(1, 2));
							SpawnBreakablePlant(scene, midPos + vec3(8, 8, 0) + MakeSpread(2, 2));
							break;
						case 2:
							SpawnBreakablePlant(scene, midPos + vec3(-8, -4, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(8, -8, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(4, 8, 0) + MakeSpread(2, 2));
							break;
						}
					
					
						m_gridConsumed[x + 1][y] = true;
						m_gridConsumed[x][y + 1] = true;
						m_gridConsumed[x + 1][y + 1] = true;
					}
					
					else if (GetCell(x + 1, y) == Cell::Floor && randi(100) < 50)
					{
						vec3 midPos = vec3(16 * x + m_posOffset.x + 12, 16 * y + m_posOffset.y + 8, 0);
						SpawnBreakablePlant(scene, midPos + MakeSpread(4, 4));
					}
					else if (GetCell(x, y + 1) == Cell::Floor && randi(100) < 50)
					{
						vec3 midPos = vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 12, 0);
						SpawnBreakablePlant(scene, midPos + MakeSpread(4, 4));
					}
					
					else
					{
						vec3 midPos = vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8, 0);
						SpawnBreakablePlant(scene, midPos + MakeSpread(4, 4));
					}
					
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::Bridge)
				{
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					reserved.Produce(scene, pos);
				
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
		
		for (int y = 0; y < m_height - 2; y++)
		{
			for (int x = 0; x < m_width - 3; x++)
			{
				if (m_gridV2[x][y] && m_gridV2[x + 3][y] && 
					m_grid[x + 1][y] == Cell::Floor && m_grid[x + 2][y] == Cell::Floor &&
					m_grid[x + 1][y + 1] == Cell::Floor && m_grid[x + 1][y + 2] == Cell::Floor)
				{
					if (randi(100) < 75)
						arch.Produce(scene, vec3(16 * (x + 1) + m_posOffset.x + 16, 16 * y + m_posOffset.y - 16, 0));
				}
			}
		}
		
		PlacePaddingColor(scene, bt);
		
		
		RemoveNearbySame(m_spawnedDeco, 50);
		m_spawnedDeco = array<UnitPtr>();
		
		RemoveNearby(m_spawnedTorches, 125);
		m_spawnedTorches = array<UnitPtr>();
	}
	
}
