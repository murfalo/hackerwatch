class SandCaveBrush : DungeonBrush
{
	UnitProducer@ m_h_deco_crack1;
	UnitProducer@ m_h_deco_crack2;
	UnitProducer@ m_h_deco_crack3;
	
	UnitProducer@ m_h_deco_ivy1;
	UnitProducer@ m_h_deco_ivy2;
	UnitProducer@ m_h_deco_ivy3;
	UnitProducer@ m_h_deco_ivy4;

	UnitProducer@ m_sw_deco_ivy;
	UnitProducer@ m_se_deco_ivy;
	
	UnitProducer@ m_torch;
	UnitProducer@ m_brk_plant;
	UnitProducer@ m_deco_vgt1;
	UnitProducer@ m_deco_vgt2;
		
	
	array<UnitPtr> m_spawnedDeco;
	array<UnitPtr> m_spawnedTorches;
	
	
	SandCaveBrush()
	{
		super();
		
		@m_h_deco_crack1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_crack.unit");
		@m_h_deco_crack2 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_crack_v2.unit");
		@m_h_deco_crack3 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_crack_v3.unit");
		
		@m_h_deco_ivy1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_ivy.unit");
		@m_h_deco_ivy2 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_ivy_v2.unit");
		@m_h_deco_ivy3 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_ivy_v3.unit");
		@m_h_deco_ivy4 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_ivy_v4.unit");
		
		@m_sw_deco_ivy = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_overhang.unit");
		@m_se_deco_ivy = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_overhang_v2.unit");
		
		@m_torch = Resources::GetUnitProducer("doodads/generic/lamp_torch.unit");
		@m_brk_plant = Resources::GetUnitProducer("hw/items/vgt_plant.unit");
		@m_deco_vgt1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt.unit");
		@m_deco_vgt2 = Resources::GetUnitProducer("hw/doodads/theme_e/e_deco_vgt_v2.unit");
		
		LoadPrefabs("theme_e");
	}
	
	bool HasPointOfInterest(PointOfInterestType poi) override { return true; }
	
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
		if (!IsOpen(x, y + 1))
			return;
	
		int r = randi(7);
		if (r == 0)
			m_spawnedDeco.insertLast(m_h_deco_crack1.Produce(scene, pos + vec3(0, 16, 0)));
		else if (r == 1)
			m_spawnedDeco.insertLast(m_h_deco_crack2.Produce(scene, pos + vec3(16, 16, 0)));
		else if (r == 2)
			m_spawnedDeco.insertLast(m_h_deco_crack3.Produce(scene, pos + vec3(0, 16, 0)));
			
		else if (r == 3)
			m_spawnedDeco.insertLast(m_h_deco_ivy1.Produce(scene, pos + vec3(8, 16, 0)));
		else if (r == 4)
			m_spawnedDeco.insertLast(m_h_deco_ivy2.Produce(scene, pos + vec3(8, 16, 0)));
		else if (r == 5)
			m_spawnedDeco.insertLast(m_h_deco_ivy3.Produce(scene, pos + vec3(8, 16, 0)));
		else if (r == 6)
			m_spawnedDeco.insertLast(m_h_deco_ivy4.Produce(scene, pos + vec3(8, 16, 0)));
		
		if (r < 3)
			SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
	}
	
	void SpawnCornerSEWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
	
		if (!IsOpen(x + 1, y + 1))
			return;
	
		if (randi(100) < 33)
			m_spawnedDeco.insertLast(m_se_deco_ivy.Produce(scene, pos + vec3(5, -20, 0)));
	}
	
	void SpawnCornerSWWallDeco(Scene@ scene, vec3 pos, int x, int y) override
	{
		SpawnTorchDeco(scene, pos + vec3(8, 0, 0), x, y);
	
		if (!IsOpen(x - 1, y + 1))
			return;
	
		if (randi(100) < 33)
			m_spawnedDeco.insertLast(m_sw_deco_ivy.Produce(scene, pos + vec3(5, -20, 0)));
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
		scene.SetEnvironment(Resources::GetEnvironment("effects/env/mine.env"));
		
	
		auto no = Resources::GetUnitProducer("hw/doodads/theme_e/e_special_pillar.unit");
		auto h1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_h_8.unit");
		auto h2 = Resources::GetUnitProducer("hw/doodads/theme_e/e_h_16.unit");
		auto v1 = Resources::GetUnitProducer("hw/doodads/theme_e/e_v_8.unit");
		auto dx = Resources::GetUnitProducer("hw/doodads/theme_e/e_x_x.unit");
		auto xu = Resources::GetUnitProducer("hw/doodads/theme_e/e_x_t_up.unit");
		auto xd = Resources::GetUnitProducer("hw/doodads/theme_e/e_x_t_dn.unit");
		auto xl = Resources::GetUnitProducer("hw/doodads/theme_e/e_x_t_l.unit");
		auto xr = Resources::GetUnitProducer("hw/doodads/theme_e/e_x_t_r.unit");
		auto cl = Resources::GetUnitProducer("hw/doodads/theme_e/e_h_cap_r.unit");
		auto cr = Resources::GetUnitProducer("hw/doodads/theme_e/e_h_cap_l.unit");
		auto cu = Resources::GetUnitProducer("hw/doodads/theme_e/e_v_cap_dn.unit");
		auto cd = Resources::GetUnitProducer("hw/doodads/theme_e/e_v_cap_up.unit");
		auto ld = Resources::GetUnitProducer("hw/doodads/theme_e/e_crn_l_dn.unit");
		auto lu = Resources::GetUnitProducer("hw/doodads/theme_e/e_crn_l_up.unit");
		auto rd = Resources::GetUnitProducer("hw/doodads/theme_e/e_crn_r_dn.unit");
		auto ru = Resources::GetUnitProducer("hw/doodads/theme_e/e_crn_r_up.unit");
		
		auto c16 = Resources::GetUnitProducer("hw/doodads/special/color_theme_e_16.unit");
		auto c32 = Resources::GetUnitProducer("hw/doodads/special/color_theme_e_32.unit");
		auto c48 = Resources::GetUnitProducer("hw/doodads/special/color_theme_e_48.unit");
		auto c64 = Resources::GetUnitProducer("hw/doodads/special/color_theme_e_64.unit");
		
		
		auto exit = Resources::GetUnitProducer("hw/doodads/theme_e/e_exit_h_up.unit");
		auto entry = Resources::GetUnitProducer("hw/doodads/theme_e/e_exit_h_dn.unit");
		auto exit_marker = Resources::GetUnitProducer("hw/doodads/generic/marker_exit.unit");

		
		auto arch = Resources::GetUnitProducer("hw/doodads/theme_e/e_special_arch_h_32.unit");
		
		
		auto slime1 = Resources::GetUnitProducer("hw/doodads/generic/deco_maggot_slime.unit");
		auto slime2 = Resources::GetUnitProducer("hw/doodads/generic/deco_maggot_slime_v2.unit");
		auto slime3 = Resources::GetUnitProducer("hw/doodads/generic/deco_maggot_slime_v3.unit");
		
		auto reserved = Resources::GetUnitProducer("hw/doodads/special/color_theme_b_16_dither.unit");
		
		SpawnPointsOfInterest(scene);
		
		
		auto t_default = Resources::GetTileset("hw/tilemaps/e_default.tileset");
		auto t_fine = Resources::GetTileset("hw/tilemaps/e_fine.tileset");
		auto t_moss = Resources::GetTileset("hw/tilemaps/e_moss.tileset");
		auto t_moss_grass = Resources::GetTileset("hw/tilemaps/grass.tileset");
		auto t_default_grass = Resources::GetTileset("hw/tilemaps/grass_brown.tileset");
		auto t_water = Resources::GetTileset("hw/tilemaps/water.tileset");
		
		
		scene.PaintTileset(t_default, m_posOffset + vec2(m_width * 8, m_height * 8), uint(max(m_width * 16, m_height * 16) * 1.5));
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				vec2 pos(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8);
			
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
						scene.PaintTileset(t_fine, pos, 16 + randi(32));
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
					
					if (randi(100) < (10 + wl * 15))
						scene.PaintTileset(t_default_grass, pos, 24);
				}
				else if(cell == Cell::Cliff)
				{
					scene.PaintTileset(t_water, pos, 20);
				}
			}
		}
		


		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				if (m_gridConsumed[x][y])
					continue;
			
				auto cell = m_grid[x][y];
				
				if (cell == Cell::Bridge)
				{
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					reserved.Produce(scene, pos);
				
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::Reserved)
				{
					/*
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					reserved.Produce(scene, pos);
					*/
				
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::Floor)
				{
					if (randi(100) < 50 && GetCell(x - 1, y) == Cell::Wall && GetCell(x + 2, y) == Cell::Wall &&
						IsFloorOrBreakables(x + 1, y) && IsFloorOrBreakables(x, y + 1) && IsFloorOrBreakables(x + 1, y + 1))
						m_spawnedDeco.insertLast(arch.Produce(scene, vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y - 28, 0)));
				
					m_gridConsumed[x][y] = true;
				}
				else if (cell == Cell::MaggotEnemies)
				{
					if (randi(100) < 75 && 
						GetCell(x + 1, y) == Cell::MaggotEnemies && GetCell(x, y + 1) == Cell::MaggotEnemies && GetCell(x + 1, y + 1) == Cell::MaggotEnemies)
					{
						vec3 midPos = vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y + 16, 0);
						if (randi(2) == 0)
							slime1.Produce(scene, midPos + MakeSpread(18, 18));
						else
							slime2.Produce(scene, midPos + MakeSpread(18, 18));
						
						/*
						m_gridConsumed[x + 1][y] = true;
						m_gridConsumed[x][y + 1] = true;
						m_gridConsumed[x + 1][y + 1] = true;
						*/
					}
					else
					{
						vec3 midPos = vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8, 0);
						slime3.Produce(scene, midPos + MakeSpread(14, 14));
					}
					
					m_gridConsumed[x][y] = true;
				}
				else if(cell == Cell::Breakables)
				{
					if (CanUseBreakables(x + 1, y) && CanUseBreakables(x, y + 1) && CanUseBreakables(x + 1, y + 1))
					{
						vec3 midPos = vec3(16 * (x + 1) + m_posOffset.x, 16 * (y + 1) + m_posOffset.y, 0);
					
						switch (randi(3) + 3)
						{
						/*
						case 0:
							SpawnBreakablePlant(scene, midPos + MakeSpread(10, 10));
							break;
						case 1:
							SpawnBreakablePlant(scene, midPos + vec3(-8, -8, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(8, 8, 0) + MakeSpread(2, 2));
							break;
						case 2:
							SpawnBreakablePlant(scene, midPos + vec3(-8, 8, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(8, -8, 0) + MakeSpread(2, 2));
							break;
						*/
						case 3:
							SpawnBreakablePlant(scene, midPos + vec3(8, 0, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(-5, -8, 0) + MakeSpread(1, 2));
							SpawnBreakablePlant(scene, midPos + vec3(-6, 8, 0) + MakeSpread(2, 2));
							break;
						case 4:
							SpawnBreakablePlant(scene, midPos + vec3(-8, 0, 0) + MakeSpread(2, 2));
							SpawnBreakablePlant(scene, midPos + vec3(4, -8, 0) + MakeSpread(1, 2));
							SpawnBreakablePlant(scene, midPos + vec3(8, 8, 0) + MakeSpread(2, 2));
							break;
						case 5:
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
				else if(cell == Cell::Nothing)
				{
					vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
				
					if (IsNothing(x + 1, y) && IsNothing(x, y + 1) && IsNothing(x + 1, y + 1))
					{
						if (IsNothing(x + 2, y) && IsNothing(x + 2, y + 1) && IsNothing(x + 2, y + 2) && IsNothing(x + 1, y + 2) && IsNothing(x, y + 2))
						{
							c64.Produce(scene, pos - vec3(8, 8 + 32, 0));
							
							m_gridConsumed[x + 2][y] = true;
							m_gridConsumed[x + 2][y + 1] = true;
							m_gridConsumed[x + 2][y + 2] = true;
							m_gridConsumed[x + 1][y + 2] = true;
							m_gridConsumed[x][y + 2] = true;
						}
						else 
							c48.Produce(scene, pos - vec3(8, 8 + 32, 0));
						
						m_gridConsumed[x + 1][y] = true;
						m_gridConsumed[x][y + 1] = true;
						m_gridConsumed[x + 1][y + 1] = true;
					}
					else
						c32.Produce(scene, pos - vec3(8, 8 + 32, 0));
					
					m_gridConsumed[x][y] = true;
				}
				else if(cell == Cell::Wall)
				{
					vec3 nPos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
					
					if (IsWall(x + 1, y) && IsWall(x, y + 1) && IsWall(x + 1, y + 1))
						c16.Produce(scene, nPos + vec3(8, -24, 0));
					
					if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
						dx.Produce(scene, nPos);

					else if (IsWall(x + 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
						xl.Produce(scene, nPos);
					else if (IsWall(x - 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
						xr.Produce(scene, nPos);
					else if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y + 1))
						xu.Produce(scene, nPos);
					else if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y - 1))
					{
						xd.Produce(scene, nPos);
						SpawnHorizontalWallDeco(scene, nPos, x, y);
					}
					
					else if (IsWall(x - 1, y) && IsWall(x, y - 1))
					{
						rd.Produce(scene, nPos);
						SpawnCornerSEWallDeco(scene, nPos, x, y);
					}
					else if (IsWall(x - 1, y) && IsWall(x, y + 1))
					{
						ru.Produce(scene, nPos);
						SpawnCornerNEWallDeco(scene, nPos, x, y);
					}
					else if (IsWall(x + 1, y) && IsWall(x, y - 1))
					{
						ld.Produce(scene, nPos);
						SpawnCornerSWWallDeco(scene, nPos, x, y);
					}
					else if (IsWall(x + 1, y) && IsWall(x, y + 1))
					{
						lu.Produce(scene, nPos);
						SpawnCornerNWWallDeco(scene, nPos, x, y);
					}

					else if (IsWall(x - 1, y) && IsWall(x + 1, y))
					{
						if (IsWall(x + 2, y) &&
							!IsWall(x + 1, y - 1) &&
							!IsWall(x + 1, y + 1) && !IsConsumed(x + 1, y))
						{
							h2.Produce(scene, nPos);
							m_gridConsumed[x + 1][y] = true;
						}
						else
							h1.Produce(scene, nPos);

						SpawnHorizontalWallDeco(scene, nPos, x, y);
					}
					else if (IsWall(x, y - 1) && IsWall(x, y + 1))
						v1.Produce(scene, nPos);

					else if (IsWall(x - 1, y))
						cl.Produce(scene, nPos);
					else if (IsWall(x + 1, y))
						cr.Produce(scene, nPos);
					else if (IsWall(x, y - 1))
						cu.Produce(scene, nPos);
					else if (IsWall(x, y + 1))
						cd.Produce(scene, nPos);

					else
					{
						no.Produce(scene, nPos);
						SpawnTorchDeco(scene, nPos + vec3(8, 0, 0), x, y);
					}
						
					m_gridConsumed[x][y] = true;
				}
			}
		}
		
		//PlacePaddingColor(scene, bt);
		
		
		RemoveNearbySame(m_spawnedDeco, 50);
		RemoveNearby(m_spawnedTorches, 125);
		
		m_spawnedDeco = array<UnitPtr>();
		m_spawnedTorches = array<UnitPtr>();
	}
}
