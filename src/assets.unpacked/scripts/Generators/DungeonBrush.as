enum Cell
{
	Floor			=  1,
	Wall			=  2,
	ReservedWall	=  3,
	Cliff			=  4,
	Bridge			=  5,
	Breakables		=  6,
	Nothing			=  7,
	Reserved		=  8,
	Outside			=  9,
	Enemies			= 10,
	MaggotEnemies	= 11
}

enum PointOfInterestType
{
	None,

	Entry,
	Exit,
	
	PrefabActShortcut,
	PrefabSpecialOre,
	
	PrefabMazePathH,
	PrefabMazePathV,
	PrefabMazePathN,
	PrefabMazePathS,
	PrefabMazePathW,
	PrefabMazePathE,
	
	Prefab22x22North2,
	Prefab22x22South2,
	Prefab21x21East,
	Prefab21x21West,
	Prefab13x13North,
	Prefab9x9North,
	Prefab5x5North,
	Prefab3x3North,
	Prefab14x14North2,
	Prefab10x10North2,
	Prefab6x6North2,
	
	Prefab9x9South,
	Prefab5x5South,
	Prefab14x14South2,
	Prefab10x10South2,
	Prefab6x6South2,
	
	Prefab13x13East,
	Prefab9x9East,
	Prefab5x5East,
	
	Prefab13x13West,
	Prefab9x9West,
	Prefab5x5West,

	Prefab35x35Block,
	Prefab21x21Block,
	Prefab13x13Block,
	Prefab9x9Block,
	Prefab7x7Block,
	Prefab5x5Block,
	Prefab3x3Block,
	Prefab2x2Block,
	
	Prefab5x5BlockNorth,
	Prefab5x5BlockSouth,
	Prefab5x6BlockEast,
	Prefab5x6BlockWest,
	Prefab12x5BlockNorth,
	Prefab12x5BlockSouth,
	Prefab5x12BlockEast,
	Prefab5x12BlockWest,
	
	Prefab12x7BlockNorthInverted,
	Prefab12x7BlockSouthInverted,
	Prefab7x12BlockEastInverted,
	Prefab7x12BlockWestInverted,
	
	Prefab2x3Junction,
	Prefab2x6Path,
	Prefab6x3Path,
	Prefab4x6Path,
	Prefab6x4Path,
	Prefab5x12Path,
	Prefab6x12Path,
	Prefab7x12Path,
	Prefab6x8Path,
	Prefab8x4Path,
	Prefab12x6Path,
	Prefab12x8Path,
	
	Prefab3x3Cliff,
	Prefab9x9Cliff,
	Prefab13x13Cliff,
	Prefab9x3Cliff,
	Prefab3x9Cliff
}

class PointOfInterest
{
	PointOfInterestType m_type;
	ivec2 m_pos;
}


class BaseBrushTiles
{
	UnitProducer@ wt;

	UnitProducer@ no;
	UnitProducer@ h1;
	UnitProducer@ h2;
	UnitProducer@ v1;
	UnitProducer@ v2;
	UnitProducer@ dx;
	UnitProducer@ xu;
	UnitProducer@ xd;
	UnitProducer@ xl;
	UnitProducer@ xr;
	UnitProducer@ cl;
	UnitProducer@ cr;
	UnitProducer@ cu;
	UnitProducer@ cd;
	UnitProducer@ ld;
	UnitProducer@ lu;
	UnitProducer@ rd;
	UnitProducer@ ru;

	UnitProducer@ c16;
	UnitProducer@ c32;
	UnitProducer@ c48;
	UnitProducer@ c64;
	UnitProducer@ c256;

	UnitProducer@ l16;
	UnitProducer@ l32;

	UnitProducer@ ln;
	UnitProducer@ ls;
	UnitProducer@ lw;
	UnitProducer@ le;
	UnitProducer@ lnw;
	UnitProducer@ lne;
	UnitProducer@ lsw;
	UnitProducer@ lse;
	UnitProducer@ lnwo;
	UnitProducer@ lneo;
	UnitProducer@ lswo;
	UnitProducer@ lseo;
}

class DungeonBrush
{
	array<array<Cell>>@ m_grid;
	array<array<bool>>@ m_gridConsumed;
	array<PointOfInterest>@ m_pointsOfInterest;
	
	Prefab@ m_pfb_exit;
	Prefab@ m_pfb_entr;
	Prefab@ m_pfb_shortcut;
	Prefab@ m_pfb_spc_ore;
	
	Prefab@ m_pfb_mzpth_h;
	Prefab@ m_pfb_mzpth_v;
	Prefab@ m_pfb_mzpth_n;
	Prefab@ m_pfb_mzpth_s;
	Prefab@ m_pfb_mzpth_w;
	Prefab@ m_pfb_mzpth_e;

	Prefab@ m_pfb_22x22_n2;
	Prefab@ m_pfb_22x22_s2;
	Prefab@ m_pfb_21x21_e;
	Prefab@ m_pfb_21x21_w;
	Prefab@ m_pfb_13x13_n;
	Prefab@ m_pfb_9x9_n;
	Prefab@ m_pfb_5x5_n;
	Prefab@ m_pfb_3x3_n;
	Prefab@ m_pfb_14x14_n2;
	Prefab@ m_pfb_10x10_n2;
	Prefab@ m_pfb_6x6_n2;
	Prefab@ m_pfb_9x9_s;
	Prefab@ m_pfb_5x5_s;
	Prefab@ m_pfb_14x14_s2;
	Prefab@ m_pfb_10x10_s2;
	Prefab@ m_pfb_6x6_s2;
	Prefab@ m_pfb_13x13_e;
	Prefab@ m_pfb_9x9_e;
	Prefab@ m_pfb_5x5_e;
	Prefab@ m_pfb_13x13_w;
	Prefab@ m_pfb_9x9_w;
	Prefab@ m_pfb_5x5_w;
	Prefab@ m_pfb_35x35;
	Prefab@ m_pfb_21x21;
	Prefab@ m_pfb_13x13;
	Prefab@ m_pfb_9x9;
	Prefab@ m_pfb_7x7;
	Prefab@ m_pfb_5x5;
	Prefab@ m_pfb_3x3;
	Prefab@ m_pfb_2x2;
	Prefab@ m_pfb_5x5_bn;
	Prefab@ m_pfb_5x5_bs;	
	Prefab@ m_pfb_5x6_be;
	Prefab@ m_pfb_5x6_bw;
	Prefab@ m_pfb_12x5_bn;
	Prefab@ m_pfb_12x5_bs;
	Prefab@ m_pfb_5x12_be;
	Prefab@ m_pfb_5x12_bw;
	Prefab@ m_pfb_12x7_bin;
	Prefab@ m_pfb_12x7_bis;
	Prefab@ m_pfb_7x12_bie;
	Prefab@ m_pfb_7x12_biw;
	Prefab@ m_pfb_2x3_jnc;
	Prefab@ m_pfb_2x6_pth;
	Prefab@ m_pfb_6x3_pth;
	Prefab@ m_pfb_4x6_pth;
	Prefab@ m_pfb_6x4_pth;
	Prefab@ m_pfb_5x12_pth;
	Prefab@ m_pfb_6x12_pth;
	Prefab@ m_pfb_7x12_pth;
	Prefab@ m_pfb_6x8_pth;
	Prefab@ m_pfb_8x4_pth;
	Prefab@ m_pfb_12x6_pth;
	Prefab@ m_pfb_12x8_pth;
	Prefab@ m_pfb_3x3_clf;
	Prefab@ m_pfb_9x9_clf;
	Prefab@ m_pfb_13x13_clf;
	Prefab@ m_pfb_9x3_clf;
	Prefab@ m_pfb_3x9_clf;
	
	UnitProducer@ m_slime1;
	UnitProducer@ m_slime2;
	UnitProducer@ m_slime3;
	
	int m_width;
	int m_height;
	
	vec2 m_posOffset;
	ivec3 m_lvl;

	
	void Initialize(int width, int height, vec2 posOffset)
	{
		@m_grid = array<array<Cell>>(width, array<Cell>(height, Cell::Wall));
		@m_gridConsumed = array<array<bool>>(width, array<bool>(height, false));
		@m_pointsOfInterest = array<PointOfInterest>();
		
		m_width = width;
		m_height = height;
		m_posOffset = posOffset;
		
		
		m_posOffset.x = int(m_posOffset.x / 16.0) * 16.0;
		m_posOffset.y = int(m_posOffset.y / 16.0) * 16.0;
		
		/*
		m_posOffset.x = 0;
		m_posOffset.y = 0;
		*/
	}
	
	void LoadPrefabs(string theme)
	{
		@m_pfb_exit    = Resources::GetPrefab("prefabs/" + theme + "/exit.pfb");
		@m_pfb_entr    = Resources::GetPrefab("prefabs/" + theme + "/entrance.pfb");
		@m_pfb_shortcut= Resources::GetPrefab("prefabs/" + theme + "/shortcut.pfb");
		@m_pfb_spc_ore = Resources::GetPrefab("prefabs/" + theme + "/special_ore.pfb");
		
		@m_pfb_mzpth_h = Resources::GetPrefab("prefabs/" + theme + "/maze_path_h.pfb");
		@m_pfb_mzpth_v = Resources::GetPrefab("prefabs/" + theme + "/maze_path_v.pfb");
		@m_pfb_mzpth_n = Resources::GetPrefab("prefabs/" + theme + "/maze_path_n.pfb");
		@m_pfb_mzpth_s = Resources::GetPrefab("prefabs/" + theme + "/maze_path_s.pfb");
		@m_pfb_mzpth_w = Resources::GetPrefab("prefabs/" + theme + "/maze_path_w.pfb");
		@m_pfb_mzpth_e = Resources::GetPrefab("prefabs/" + theme + "/maze_path_e.pfb");
		
		@m_pfb_22x22_n2= Resources::GetPrefab("prefabs/" + theme + "/north2_22x22.pfb");
		@m_pfb_22x22_s2= Resources::GetPrefab("prefabs/" + theme + "/south2_22x22.pfb");
		@m_pfb_21x21_e = Resources::GetPrefab("prefabs/" + theme + "/east_21x21.pfb");
		@m_pfb_21x21_w = Resources::GetPrefab("prefabs/" + theme + "/west_21x21.pfb");
		@m_pfb_13x13_n = Resources::GetPrefab("prefabs/" + theme + "/north_13x13.pfb");
		@m_pfb_9x9_n   = Resources::GetPrefab("prefabs/" + theme + "/north_9x9.pfb");
		@m_pfb_5x5_n   = Resources::GetPrefab("prefabs/" + theme + "/north_5x5.pfb");
		@m_pfb_3x3_n   = Resources::GetPrefab("prefabs/" + theme + "/north_3x3.pfb");
		@m_pfb_14x14_n2= Resources::GetPrefab("prefabs/" + theme + "/north2_14x14.pfb");
		@m_pfb_10x10_n2= Resources::GetPrefab("prefabs/" + theme + "/north2_10x10.pfb");
		@m_pfb_6x6_n2  = Resources::GetPrefab("prefabs/" + theme + "/north2_6x6.pfb");
		@m_pfb_9x9_s   = Resources::GetPrefab("prefabs/" + theme + "/south_9x9.pfb");
		@m_pfb_5x5_s   = Resources::GetPrefab("prefabs/" + theme + "/south_5x5.pfb");
		@m_pfb_14x14_s2= Resources::GetPrefab("prefabs/" + theme + "/south2_14x14.pfb");
		@m_pfb_10x10_s2= Resources::GetPrefab("prefabs/" + theme + "/south2_10x10.pfb");
		@m_pfb_6x6_s2  = Resources::GetPrefab("prefabs/" + theme + "/south2_6x6.pfb");
		@m_pfb_13x13_e = Resources::GetPrefab("prefabs/" + theme + "/east_13x13.pfb");
		@m_pfb_9x9_e   = Resources::GetPrefab("prefabs/" + theme + "/east_9x9.pfb");
		@m_pfb_5x5_e   = Resources::GetPrefab("prefabs/" + theme + "/east_5x5.pfb");
		@m_pfb_13x13_w = Resources::GetPrefab("prefabs/" + theme + "/west_13x13.pfb");
		@m_pfb_9x9_w   = Resources::GetPrefab("prefabs/" + theme + "/west_9x9.pfb");
		@m_pfb_5x5_w   = Resources::GetPrefab("prefabs/" + theme + "/west_5x5.pfb");
		@m_pfb_35x35   = Resources::GetPrefab("prefabs/" + theme + "/35x35.pfb");
		@m_pfb_21x21   = Resources::GetPrefab("prefabs/" + theme + "/21x21.pfb");
		@m_pfb_13x13   = Resources::GetPrefab("prefabs/" + theme + "/13x13.pfb");
		@m_pfb_9x9     = Resources::GetPrefab("prefabs/" + theme + "/9x9.pfb");
		@m_pfb_7x7     = Resources::GetPrefab("prefabs/" + theme + "/7x7.pfb");
		@m_pfb_5x5     = Resources::GetPrefab("prefabs/" + theme + "/5x5.pfb");
		@m_pfb_3x3     = Resources::GetPrefab("prefabs/" + theme + "/3x3.pfb");
		@m_pfb_2x2     = Resources::GetPrefab("prefabs/" + theme + "/2x2.pfb");
		@m_pfb_5x5_bn  = Resources::GetPrefab("prefabs/" + theme + "/north_5x5wall.pfb");
		@m_pfb_5x5_bs  = Resources::GetPrefab("prefabs/" + theme + "/south_5x5wall.pfb");
		@m_pfb_5x6_be  = Resources::GetPrefab("prefabs/" + theme + "/east_5x6wall.pfb");
		@m_pfb_5x6_bw  = Resources::GetPrefab("prefabs/" + theme + "/west_5x6wall.pfb");
		@m_pfb_12x5_bn = Resources::GetPrefab("prefabs/" + theme + "/north_12x5wall.pfb");
		@m_pfb_12x5_bs = Resources::GetPrefab("prefabs/" + theme + "/south_12x5wall.pfb");
		@m_pfb_5x12_be = Resources::GetPrefab("prefabs/" + theme + "/east_5x12wall.pfb");
		@m_pfb_5x12_bw = Resources::GetPrefab("prefabs/" + theme + "/west_5x12wall.pfb");
		@m_pfb_12x7_bin= Resources::GetPrefab("prefabs/" + theme + "/north_12x7wall_inverted.pfb");
		@m_pfb_12x7_bis= Resources::GetPrefab("prefabs/" + theme + "/south_12x7wall_inverted.pfb");
		@m_pfb_7x12_bie= Resources::GetPrefab("prefabs/" + theme + "/east_7x12wall_inverted.pfb");
		@m_pfb_7x12_biw= Resources::GetPrefab("prefabs/" + theme + "/west_7x12wall_inverted.pfb");
		@m_pfb_2x3_jnc = Resources::GetPrefab("prefabs/" + theme + "/junction_2x3.pfb");
		@m_pfb_2x6_pth = Resources::GetPrefab("prefabs/" + theme + "/path_2x6.pfb");
		@m_pfb_6x3_pth = Resources::GetPrefab("prefabs/" + theme + "/path_6x3.pfb");
		@m_pfb_4x6_pth = Resources::GetPrefab("prefabs/" + theme + "/path_4x6.pfb");
		@m_pfb_6x4_pth = Resources::GetPrefab("prefabs/" + theme + "/path_6x4.pfb");
		@m_pfb_5x12_pth= Resources::GetPrefab("prefabs/" + theme + "/path_5x12.pfb");
		@m_pfb_6x12_pth= Resources::GetPrefab("prefabs/" + theme + "/path_6x12.pfb");
		@m_pfb_7x12_pth= Resources::GetPrefab("prefabs/" + theme + "/path_7x12.pfb");
		@m_pfb_6x8_pth = Resources::GetPrefab("prefabs/" + theme + "/path_6x8.pfb");
		@m_pfb_8x4_pth = Resources::GetPrefab("prefabs/" + theme + "/path_8x4.pfb");
		@m_pfb_12x6_pth= Resources::GetPrefab("prefabs/" + theme + "/path_12x6.pfb");
		@m_pfb_12x8_pth= Resources::GetPrefab("prefabs/" + theme + "/path_12x8.pfb");
		@m_pfb_3x3_clf = Resources::GetPrefab("prefabs/" + theme + "/cliff_3x3.pfb");
		@m_pfb_9x9_clf = Resources::GetPrefab("prefabs/" + theme + "/cliff_9x9.pfb");
		@m_pfb_13x13_clf=Resources::GetPrefab("prefabs/" + theme + "/cliff_13x13.pfb");
		@m_pfb_9x3_clf = Resources::GetPrefab("prefabs/" + theme + "/cliff_9x3.pfb");
		@m_pfb_3x9_clf = Resources::GetPrefab("prefabs/" + theme + "/cliff_3x9.pfb");
	}

	BaseBrushTiles@ LoadBaseBrushTiles(string theme, bool snakePits = false)
	{
		// What a nice hack :\
		for (int y = 0; y < m_height; y++)
			for (int x = 0; x < m_width; x++)
				if(m_grid[x][y] == Cell::ReservedWall)
					m_grid[x][y] = Cell::Wall;
	
	
		@m_slime1 = Resources::GetUnitProducer("doodads/generic/deco_maggot_slime.unit");
		@m_slime2 = Resources::GetUnitProducer("doodads/generic/deco_maggot_slime_v2.unit");
		@m_slime3 = Resources::GetUnitProducer("doodads/generic/deco_maggot_slime_v3.unit");
	
	
		BaseBrushTiles tiles;

		@tiles.no = Resources::GetUnitProducer("doodads/walls/" + theme + "/single.unit");
		@tiles.h1 = Resources::GetUnitProducer("doodads/walls/" + theme + "/h_16.unit");
		@tiles.h2 = Resources::GetUnitProducer("doodads/walls/" + theme + "/h.unit");
		@tiles.v1 = Resources::GetUnitProducer("doodads/walls/" + theme + "/v_16.unit");
		@tiles.v2 = Resources::GetUnitProducer("doodads/walls/" + theme + "/v.unit");
		@tiles.dx = Resources::GetUnitProducer("doodads/walls/" + theme + "/x_x.unit");
		@tiles.xu = Resources::GetUnitProducer("doodads/walls/" + theme + "/x_n.unit");
		@tiles.xd = Resources::GetUnitProducer("doodads/walls/" + theme + "/x_s.unit");
		@tiles.xl = Resources::GetUnitProducer("doodads/walls/" + theme + "/x_w.unit");
		@tiles.xr = Resources::GetUnitProducer("doodads/walls/" + theme + "/x_e.unit");
		@tiles.cl = Resources::GetUnitProducer("doodads/walls/" + theme + "/cap_e.unit");
		@tiles.cr = Resources::GetUnitProducer("doodads/walls/" + theme + "/cap_w.unit");
		@tiles.cu = Resources::GetUnitProducer("doodads/walls/" + theme + "/cap_s.unit");
		@tiles.cd = Resources::GetUnitProducer("doodads/walls/" + theme + "/cap_n.unit");
		@tiles.ld = Resources::GetUnitProducer("doodads/walls/" + theme + "/crn_sw.unit");
		@tiles.lu = Resources::GetUnitProducer("doodads/walls/" + theme + "/crn_nw.unit");
		@tiles.rd = Resources::GetUnitProducer("doodads/walls/" + theme + "/crn_se.unit");
		@tiles.ru = Resources::GetUnitProducer("doodads/walls/" + theme + "/crn_ne.unit");
		
		@tiles.c16 = Resources::GetUnitProducer("doodads/special/color_" + theme + "_16.unit");
		@tiles.c32 = Resources::GetUnitProducer("doodads/special/color_" + theme + "_32.unit");
		@tiles.c48 = Resources::GetUnitProducer("doodads/special/color_" + theme + "_48.unit");
		@tiles.c64 = Resources::GetUnitProducer("doodads/special/color_" + theme + "_64.unit");
		@tiles.c256 = Resources::GetUnitProducer("doodads/special/color_" + theme + "_256.unit");
		
		if (!snakePits)
		{
			@tiles.l16 = Resources::GetUnitProducer("doodads/walls/_ledge_black_16.unit");
			@tiles.l32 = Resources::GetUnitProducer("doodads/walls/_ledge_black.unit");
		}
		else
		{
			@tiles.l16 = Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_snakes_16.unit");
			@tiles.l32 = Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_snakes.unit");
		}
		
		@tiles.ln	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_n_16.unit");
		@tiles.ls	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_s_16.unit");
		@tiles.lw	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_w_16.unit");
		@tiles.le	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_e_16.unit");
		@tiles.lnw	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_nw.unit");
		@tiles.lne	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_ne.unit");
		@tiles.lsw	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_sw.unit");
		@tiles.lse	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_se.unit");
		@tiles.lnwo	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_nw_o.unit");
		@tiles.lneo	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_ne_o.unit");
		@tiles.lswo	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_sw_o.unit");
		@tiles.lseo	= Resources::GetUnitProducer("doodads/walls/" + theme + "/_ledge_crn_se_o.unit");
		
		
		return tiles;
	}
	
	void PlacePaddingColor(Scene@ scene, BaseBrushTiles@  bt)
	{
		int tilesz = 256;
	
		int w = int(ceil(m_width / (tilesz / 16.0f)));
		int h = int(ceil(m_height / (tilesz / 16.0f)));
	
		
		for (int x = -1; x < (w + 1); x++)
		{
			bt.c256.Produce(scene, vec3(tilesz * x + m_posOffset.x, m_posOffset.y - 16, 0));
			bt.c256.Produce(scene, vec3(tilesz * x + m_posOffset.x, m_height * 16 + m_posOffset.y + tilesz - 32, 0));
		}
		
		for (int y = 0; y < h; y++)
		{
			bt.c256.Produce(scene, vec3(m_posOffset.x - tilesz, tilesz * y + m_posOffset.y + tilesz - 16, 0));
			bt.c256.Produce(scene, vec3(m_posOffset.x + m_width * 16, tilesz * y + m_posOffset.y + tilesz - 16, 0));
		}
	}
	
	void FillCellNothing(Scene@ scene, BaseBrushTiles@  bt, int x, int y)
	{
		vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
	
		if (IsNothing(x + 1, y) && IsNothing(x, y + 1) && IsNothing(x + 1, y + 1))
		{
			if (IsNothing(x + 2, y) && IsNothing(x + 2, y + 1) && IsNothing(x + 2, y + 2) && IsNothing(x + 1, y + 2) && IsNothing(x, y + 2))
			{
				bt.c64.Produce(scene, pos - vec3(8, 8 - 32, 0));
				
				m_gridConsumed[x + 2][y] = true;
				m_gridConsumed[x + 2][y + 1] = true;
				m_gridConsumed[x + 2][y + 2] = true;
				m_gridConsumed[x + 1][y + 2] = true;
				m_gridConsumed[x][y + 2] = true;
			}
			else 
				bt.c48.Produce(scene, pos - vec3(8, 8 - 16, 0));
			
			m_gridConsumed[x + 1][y] = true;
			m_gridConsumed[x][y + 1] = true;
			m_gridConsumed[x + 1][y + 1] = true;
		}
		else
			bt.c32.Produce(scene, pos - vec3(8, 8, 0));
		
		m_gridConsumed[x][y] = true;
	}
	
	bool SpawnTorchDeco(Scene@ scene, vec3 pos, int x, int y) { return false; }
	void SpawnHorizontalWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnHorizontalWall2Deco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnVerticalWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnVerticalWall2Deco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnCornerSEWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnCornerNEWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnCornerSWWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	void SpawnCornerNWWallDeco(Scene@ scene, vec3 pos, int x, int y) {}
	
	void FillCellWall(Scene@ scene, BaseBrushTiles@  bt, int x, int y)
	{
		vec3 nPos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);

		if (IsWall(x + 1, y) && IsWall(x, y + 1) && IsWall(x + 1, y + 1))
			bt.c16.Produce(scene, nPos + vec3(8, -8, 0));
		
		if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
		{
			bt.dx.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, false, false, false, false);
		}
			
		else if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y - 1) && !IsWall(x, y + 1) &&
			IsWall(x + 2, y) && IsWall(x + 1, y - 1) && !IsWall(x + 1, y + 1) && IsWall(x - 1, y - 1) && IsWall(x + 2, y - 1))
		{
			bt.h2.Produce(scene, nPos);
			m_gridConsumed[x + 1][y] = true;
			SpawnHorizontalWall2Deco(scene, nPos, x, y);
			
			DoWallTrim(scene, bt.wt, x, y, false, false, true, false);
			DoWallTrim(scene, bt.wt, x+1, y, false, false, true, false);
		}

		else if (IsWall(x + 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
		{
			bt.xl.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, false, false, false, true);
		}
		else if (IsWall(x - 1, y) && IsWall(x, y - 1) && IsWall(x, y + 1))
		{
			bt.xr.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, false, true, false, false);
		}
		else if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y + 1))
		{
			bt.xu.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, true, false, false, false);
		}
		else if (IsWall(x - 1, y) && IsWall(x + 1, y) && IsWall(x, y - 1))
		{
			bt.xd.Produce(scene, nPos);
			SpawnHorizontalWallDeco(scene, nPos, x, y);
			DoWallTrim(scene, bt.wt, x, y, false, false, true, false);
		}
		
		else if (IsWall(x - 1, y) && IsWall(x, y - 1))
		{
			bt.rd.Produce(scene, nPos);
			SpawnCornerSEWallDeco(scene, nPos, x, y);
			DoWallTrim(scene, bt.wt, x, y, false, true, true, false);
		}
		else if (IsWall(x - 1, y) && IsWall(x, y + 1))
		{
			bt.ru.Produce(scene, nPos);
			SpawnCornerNEWallDeco(scene, nPos, x, y);
			DoWallTrim(scene, bt.wt, x, y, true, true, false, false);
		}
		else if (IsWall(x + 1, y) && IsWall(x, y - 1))
		{
			bt.ld.Produce(scene, nPos);
			SpawnCornerSWWallDeco(scene, nPos, x, y);
			DoWallTrim(scene, bt.wt, x, y, false, false, true, true);
		}
		else if (IsWall(x + 1, y) && IsWall(x, y + 1))
		{
			bt.lu.Produce(scene, nPos);
			SpawnCornerNWWallDeco(scene, nPos, x, y);
			DoWallTrim(scene, bt.wt, x, y, true, false, false, true);
		}

		else if (IsWall(x - 1, y) && IsWall(x + 1, y))
		{
			if (IsWall(x + 2, y) &&
				!IsWall(x + 1, y - 1) &&
				!IsWall(x + 1, y + 1) && !IsConsumed(x + 1, y))
			{
				bt.h2.Produce(scene, nPos);
				m_gridConsumed[x + 1][y] = true;
				SpawnHorizontalWall2Deco(scene, nPos, x, y);
				DoWallTrim(scene, bt.wt, x, y, true, false, true, false);
				DoWallTrim(scene, bt.wt, x+1, y, true, false, true, false);
			}
			else
			{
				bt.h1.Produce(scene, nPos);
				SpawnHorizontalWallDeco(scene, nPos, x, y);
				DoWallTrim(scene, bt.wt, x, y, true, false, true, false);
			}
		}
		else if (IsWall(x, y - 1) && IsWall(x, y + 1))
		{
			if (IsWall(x, y + 2) &&
				!IsWall(x - 1, y + 1) &&
				!IsWall(x + 1, y + 1) && !IsConsumed(x, y + 1))
			{
				bt.v2.Produce(scene, nPos + vec3(0, -16, 0));
				m_gridConsumed[x][y + 1] = true;
				SpawnVerticalWall2Deco(scene, nPos, x, y);
				DoWallTrim(scene, bt.wt, x, y, false, true, false, true);
				DoWallTrim(scene, bt.wt, x, y+1, false, true, false, true);
			}
			else
			{
				bt.v1.Produce(scene, nPos + vec3(0, -16, 0));
				SpawnVerticalWallDeco(scene, nPos, x, y);
				DoWallTrim(scene, bt.wt, x, y, false, true, false, true);
			}
		}

		else if (IsWall(x - 1, y))
		{
			bt.cl.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, true, true, true, false);
		}
		else if (IsWall(x + 1, y))
		{
			bt.cr.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, true, false, true, true);
		}
		else if (IsWall(x, y - 1))
		{
			bt.cu.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, false, true, true, true);
		}
		else if (IsWall(x, y + 1))
		{
			bt.cd.Produce(scene, nPos);
			DoWallTrim(scene, bt.wt, x, y, true, true, false, true);
		}

		else
		{
			bt.no.Produce(scene, nPos);
			SpawnTorchDeco(scene, nPos + vec3(8, 0, 0), x, y);
			DoWallTrim(scene, bt.wt, x, y, true, true, true, true);
		}
			
		m_gridConsumed[x][y] = true;
	}
	
	void DoWallTrim(Scene@ scene, UnitProducer@ wt, int x, int y, bool n, bool e, bool s, bool w)
	{
		if (wt is null)
			return;
			
		vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);
			
		if (s)
		{
			wt.Produce(scene, pos + vec3(0, 16, 0));
			wt.Produce(scene, pos + vec3(8, 16, 0));
		}
		
		if (w)
		{
			wt.Produce(scene, pos + vec3(-8, 0, 0));
			wt.Produce(scene, pos + vec3(-8, 8, 0));
			
			if (s)
				wt.Produce(scene, pos + vec3(-8, 16, 0));
			if (n)
				wt.Produce(scene, pos + vec3(-8, -8, 0));
		}
		
		if (e)
		{
			wt.Produce(scene, pos + vec3(16, 0, 0));
			wt.Produce(scene, pos + vec3(16, 8, 0));
			
			if (s)
				wt.Produce(scene, pos + vec3(16, 16, 0));
			if (n)
				wt.Produce(scene, pos + vec3(16, -8, 0));
		}
	}
	
	void FillCellCliff(Scene@ scene, BaseBrushTiles@  bt, int x, int y)
	{
		vec3 pos = vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y, 0);

		if (!IsCliff(x, y - 1))
		{
			bt.ln.Produce(scene, pos - vec3(0, 8, 0));
		
			if (!IsCliff(x - 1, y))
			{
				bt.lnw.Produce(scene, pos + vec3(-8, -8, 0));
				bt.lw.Produce(scene, pos + vec3(-8, 0, 0));
			}
			
			if (!IsCliff(x + 1, y))
			{
				bt.lne.Produce(scene, pos + vec3(16, -8, 0));
				bt.le.Produce(scene, pos + vec3(16, 0, 0));
			}
		}
		else
		{
			bool w = false;
			bool e = false;
		
			if (!IsCliff(x - 1, y))
			{
				bt.lw.Produce(scene, pos - vec3(8, 0, 0));
				w = true;
			}

			if (!IsCliff(x + 1, y))
			{
				bt.le.Produce(scene, pos + vec3(16, 0, 0));
				e = true;
			}
				
			if (!IsCliff(x, y + 1))
			{
				bt.ls.Produce(scene, pos + vec3(0, 16, 0));
				
				if (w)
					bt.lsw.Produce(scene, pos + vec3(-8, 16, 0));
				if (e)
					bt.lse.Produce(scene, pos + vec3(16, 16, 0));
			}
			
			bt.l16.Produce(scene, pos + vec3(0, 16, 0));
		}
	
		m_gridConsumed[x][y] = true;
	}
	
	vec3 MakeSpread(int x, int y)
	{
		return vec3(randi(x) - x/2, randi(y) - y/2, 0);
	}
	
	void FillCellMaggotEnemies(Scene@ scene, BaseBrushTiles@  bt, int x, int y)
	{
		auto cell = GetCell(x - 1, y);
		if (cell == Cell::Cliff || cell == Cell::Reserved)
			return;
		cell = GetCell(x + 1, y);
		if (cell == Cell::Cliff || cell == Cell::Reserved)
			return;
	
		if (randi(100) < 75 && 
			GetCell(x + 1, y) == Cell::MaggotEnemies && GetCell(x, y + 1) == Cell::MaggotEnemies && GetCell(x + 1, y + 1) == Cell::MaggotEnemies)
		{
			vec3 midPos = vec3(16 * x + m_posOffset.x + 16, 16 * y + m_posOffset.y + 16, 0);
			if (randi(2) == 0)
				m_slime1.Produce(scene, midPos + MakeSpread(18, 18));
			else
				m_slime2.Produce(scene, midPos + MakeSpread(18, 18));
			
			/*
			m_gridConsumed[x + 1][y] = true;
			m_gridConsumed[x][y + 1] = true;
			m_gridConsumed[x + 1][y + 1] = true;
			*/
		}
		else
		{
			vec3 midPos = vec3(16 * x + m_posOffset.x + 8, 16 * y + m_posOffset.y + 8, 0);
			m_slime3.Produce(scene, midPos + MakeSpread(14, 14));
		}
		
		m_gridConsumed[x][y] = true;
	}
	
	void DoLighting(Scene@ scene, string theme, int minDist)
	{
		array<UnitPtr> spawnedLights;
	
		int lvl = clamp(m_lvl.y + 1, 1, 3);
		
		auto env = "effects/lighting/" + theme + "_" + lvl;
		//if (Fountain::HasEffect(FountainEffect::Darkness))
		//	env = "effects/lighting/darkness";
		
		scene.SetEnvironment(Resources::GetEnvironment(env + ".env"));
		auto light = Resources::GetUnitProducer(env + ".unit");
		if (light is null)
			return;
	
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				//if (m_gridConsumed[x][y])
				//	continue;
			
				auto cell = m_grid[x][y];
				
				if (randi(1000) < 985)
					continue;
					
				bool valid = false;
				for (int yd = -2; yd < 2; yd++)
				{
					for (int xd = -2; xd < 2; xd++)
					{
						auto cl = GetCell(x + xd, y + yd);
						if (cl == Cell::Floor || cl == Cell::Breakables || cl == Cell::Reserved)
						{
							valid = true;
							break;
						}
					}
					
					if (valid)
						break;
				}
				
				if (!valid)
					continue;
			
				spawnedLights.insertLast(light.Produce(scene, vec3(16 * x + m_posOffset.x, 16 * y + m_posOffset.y - 32, 0)));
			}
		}
		
		RemoveNearby(spawnedLights, minDist);
	}
	
	Prefab@ GetPrefab(PointOfInterestType poi)
	{
		switch(poi)
		{
		case PointOfInterestType::PrefabActShortcut:
			return m_pfb_shortcut;
		case PointOfInterestType::PrefabSpecialOre:
			return m_pfb_spc_ore;
			
		case PointOfInterestType::PrefabMazePathH:
			return m_pfb_mzpth_h;
		case PointOfInterestType::PrefabMazePathV:
			return m_pfb_mzpth_v;
		case PointOfInterestType::PrefabMazePathN:
			return m_pfb_mzpth_n;
		case PointOfInterestType::PrefabMazePathS:
			return m_pfb_mzpth_s;
		case PointOfInterestType::PrefabMazePathW:
			return m_pfb_mzpth_w;
		case PointOfInterestType::PrefabMazePathE:
			return m_pfb_mzpth_e;
			
		case PointOfInterestType::Prefab22x22North2:
			return m_pfb_22x22_n2;
		case PointOfInterestType::Prefab22x22South2:
			return m_pfb_22x22_s2;
		case PointOfInterestType::Prefab21x21East:
			return m_pfb_21x21_e;
		case PointOfInterestType::Prefab21x21West:
			return m_pfb_21x21_w;
			
		case PointOfInterestType::Prefab13x13North:
			return m_pfb_13x13_n;
		case PointOfInterestType::Prefab9x9North:
			return m_pfb_9x9_n;
		case PointOfInterestType::Prefab5x5North:
			return m_pfb_5x5_n;
		case PointOfInterestType::Prefab3x3North:
			return m_pfb_3x3_n;
		
		case PointOfInterestType::Prefab14x14North2:
			return m_pfb_14x14_n2;
		case PointOfInterestType::Prefab10x10North2:
			return m_pfb_10x10_n2;
		case PointOfInterestType::Prefab6x6North2:
			return m_pfb_6x6_n2;
		
		case PointOfInterestType::Prefab9x9South:
			return m_pfb_9x9_s;
		case PointOfInterestType::Prefab5x5South:
			return m_pfb_5x5_s;
		
		case PointOfInterestType::Prefab14x14South2:
			return m_pfb_14x14_s2;		
		case PointOfInterestType::Prefab10x10South2:
			return m_pfb_10x10_s2;
		case PointOfInterestType::Prefab6x6South2:
			return m_pfb_6x6_s2;
		
		case PointOfInterestType::Prefab13x13East:
			return m_pfb_13x13_e;		
		case PointOfInterestType::Prefab9x9East:
			return m_pfb_9x9_e;
		case PointOfInterestType::Prefab5x5East:
			return m_pfb_5x5_e;
		
		case PointOfInterestType::Prefab13x13West:
			return m_pfb_13x13_w;
		case PointOfInterestType::Prefab9x9West:
			return m_pfb_9x9_w;
		case PointOfInterestType::Prefab5x5West:
			return m_pfb_5x5_w;
		
		case PointOfInterestType::Prefab35x35Block:
			return m_pfb_35x35;
		case PointOfInterestType::Prefab21x21Block:
			return m_pfb_21x21;
		case PointOfInterestType::Prefab13x13Block:
			return m_pfb_13x13;
		case PointOfInterestType::Prefab9x9Block:
			return m_pfb_9x9;
		case PointOfInterestType::Prefab7x7Block:
			return m_pfb_7x7;
		case PointOfInterestType::Prefab5x5Block:
			return m_pfb_5x5;
		case PointOfInterestType::Prefab3x3Block:
			return m_pfb_3x3;
		case PointOfInterestType::Prefab2x2Block:
			return m_pfb_2x2;
			
		case PointOfInterestType::Prefab5x5BlockNorth:
			return m_pfb_5x5_bn;
		case PointOfInterestType::Prefab5x5BlockSouth:
			return m_pfb_5x5_bs;
		case PointOfInterestType::Prefab5x6BlockEast:
			return m_pfb_5x6_be;
		case PointOfInterestType::Prefab5x6BlockWest:
			return m_pfb_5x6_bw;
		case PointOfInterestType::Prefab12x5BlockNorth:
			return m_pfb_12x5_bn;
		case PointOfInterestType::Prefab12x5BlockSouth:
			return m_pfb_12x5_bs;
		case PointOfInterestType::Prefab5x12BlockEast:
			return m_pfb_5x12_be;
		case PointOfInterestType::Prefab5x12BlockWest:
			return m_pfb_5x12_bw;
			
		case PointOfInterestType::Prefab12x7BlockNorthInverted:
			return m_pfb_12x7_bin;
		case PointOfInterestType::Prefab12x7BlockSouthInverted:
			return m_pfb_12x7_bis;
		case PointOfInterestType::Prefab7x12BlockEastInverted:
			return m_pfb_7x12_bie;
		case PointOfInterestType::Prefab7x12BlockWestInverted:
			return m_pfb_7x12_biw;
			
		case PointOfInterestType::Prefab2x3Junction:
			return m_pfb_2x3_jnc;
		case PointOfInterestType::Prefab2x6Path:
			return m_pfb_2x6_pth;
		case PointOfInterestType::Prefab6x3Path:
			return m_pfb_6x3_pth;
		case PointOfInterestType::Prefab4x6Path:
			return m_pfb_4x6_pth;
		case PointOfInterestType::Prefab6x4Path:
			return m_pfb_6x4_pth;
		
		case PointOfInterestType::Prefab5x12Path:
			return m_pfb_5x12_pth;		
		case PointOfInterestType::Prefab6x12Path:
			return m_pfb_6x12_pth;
		case PointOfInterestType::Prefab7x12Path:
			return m_pfb_7x12_pth;
			
		case PointOfInterestType::Prefab6x8Path:
			return m_pfb_6x8_pth;
		case PointOfInterestType::Prefab8x4Path:
			return m_pfb_8x4_pth;
		case PointOfInterestType::Prefab12x6Path:
			return m_pfb_12x6_pth;
		case PointOfInterestType::Prefab12x8Path:
			return m_pfb_12x8_pth;
			
		case PointOfInterestType::Prefab3x3Cliff:
			return m_pfb_3x3_clf;
		case PointOfInterestType::Prefab9x9Cliff:
			return m_pfb_9x9_clf;
		case PointOfInterestType::Prefab13x13Cliff:
			return m_pfb_13x13_clf;
		case PointOfInterestType::Prefab9x3Cliff:
			return m_pfb_9x3_clf;
		case PointOfInterestType::Prefab3x9Cliff:
			return m_pfb_3x9_clf;
		}
			
		return null;
	}
	
	void SpawnPointsOfInterest(Scene@ scene)
	{
		bool printPfb = GetVarBool("debug_dungeon_prefabs");
	
		for (uint i = 0; i < m_pointsOfInterest.length(); i++)
		{
			vec3 pos = vec3(16 * m_pointsOfInterest[i].m_pos.x + m_posOffset.x, 16 * m_pointsOfInterest[i].m_pos.y + m_posOffset.y, 0);
			
			switch(m_pointsOfInterest[i].m_type)
			{
			case PointOfInterestType::Entry:
				g_prefabsToSpawn.insertLast(PrefabToSpawn(m_pfb_entr, pos));
				//m_pfb_entr.Fabricate(scene, pos);
				break;
			case PointOfInterestType::Exit:
				g_prefabsToSpawn.insertLast(PrefabToSpawn(m_pfb_exit, pos));
				//m_pfb_exit.Fabricate(scene, pos);
				break;
				
			default:
			{
				auto pfb = GetPrefab(m_pointsOfInterest[i].m_type);
				if (pfb !is null)
				{
					if (printPfb)
						print("Spawning prefab: " + pfb.GetDebugName());
						
					g_prefabsToSpawn.insertLast(PrefabToSpawn(pfb, pos));
					//pfb.Fabricate(scene, pos);
				}
				
				break;
			}
			}
		}
	}
	
	bool HasPointOfInterest(PointOfInterestType poi)
	{ 
		if (poi == PointOfInterestType::Entry || poi == PointOfInterestType::Exit)
			return true;

		return GetPrefab(poi) !is null;
	}
	
	void AddPointOfInterest(PointOfInterestType type, int x, int y)
	{
		PointOfInterest poi;
		poi.m_type = type;
		poi.m_pos = ivec2(x, y);
		m_pointsOfInterest.insertLast(poi);
	}
	
	bool IsConsumed(int x, int y)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return true;
			
		return m_gridConsumed[x][y];
	}	

	void SetConsumed(int x, int y, bool consumed = true)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return;
			
		m_gridConsumed[x][y] = consumed;
	}
	
	void SetCell(int x, int y, Cell cell)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return;
			
		m_grid[x][y] = cell;
	}
	
	Cell GetCell(int x, int y)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return Cell::Outside;
	
		return m_grid[x][y];
	}
	
	bool IsWallOrBreakable(int x, int y)
	{
		auto cell = GetCell(x, y);
		return cell == Cell::Wall || cell == Cell::Breakables;
	}
	
	bool IsWall(int x, int y)
	{
		return GetCell(x, y) == Cell::Wall;
	}
	
	bool IsCliff(int x, int y)
	{
		return GetCell(x, y) == Cell::Cliff;
	}
	
	bool IsNothing(int x, int y)
	{
		return GetCell(x, y) == Cell::Nothing;
	}
	
	bool IsOpen(int x, int y)
	{
		auto cell = GetCell(x, y);
		return cell == Cell::Floor || cell == Cell::Breakables;
	}
	
	bool CenBeReplacedWithNothingness(int x, int y)
	{
		if (x < 0 || y < 0 || x >= m_width || y >= m_height)
			return true;
		return (m_grid[x][y] == Cell::Wall || m_grid[x][y] == Cell::Nothing);
	}
	
	void GenerateNothingness()
	{
		for (int y = 0; y < m_height; y++)
		{
			for (int x = 0; x < m_width; x++)
			{
				if (GetCell(x, y) == Cell::Wall)
				{
					if (!CenBeReplacedWithNothingness(x - 1, y - 1)) continue;
					if (!CenBeReplacedWithNothingness(x, y - 1)) continue;
					if (!CenBeReplacedWithNothingness(x + 1, y - 1)) continue;
					if (!CenBeReplacedWithNothingness(x - 1, y)) continue;
					if (!CenBeReplacedWithNothingness(x + 1, y)) continue;
					if (!CenBeReplacedWithNothingness(x - 1, y + 1)) continue;
					if (!CenBeReplacedWithNothingness(x, y + 1)) continue;
					if (!CenBeReplacedWithNothingness(x + 1, y + 1)) continue;
					
					SetCell(x, y, Cell::Nothing);
				}
			}
		}
	}
	
	void Build(Scene@ scene) {}
	
		
	void RemoveNearbySame(array<UnitPtr>@ deco, int dist)
	{
		dist = dist * dist;
		
		while(true)
		{
			bool removed = false;
			for (uint i = 0; i < deco.length(); i++)
			{
				for (uint j = 0; j < deco.length(); j++)
				{
					if (i == j)
						continue;
						
					if (deco[i].GetUnitProducer() !is deco[j].GetUnitProducer())
						continue;
				
					if (distsq(deco[i], deco[j]) > dist)
						continue;
					
					if (randi(2) == 0)
					{
						deco[i].Destroy();
						deco.removeAt(i);
						i--;
					}
					else
					{
						deco[j].Destroy();
						deco.removeAt(j);
					}
					
					removed = true;
					break;
				}
			}
			
			if (!removed)
				break;
		}
	}
	
	
	void RemoveNearby(array<UnitPtr>@ deco, int dist)
	{
		dist = dist * dist;
		
		while(true)
		{
			bool removed = false;
			for (uint i = 0; i < deco.length(); i++)
			{
				for (uint j = 0; j < deco.length(); j++)
				{
					if (i == j)
						continue;
				
					if (distsq(deco[i], deco[j]) > dist)
						continue;
					
					if (randi(2) == 0)
					{
						deco[i].Destroy();
						deco.removeAt(i);
						i--;
					}
					else
					{
						deco[j].Destroy();
						deco.removeAt(j);
					}
					
					removed = true;
					break;
				}
			}
			
			if (!removed)
				break;
		}
	}
}