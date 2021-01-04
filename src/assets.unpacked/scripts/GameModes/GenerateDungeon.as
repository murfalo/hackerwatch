pfloat g_ngp = 0.0f;

ivec3 CalcLevel(int levelNum)
{
	auto gm = cast<BaseGameMode>(g_gameMode);
	if (gm is null)
		return ivec3();

	auto level = gm.m_dungeon.GetLevel(levelNum);
	if (level is null)
		return ivec3();
	
	return ivec3(level.m_act, level.m_level, levelNum);
}

void SetLevelFlags(int levelCount)
{
	for (uint i = 0; i < Fountain::CurrentEffects.length(); i++)
	{
		auto effect = Fountain::GetEffect(Fountain::CurrentEffects[i]);
		if (effect is null)
		{
			PrintError("Couldn't find effect for ID " + Fountain::CurrentEffects[i]);
			continue;
		}

		if (effect.m_flag != "")
			g_flags.Set(effect.m_flag, FlagState::Level);
	}

	ivec3 lvl = CalcLevel(levelCount);

	g_flags.Set("act_" + lvl.x, FlagState::Level);
	g_flags.Set("lvl_" + lvl.y, FlagState::Level);
	g_flags.Set("lvlcount_" + lvl.z, FlagState::Level);
}

void GenerateDungeon(RandomLevel@ gameMode, int levelCount, int shortcut, int numPlrs)
{
	DungeonGenerator@ dgn = MakeDungeonGenerator(levelCount, numPlrs);
	
	print("LevelCount: " + levelCount);

	auto gm = cast<BaseGameMode>(g_gameMode);
	auto level = gm.m_dungeon.GetLevel(levelCount);

	SetLevelFlags(levelCount);

	if (dgn !is null)
	{
		if (gameMode !is null)
			@gameMode.m_enemyPlacer = dgn.m_enemyPlacer;
	
		if (level.m_level == 0 && shortcut > level.m_act)
			dgn.m_placeActShortcut = true;
		
		dgn.MakeBrush();
		dgn.m_brush.m_lvl = CalcLevel(levelCount);
		dgn.m_numPlrs = numPlrs;
		dgn.Generate(g_scene);
	}
}

ivec2 Rectangularize(int w, int h, float amount)
{
	int tot = w * h;
	w += int((randf() - randf()) * w * amount);
	h = tot / w;
	return ivec2(w, h);
}

array<PrefabToSpawn@> g_prefabsToSpawn;
class PrefabToSpawn
{
	Prefab@ m_pfb;
	vec3 m_pos;
	bool m_tileset;
	
	PrefabToSpawn(Prefab@ pfb, vec3 pos, bool includeTileset = false)
	{
		@m_pfb = pfb;
		m_pos = pos;
		m_tileset = includeTileset;
	}
	
	void Fabricate()
	{
		m_pfb.Fabricate(g_scene, m_pos, m_tileset);
	}
}


DungeonGenerator@ MakeDungeonGenerator(int levelCount, int numPlrs)
{
	DungeonGenerator@ dgn;
	EnemyPlacement enemyPlacer;

	auto gm = cast<BaseGameMode>(g_gameMode);
	auto level = gm.m_dungeon.GetLevel(levelCount);
	
	float enemyAmountMul = 1.0f;
	float levelSizeMul = 1.0f;
	
	if (Fountain::HasEffect("bigger_levels"))
	{
		levelSizeMul *= 1.15f;
		enemyAmountMul *= 1.33f;
	}

	if (g_ngp > 0)
	{
		levelSizeMul *= 1.15f;
		enemyAmountMul *= 1.33f;
	}
	
	bool forceMiniboss = Fountain::HasEffect("minibosses_everywhere");
	if (level.m_theme == "mines")
	{
		MinesGenerator mines;
		
		auto brush = GraniteMineBrush();
		brush.m_grassChanceAdjustment = -3 * level.m_level;
		@mines.m_brush = brush;
		
	
		if (level.m_level == 0)
			g_flags.Set("no_flowers", FlagState::Level);

		mines.Width = int(level.m_width * levelSizeMul);
		mines.Height = int(level.m_height * levelSizeMul);
		
		
		mines.Density = 1;
		mines.RoomChance = 0.1;
		mines.RoomSize = 12;
		mines.NumDeadEndsFill = 5;
		mines.MaxCliffNum = 0;
		mines.Prefabs = true;

		
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Bats, 1, true, level.m_level >= 2));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Ticks, 3, true, level.m_level >= 1, forceMiniboss || level.m_level >= 2).AddExtra("actors/tick_1_small_exploding.unit", 2));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Maggots, (level.m_level == 0) ? 1 : 2, true, level.m_level >= 1, false));
		
		enemyPlacer.m_maxMinibosses = 2 + int(g_ngp) * 2 + numPlrs;
		mines.MinEnemyGroups = int(enemyAmountMul * (8 + level.m_level * 5 + numPlrs * 2));
		mines.EnemyGroupChance = 1;
		
		@dgn = mines;
	}
	else if (level.m_theme == "prison")
	{
		PrisonGenerator prison;
		prison.Tileset = DungeonTileset::Prison;
	
		prison.Width = int(level.m_width * levelSizeMul);
		prison.Height = int(level.m_height * levelSizeMul);
		
		
		prison.Density = 2.5;
		prison.RoomChance = 0.2;
		prison.RoomSize = 12;
		prison.NumDeadEndsFill = 20;
		prison.MaxCliffNum = 5;
		prison.Prefabs = true;
		

		if (level.m_level < 1)
			enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Ticks, 3, true, true));
		
		if (level.m_level < 2)
			enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Bats, 3, true, true));

		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Maggots, 3, true, true, forceMiniboss || level.m_level >= 2));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::SkeletonArchers1, 2, true, level.m_level >= 1, false));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Skeletons1, 3, true, level.m_level >= 1, false).AddExtra("actors/bannerman_bloodlust.unit", (level.m_level >= 1) ? 1 : 0, 0.75f));
		
		enemyPlacer.m_maxMinibosses = 3 + int(g_ngp) * 2 + numPlrs;
		prison.MinEnemyGroups = int(enemyAmountMul * (20 + level.m_level * 3 + numPlrs * 2));
		prison.EnemyGroupChance = 1;
		
		@dgn = prison;
	}
	else if (level.m_theme == "armory")
	{
		ArmoryGenerator armory;
		armory.Tileset = DungeonTileset::Armory;
	
		armory.Width = int(level.m_width * levelSizeMul);
		armory.Height = int(level.m_height * levelSizeMul);
		auto sz = Rectangularize(armory.Width, armory.Height, 0.25);
		armory.Width = sz.x;
		armory.Height = sz.y;
		
		armory.RoomSize = 17 + numPlrs;
		armory.MaxCliffNum = 2;
		armory.Prefabs = true;
		
		if (level.m_level < 1)
			enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::SkeletonArchers1, 1, true, true, false));
		
		if (level.m_level < 2)
			enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Skeletons1, 1, true, true, false).AddExtra("actors/bannerman_bloodlust.unit", 1, 0.5f));

		auto skelGroup = EnemySetting(Enemies::Skeletons1, 1, true, true, forceMiniboss || level.m_level >= 2)
			.AddExtra("actors/bannerman_bloodlust.unit", 1, 0.2f)
			.AddExtra("actors/bannerman_protection.unit", 1, 0.2f)
			.AddExtra("actors/skeleton_1_spear.unit", 4, 1.5f);
		
		if (level.m_level >= 1)
			skelGroup.AddExtra("actors/lich_summ_1.unit", 1, 0.1f);
		
			
		enemyPlacer.AddEnemyGroup(skelGroup);
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::SkeletonArchers1, 1, true, true, false).AddExtra("actors/lich_1.unit", 2));
		
		enemyPlacer.m_maxMinibosses = 4 + int(g_ngp) * 2 + numPlrs * 2;
		armory.MinEnemyGroups = int(enemyAmountMul * (24 + numPlrs * 5 + level.m_level * 5));
		armory.EnemyGroupChance = 1;
		
		@dgn = armory;
	}
	else if (level.m_theme == "archives")
	{
		ArchivesGenerator archives;
		archives.Tileset = DungeonTileset::Archives;
		
		levelSizeMul = lerp(1.0f, levelSizeMul, 0.5f);
		enemyAmountMul = lerp(1.0f, enemyAmountMul, 0.5f);
	    
		archives.Width = int(level.m_width * levelSizeMul);
		archives.Height = int(level.m_height * levelSizeMul);
		auto sz = Rectangularize(archives.Width, archives.Height, 0.25);
		archives.Width = sz.x;
		archives.Height = sz.y;
		
		archives.Padding = 30;
		archives.PathWidth = 5;
		archives.Prefabs = true;

		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Ghosts, 1, true, true, false));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Eyes, 5, true, true, forceMiniboss || level.m_level >= 1)
			.AddExtra("actors/lich_1.unit", 2, 0.5f));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Wisps, 5, true, level.m_level >= 1, false)
			.AddExtra("actors/lich_1.unit", 2, 0.5f));
		
		enemyPlacer.m_maxMinibosses = 0; //4 + level.m_level * (3 + int(g_ngp) * 2) + numPlrs;
		archives.MinEnemyGroups = int(enemyAmountMul * (20 + level.m_level * 3 + numPlrs * 4));
		archives.EnemyGroupChance = 1;
		
		@dgn = archives;
	}
	else if (level.m_theme == "chambers")
	{
		ChambersGenerator chambers;
		chambers.Tileset = DungeonTileset::Chambers;
		
		chambers.Width = int(level.m_width * levelSizeMul);
		chambers.Height = int(level.m_height * levelSizeMul);
		
		chambers.Padding = 43;
		chambers.Splits = 8 + level.m_level;
		chambers.Prefabs = true;
		
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::SkeletonArchers2, 2, true, level.m_level >= 1, false));
			
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Skeletons2, 4, true, true, forceMiniboss || level.m_level >= 2)
			); //.AddExtra("actors/bannerman_healing.unit", 1, 0.1f));
		
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Liches, 1, true, true, forceMiniboss || level.m_level >= 2));
		
		enemyPlacer.m_maxMinibosses = 6 + level.m_level * (4 + int(g_ngp) * 2) + numPlrs;
		chambers.MinEnemyGroups = int(enemyAmountMul * (32 + level.m_level * 4 + numPlrs * 4));
		chambers.EnemyGroupChance = 1;
		
		@dgn = chambers;
	}
	else if (level.m_theme == "battlements")
	{
		@dgn = DungeonGenerator();
	
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::IceTrolls, 1, true, true, forceMiniboss || level.m_level >= 1)
		.AddExtra("actors/ice_troll_shaman.unit", 1, 0.8f));
		
		enemyPlacer.m_maxMinibosses = 6 + level.m_level * (4 + int(g_ngp) * 2) + numPlrs;
	}
	else if (level.m_theme == "desert")
	{
		DesertGenerator desert;
		desert.Tileset = DungeonTileset::Desert;
	
		desert.Width = int(level.m_width * levelSizeMul);
		desert.Height = int(level.m_height * levelSizeMul);
		
		/*
		desert.Density = 3.0;
		desert.RoomChance = 0.25;
		desert.RoomSize = 8;
		desert.NumDeadEndsFill = 20;
		desert.MaxCliffNum = 3;
		*/
		desert.Prefabs = true;


		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Snakes, 1, false, false, false));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Scorpions, 4, false, level.m_level >= 1, forceMiniboss || level.m_level >= 2));
		
		enemyPlacer.m_maxMinibosses = 4 + int(g_ngp) * 2 + numPlrs;
		desert.MinEnemyGroups = 0;
		desert.EnemyGroupChance = 1;
		
		@dgn = desert;
	}
	else if (level.m_theme == "pyramid_slum")
	{
		PyramidGenerator pyramid;
		pyramid.Tileset = DungeonTileset::PyramidSlum;
	
		pyramid.Width = int(level.m_width * levelSizeMul);
		pyramid.Height = int(level.m_height * levelSizeMul);
		
		
		pyramid.Density = 3.0;
		pyramid.RoomChance = 0.25;
		pyramid.RoomSize = 8;
		pyramid.NumDeadEndsFill = 20;
		pyramid.MaxCliffNum = 3;
		pyramid.Prefabs = true;
		
		int extraElites = 0;
		if (Fountain::HasEffect("more_elites"))
			extraElites = 2;

		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Mummies1, 3, true, false, forceMiniboss || level.m_level >= 2));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::MummyRanged1, 2, level.m_level >= 1, false).AddExtra("actors/pop/high_priest_green.unit", extraElites + ((level.m_level >= 1) ? 1 : 0)));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Snakes, 1, false, true, false));
		//enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Spiders, level.m_level, false, true, false));

		
		enemyPlacer.m_maxMinibosses = 4 + int(g_ngp) * 2 + numPlrs;
		pyramid.MinEnemyGroups = int(enemyAmountMul * (22 + level.m_level * 3 + numPlrs * 4));
		pyramid.EnemyGroupChance = 0.8f;
		
		@dgn = pyramid;
	}
	else if (level.m_theme == "pyramid_fancy")
	{
		PyramidFancyGenerator pyramid;
		pyramid.Tileset = DungeonTileset::PyramidFancy;
	
		auto sz = Rectangularize(int(level.m_width * levelSizeMul), int(level.m_height * levelSizeMul), 0.25);
		pyramid.Width = sz.x;
		pyramid.Height = sz.y;
		
		pyramid.RoomSize = 17 + numPlrs;
		pyramid.LoopNum = 16;
		pyramid.MaxCliffNum = 2;
		pyramid.Prefabs = true;
	
		int extraElites = 0;
		if (Fountain::HasEffect("more_elites"))
			extraElites = 3;

		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::Mummies2, 3, true, forceMiniboss || level.m_level >= 2).AddExtra("actors/pop/high_priest_red.unit", 1, extraElites + level.m_level + 0.75f));
		enemyPlacer.AddEnemyGroup(EnemySetting(Enemies::MummyRanged2, 2, level.m_level >= 1, false).AddExtra("actors/pop/high_priest_blue.unit", 1, extraElites + level.m_level + 0.75f));
		
		enemyPlacer.m_maxMinibosses = 6 + int(g_ngp) * 3 + numPlrs;
		pyramid.MinEnemyGroups = int(1.75f * enemyAmountMul * (32 + level.m_level * 6 + numPlrs * 6));
		pyramid.EnemyGroupChance = 0.4f;
		
		@dgn = pyramid;
	}
	else if (level.m_theme == "moon_temple_poor")
	{
		LabyrinthGenerator labyrinth;

		labyrinth.Set = level.m_theme;
		labyrinth.ColorTheme = "temple_poor";
		labyrinth.RoomSections = int(level.m_width * levelSizeMul);
		labyrinth.ReserveSections = 0.0f;
		labyrinth.DoorwaysMin = 0.5f;
		labyrinth.DoorwaysMax = 1.0f;
		labyrinth.RoomSectionTightnessLimit = 1.5f; // default 1.5f
	
	
		switch(randi(4))
		{
		case 0:
			labyrinth.Set = level.m_theme + "_1";
			labyrinth.RoomSectionWidthLimit = 4;
			break;
		case 1:
			labyrinth.Set = level.m_theme + "_2";
			labyrinth.RoomSectionWidthLimit = 4;
			break;
		case 2:
			labyrinth.Set = level.m_theme + "_3";
			labyrinth.RoomSectionHeightLimit = 4;
			break;
		case 3:
			labyrinth.Set = level.m_theme + "_4";
			labyrinth.RoomSectionHeightLimit = 4;
			break;
		}
	
		// labyrinth.RoomSectionWidthLimit = -1;
		// labyrinth.RoomSectionHeightLimit = 4;
		// labyrinth.Set = level.m_theme + "_3";
		print (labyrinth.Set);
		
		@dgn = labyrinth;
	}
	else if (level.m_theme == "moon_temple_common")
	{
		LabyrinthGenerator labyrinth;
	
		labyrinth.Set = level.m_theme;
		labyrinth.ColorTheme = "temple_common";
		labyrinth.RoomSections = int(level.m_width * levelSizeMul);
		labyrinth.DoorwaysMin = 0.33f;
		labyrinth.DoorwaysMax = 1.0f;
		
		switch(randi(4))
		{
		case 0:
			labyrinth.Set = level.m_theme + "_1";
			labyrinth.ReserveSections = 0.25f;
			break;
		case 1:
			labyrinth.Set = level.m_theme + "_4";
			labyrinth.ReserveSections = 0.10f;
			break;
		case 2:
			labyrinth.Set = level.m_theme + "_3";
			labyrinth.ReserveSections = 0.10f;
			break;
		case 3:
			labyrinth.Set = level.m_theme + "_4";
			labyrinth.ReserveSections = 0.2f;
			break;
		}
		
		//labyrinth.Set = level.m_theme + "_4";
		//labyrinth.ReserveSections = 0.2f;
		print (labyrinth.Set);
		
		@dgn = labyrinth;
	}
	else if (level.m_theme == "moon_temple_rich")
	{
		LabyrinthGenerator labyrinth;
	
		labyrinth.Set = level.m_theme;
		labyrinth.ColorTheme = "temple_rich";
		labyrinth.RoomSections = int(level.m_width * levelSizeMul);
		labyrinth.ReserveSections = 0.0f;
		labyrinth.DoorwaysMin = 1.0f;
		labyrinth.DoorwaysMax = 1.0f;
		
		switch(randi(4))
		{
		case 0:
			labyrinth.Set = level.m_theme + "_1";
			labyrinth.RoomSectionTightnessLimit = 1.7f;
			break;
		case 1:
			labyrinth.Set = level.m_theme + "_2";
			labyrinth.RoomSectionTightnessLimit = 5.0f;
			break;
		case 2:
			labyrinth.Set = level.m_theme + "_3";
			labyrinth.RoomSectionTightnessLimit = 5.0f;
			break;
		case 3:
			labyrinth.Set = level.m_theme + "_4";
			labyrinth.RoomSectionTightnessLimit = 1.2f;
			break;
		}

		// labyrinth.ReserveSections = 0.15f;
		// labyrinth.RoomSectionTightnessLimit = 1.0f;
		// labyrinth.RoomSectionTightnessLimit = 3.0f;
		// labyrinth.RoomSectionTightnessLimit = 5.0f;
		// labyrinth.Set = level.m_theme + "_1";
		print (labyrinth.Set);

		@dgn = labyrinth;
	}
	
	
	if (dgn !is null)
		@dgn.m_enemyPlacer = enemyPlacer;
		
	return dgn;
}