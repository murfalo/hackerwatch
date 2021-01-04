int GetAct()
{
	int act = 0;
	
	auto gm = cast<Campaign>(g_gameMode);
	if (gm !is null)
	{
		ivec3 level = CalcLevel(gm.m_levelCount);
		act = level.x;
	}

	if (g_flags.IsSet("dlc_pop"))
		act += 2;
		
	return act;
}

namespace RandomLootManager
{
	array<WorldScript::RandomLoot@> lootPoints;

	bool gotPossibleBlueprintItems;
	array<ActorItem@> possibleBlueprintItems;

	bool gotPossibleDyes;
	array<Materials::Dye@> possibleDyes;
	
	bool hasSpawnedStatueBlueprint;
	
	
	ActorItemQuality RollQuality(array<int> chances)
	{
		int total = 0;

		// Increase the likelihood of better rolls
		for (int i = chances.length() - 1;  i >= 0; --i)
		{
			chances[i] = chances[i] * (1 << i);
		}

		for (uint i = 0; i < chances.length(); i++)
			total += chances[i];

		int n = randi(total);
		for (uint i = 0; i < chances.length(); i++)
		{
			n -= chances[i];
			if (n < 0)
				return ActorItemQuality(i);
		}
		
		return ActorItemQuality::None;
	}
	
	void FallbackSpawn(vec2 pos)
	{
		UnitProducer@ fallback = null;
		
		int act = GetAct();
		
		
		if (act < 2)
		{
			if (randi(100) < 75)
				@fallback = Resources::GetUnitProducer("items/money_diamond_blue_small.unit");
			else
				@fallback = Resources::GetUnitProducer("items/money_diamond_blue_large.unit");
		}
		else if (act < 4)
		{
			if (randi(100) < 75)
				@fallback = Resources::GetUnitProducer("items/money_diamond_red_small.unit");
			else
				@fallback = Resources::GetUnitProducer("items/money_diamond_red_large.unit");
		}
		else
		{
			if (randi(100) < 75)
				@fallback = Resources::GetUnitProducer("items/money_diamond_gold_small.unit");
			else
				@fallback = Resources::GetUnitProducer("items/money_diamond_gold_large.unit");
		}
		
		if (fallback is null)
			@fallback = Resources::GetUnitProducer("items/ore.unit");
		
		fallback.Produce(g_scene, xyz(pos));
	}

	void NetSpawnDrinkBarrel(vec2 pos, ActorItemQuality quality)
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm.m_townLocal.GetBuilding("tavern").m_level <= 0)
		{
			FallbackSpawn(pos);
			return;
		}

		auto barrelProd = Resources::GetUnitProducer("items/barrel.unit");
		auto barrel = barrelProd.Produce(g_scene, xyz(pos));
		auto behavior = cast<TavernBarrel>(barrel.GetScriptBehavior());
		behavior.Initialize(quality);
	}

	void NetSpawnItemBlueprint(vec2 pos, ActorItemQuality quality)
	{
		auto gm = cast<Campaign>(g_gameMode);

		if (!gotPossibleBlueprintItems)
		{
			for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
			{
				auto item = g_items.m_allItemsList[i];

				if (!item.hasBlueprints || item.quality != quality)
					continue;

				if (gm.m_townLocal.m_forgeBlueprints.find(item.idHash) != -1)
					continue;
					
				if (!HasDLC(item.dlc))
					continue;

				possibleBlueprintItems.insertLast(item);
			}
			gotPossibleBlueprintItems = true;
		}

		if (possibleBlueprintItems.length() == 0)
		{
			FallbackSpawn(pos);
			return;
		}

		auto blueprintProd = Resources::GetUnitProducer("items/blueprint.unit");
		auto blueprint = blueprintProd.Produce(g_scene, xyz(pos));
		auto behavior = cast<ForgeBlueprint>(blueprint.GetScriptBehavior());

		int randomIndex = randi(possibleBlueprintItems.length());
		auto item = possibleBlueprintItems[randomIndex];
		possibleBlueprintItems.removeAt(randomIndex);

		behavior.Initialize(item);
	}

	void NetSpawnDyeBucket(vec2 pos, ActorItemQuality quality)
	{
		auto gm = cast<Campaign>(g_gameMode);

		if (!gotPossibleDyes)
		{
			for (uint i = 0; i < Materials::g_dyes.length(); i++)
			{
				auto dye = Materials::g_dyes[i];

				// Skip default dyes
				if (dye.m_default)
					continue;

				// Skip dyes unlocked with legacy points
				if (dye.m_legacyPoints > 0)
					continue;

				// Skip unmatched dye quality
				if (dye.m_quality != quality)
					continue;

				// Skip already-owned dyes
				if (gm.m_townLocal.OwnsDye(dye))
					continue;

				// Skip dyes that require a DLC that we don't have
				if (!HasDLC(dye.m_dlc))
					continue;

				possibleDyes.insertLast(dye);
			}
			gotPossibleDyes = true;
		}

		if (possibleDyes.length() == 0)
		{
			FallbackSpawn(pos);
			return;
		}

		auto bucketProd = Resources::GetUnitProducer("items/dye_bucket.unit");
		auto bucket = bucketProd.Produce(g_scene, xyz(pos));
		auto behavior = cast<DyeBucket>(bucket.GetScriptBehavior());

		int randomIndex = randi(possibleDyes.length());
		auto item = possibleDyes[randomIndex];
		possibleDyes.removeAt(randomIndex);

		behavior.Initialize(item);
	}

	ActorItemQuality RandomItemQuality()
	{
		if (g_ngp == 0)
			return RollQuality({ 2, 10, 0, 0 });
		else if (g_ngp == 1)
			return RollQuality({ 0, 6, 4, 0 });
		else if (g_ngp == 2)
			return RollQuality({ 0, 4, 3, 2 });
		else
			return RollQuality({ 0, 3, 3, 3 });
	}

	bool SpawnDrinkBarrel(int index)
	{
		WorldScript::RandomLoot@ loot = lootPoints[index];

		ActorItemQuality quality = RandomItemQuality();
		if (quality != ActorItemQuality::None)
		{
			(Network::Message("SpawnDrinkBarrel") << xy(loot.Position) << int(quality)).SendToAll();
			NetSpawnDrinkBarrel(xy(loot.Position), quality);
			lootPoints.removeAt(index);
			return true;
		}
		
		return false;
	}

	bool SpawnForgeBlueprint(int index)
	{
		if (!g_flags.IsSet("unlock_anvil"))
			return false;
	
		WorldScript::RandomLoot@ loot = lootPoints[index];

		ActorItemQuality quality = RandomItemQuality();
		if (quality != ActorItemQuality::None)
		{
			(Network::Message("SpawnItemBlueprint") << xy(loot.Position) << int(quality)).SendToAll();
			NetSpawnItemBlueprint(xy(loot.Position), quality);
			lootPoints.removeAt(index);
			return true;
		}
		
		return false;
	}
	
	float CalcStatueBlueprintChance(int blueprintLevel)
	{
		return min(2.0f, pow((g_ngp + 1) / (blueprintLevel + 1), blueprintLevel));
	}

	bool SpawnStatueBlueprint(int index)
	{
		// Comment this out to test statue blueprints in Town
		if (!g_flags.IsSet("dlc_pop"))
			return false;
			
		if (!g_owns_dlc_pop)
			return false;
			
		if (hasSpawnedStatueBlueprint)
			return false;

		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return false;

		float totChance = 0;
		for (uint i = 0; i < Statues::g_statues.length(); i++)
		{
			int bp = 0;

			auto statueDef = Statues::g_statues[i];
			auto statue = gm.m_townLocal.GetStatue(statueDef.m_id);
			if (statue !is null)
				bp = statue.m_blueprint;

			totChance += CalcStatueBlueprintChance(bp);
		}
		
		Statues::StatueDef@ picked = null;
		float r = randf() * (max(8.0f, totChance * 3) + 4);

		for (uint i = 0; i < Statues::g_statues.length(); i++)
		{
			int bp = 0;

			auto statueDef = Statues::g_statues[i];
			auto statue = gm.m_townLocal.GetStatue(statueDef.m_id);
			if (statue !is null)
				bp = statue.m_blueprint;

			r -= CalcStatueBlueprintChance(bp);
			if (r <= 0)
			{
				@picked = statueDef;
				break;
			}
		}
		
		if (picked !is null)
		{
			hasSpawnedStatueBlueprint = true;
			WorldScript::RandomLoot@ loot = lootPoints[index];
			
			auto blueprintProd = Resources::GetUnitProducer("items/statue_blueprint.unit");
			auto blueprint = blueprintProd.Produce(g_scene, loot.Position);
			auto behavior = cast<StatueBlueprint>(blueprint.GetScriptBehavior());
			behavior.Initialize(picked);
			
			lootPoints.removeAt(index);
			return true;
		}
		
		return false;
	}

	bool SpawnDyeBucket(int index)
	{
		WorldScript::RandomLoot@ loot = lootPoints[index];

		ActorItemQuality quality = RandomItemQuality();
		if (quality != ActorItemQuality::None)
		{
			(Network::Message("SpawnDyeBucket") << xy(loot.Position) << int(quality)).SendToAll();
			NetSpawnDyeBucket(xy(loot.Position), quality);
			lootPoints.removeAt(index);
			return true;
		}

		return false;
	}

	bool SpawnLoot(int index, bool forced)
	{
%if !HARDCORE
		float chance = 0.4f + 0.01f * g_ngp;
	
		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
			chance += CalcLevel(gm.m_levelCount).y * 0.1f;
	
		if (!forced && randf() < chance)
			return false;
	
		int attempts = forced ? 100 : (2 + int(g_ngp / 3.0f));
		for (int i = 0; i < attempts; i++)
		{
			switch(randi(5))
			{
			case 0:
			case 1:
				if (SpawnDrinkBarrel(index))
					return true;
				break;
			case 2:
			case 3:
				if (SpawnForgeBlueprint(index))
					return true;
				break;
			case 4:
				if (SpawnDyeBucket(index))
					return true;
				break;
			}
		}
%endif
		
		if (forced)
		{
			FallbackSpawn(xy(lootPoints[index].Position));
			lootPoints.removeAt(index);
			return true;
		}

		return false;
	}

	void Update(int ms)
	{
		if (lootPoints.length() == 0)
			return;

%if !HARDCORE
		SpawnStatueBlueprint(randi(lootPoints.length()));
%endif

		if (!Network::IsServer())
		{
			lootPoints.removeRange(0, lootPoints.length());
			return;
		}

		int toSpawn = roll_round(1.0f + g_ngp / 10.0f);
		for (uint i = 0; i < lootPoints.length(); i++)
		{
			if (lootPoints[i].Forced)
			{
				if (SpawnLoot(i, true))
					i--;
				toSpawn--;
			}
		}
		
		while (toSpawn > 0 && lootPoints.length() > 0)
		{
			SpawnLoot(randi(lootPoints.length()), false);
			toSpawn--;
		}

		lootPoints.removeRange(0, lootPoints.length());
	}

	void AddLootPoint(WorldScript::RandomLoot@ pos)
	{
		lootPoints.insertLast(pos);
	}
	
	void Save(SValueBuilder& builder)
	{
/*
		if (g_currMusic !is null)
			builder.PushString("curr-music", g_currMusic.GetName());
*/
	}
	
	void Load(SValue@ save)
	{
/*
		auto musicData = save.GetDictionaryEntry("curr-music");
		if (musicData !is null && musicData.GetType() == SValueType::String)
		{
			auto music = Resources::GetSoundEvent(musicData.GetString());
			if (music !is null)
				Play(music);
		}
*/
	}
}