class DesertBrush : DungeonBrush
{
	array<UnitPtr> m_spawnedDeco;
	

	DesertBrush()
	{
		super();
		
		LoadPrefabs("desert");
	}
	
	bool SpawnTorchDeco(Scene@ scene, vec3 pos, int x, int y) override { return true; }
	void SpawnBreakable(Scene@ scene, vec3 pos) { }
	void SpawnHorizontalWallDeco(Scene@ scene, vec3 pos, int x, int y) override { }
	void SpawnHorizontalWall2Deco(Scene@ scene, vec3 pos, int x, int y) override { }
	void SpawnCornerSEWallDeco(Scene@ scene, vec3 pos, int x, int y) override { }
	void SpawnCornerSWWallDeco(Scene@ scene, vec3 pos, int x, int y) override { }

	void Build(Scene@ scene) override
	{
		auto bt = LoadBaseBrushTiles("pyramid_slum");

		auto reserved = Resources::GetUnitProducer("doodads/special/color_archives_16.unit");
		auto cactus = Resources::GetUnitProducer("doodads/terrain/cactus.unit");
		auto stone = Resources::GetUnitProducer("doodads/terrain/stone_desert_small.unit");
	
	
		SpawnPointsOfInterest(scene);
		
		
		auto t_default = Resources::GetTileset("tilesets/desert.tileset");
		auto t_dirt = Resources::GetTileset("tilesets/desert_flat.tileset");
		auto t_default_grass = Resources::GetTileset("tilesets/desert_grass_tall.tileset");
		
		
		
		scene.PaintTileset(t_default, m_posOffset + vec2(m_width * 8, m_height * 8), uint(max(m_width * 16, m_height * 16) * 2.0) + 2000);
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				vec2 pos(16 * x + m_posOffset.x, 16 * y + m_posOffset.y);
			
				auto cell = m_grid[x][y];
				if(cell == Cell::Enemies || cell == Cell::MaggotEnemies)
				{
					if (randi(100) < 33)
						scene.PaintTileset(t_dirt, pos, 24 + randi(32));
				}
				else if(cell == Cell::Reserved)
				{
					if (randi(100) < 8)
						scene.PaintTileset(t_dirt, pos, 24 + randi(48));
				}
				else if(cell == Cell::Floor || cell == Cell::Breakables)
				{
					if (randi(100) < 1)
						scene.PaintTileset(t_default_grass, pos, 16);
					else if (randi(100) < 8)
						scene.PaintTileset(t_dirt, pos, 24 + randi(48));
				}
			}
		}
		
		
		DoLighting(scene, "desert", 100);
		

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
					//if (randi(1000) < 1)
					//	m_spawnedDeco.insertLast(cactus.Produce(scene, vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8, 0)));
					if (randi(1000) < 32)
						stone.Produce(scene, vec3(16 * x + m_posOffset.x + randi(16), 16 * y + m_posOffset.y + randi(16), 0));
				
					m_gridConsumed[x][y] = true;
				}
				else if(cell == Cell::Breakables)
				{
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::Bridge)
				{
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
		
		
		RemoveNearbySame(m_spawnedDeco, 75);
		m_spawnedDeco = array<UnitPtr>();
	}
}
