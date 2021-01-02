class PyramidFancyBrush : DungeonBrush
{
	UnitProducer@ m_torch;
	array<UnitProducer@> m_deco_wall;
	array<UnitProducer@> m_deco_wall_small;

	array<UnitProducer@> m_breakables;
	
	array<UnitPtr> m_spawnedDeco;
	array<UnitPtr> m_spawnedTorches;


	PyramidFancyBrush()
	{
		super();
		
		@m_torch = Resources::GetUnitProducer("doodads/generic/lamp_torch_bowl.unit");
		
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_crack_1.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_crack_2.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_crack_3.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_crack_4.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_pillar_large.unit"));
		m_deco_wall.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_pillar_medium.unit"));
		
		m_deco_wall_small.insertLast(Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_h_pillar_small.unit"));
		
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_vase.unit"));
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_pot.unit"));
		m_breakables.insertLast(Resources::GetUnitProducer("doodads/generic/container_pot_b.unit"));
		
		LoadPrefabs("pyramid_fancy");
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
	
	void SpawnBreakable(Scene@ scene, vec3 pos)
	{
		m_breakables[randi(m_breakables.length())].Produce(scene, pos);
	}
	
	void SpawnHorizontalWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return;
	
		if (SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y))
			return;

		//if (randi(100) < 75)
			m_spawnedDeco.insertLast(m_deco_wall_small[randi(m_deco_wall_small.length())].Produce(scene, pos + vec3(8, 16, 0)));
	}
	
	void SpawnHorizontalWall2Deco(Scene@ scene, vec3 pos, int x, int y) override
	{
		if (!IsOpen(x, y + 1))
			return;
			
		if (randi(100) < 50 && SpawnTorchDeco(scene, pos + vec3(16, 0, 0), x, y))
			return;
		
		//if (randi(100) < 75)
			m_spawnedDeco.insertLast(m_deco_wall[randi(m_deco_wall.length())].Produce(scene, pos + vec3(16, 16, 0)));
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
	
	bool IsOpenFloor(int x, int y)
	{
		auto cell = GetCell(x, y);
		return cell == Cell::Floor || cell == Cell::Breakables || cell == Cell::Enemies || cell == Cell::MaggotEnemies;
	}
	
	void Build(Scene@ scene) override
	{
		auto bt = LoadBaseBrushTiles("pyramid_fancy");
		@bt.wt = Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_floor_8_color.unit");
		
		auto arch = Resources::GetUnitProducer("doodads/walls/pyramid_fancy/_deco_ceiling_support.unit");
		auto reserved = Resources::GetUnitProducer("doodads/special/color_archives_16.unit");
	
	
		SpawnPointsOfInterest(scene);
		
		
		auto t_default = Resources::GetTileset("tilesets/pyramid_fancy_16_offset.tileset");
		auto t_default_big = Resources::GetTileset("tilesets/pyramid_fancy_32_border.tileset");
		
		
		scene.PaintTileset(t_default, m_posOffset + vec2(m_width * 8, m_height * 8), uint(max(m_width * 16, m_height * 16) * 1.5));
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				bool valid = true;
				for (int dx = -1; dx <= 2 && valid; dx++)
				{
					for (int dy = -1; dy <= 2; dy++)
					{
						if (!IsOpenFloor(x + dx, y + dy))
						{
							valid = false;
							continue;
						}
					}
				}
				
				if (valid)
				{
					vec2 pos(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y + 16);
					scene.PaintTileset(t_default_big, pos, 24);
				}
			}
		}

		DoLighting(scene, "pyramid_fancy", 100);
		

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
					if (randi(100) < 33 && GetCell(x - 1, y) == Cell::Wall && GetCell(x + 2, y) == Cell::Wall &&
						IsFloorOrBreakables(x + 1, y) && IsFloorOrBreakables(x, y + 1) && IsFloorOrBreakables(x + 1, y + 1))
						m_spawnedDeco.insertLast(arch.Produce(scene, vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y, 0)));
				
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
						if (q1 != q2 || (randi(100) < 90 && q1))
							SpawnBreakable(scene, midPos + vec3(-3, -4, 0) + MakeSpread(2, 0));
						else if (q1)
						{
							SpawnBreakable(scene, midPos + vec3(-4, -4, 0));
							SpawnBreakable(scene, midPos + vec3(4, -4, 0));
						}	
							
						if (q3 != q4 || (randi(100) < 90 && q3))
							SpawnBreakable(scene, midPos + vec3(3, 4, 0) + MakeSpread(2, 0));
						else if (q3)
						{
							SpawnBreakable(scene, midPos + vec3(-4, 4, 0));
							SpawnBreakable(scene, midPos + vec3(4, 4, 0));
						}
					}
					else
					{
						if (q1 != q3 || (randi(100) < 90 && q1))
							SpawnBreakable(scene, midPos + vec3(-4, -3, 0) + MakeSpread(0, 2));
						else if (q1)
						{
							SpawnBreakable(scene, midPos + vec3(-4, -4, 0));
							SpawnBreakable(scene, midPos + vec3(-4, 4, 0));
						}	
							
						if (q2 != q4 || (randi(100) < 90 && q3))
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
		
		PlacePaddingColor(scene, bt);
		
		
		RemoveNearbySame(m_spawnedDeco, 50);
		m_spawnedDeco = array<UnitPtr>();
		
		RemoveNearby(m_spawnedTorches, 125);
		m_spawnedTorches = array<UnitPtr>();
	}
}
