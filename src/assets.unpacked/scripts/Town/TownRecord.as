int g_bestiaryCostCommon;
int g_bestiaryCostUncommon;
int g_bestiaryCostRare;
int g_bestiaryCostEpic;
int g_bestiaryCostLegendary;

void LoadBestiaryCosts(SValue@ sval)
{
	g_bestiaryCostCommon = GetParamInt(UnitPtr(), sval, "common");
	g_bestiaryCostUncommon = GetParamInt(UnitPtr(), sval, "uncommon");
	g_bestiaryCostRare = GetParamInt(UnitPtr(), sval, "rare");
	g_bestiaryCostEpic = GetParamInt(UnitPtr(), sval, "epic");
	g_bestiaryCostLegendary = GetParamInt(UnitPtr(), sval, "legendary");
}

class BestiaryEntry
{
	uint m_idHash;
	uint m_type;
	ActorItemQuality m_quality;
	string m_dlc;

	int m_kills;
	int m_killer;
	UnitProducer@ m_producer;
	
	BestiaryEntry(UnitProducer@ producer, int kills, int killer)
	{
		m_idHash = producer.GetResourceHash();
		@m_producer = producer;

		m_kills = kills;
		m_killer = killer;
		
		auto params = m_producer.GetBehaviorParams();
		m_type = HashString(GetParamString(UnitPtr(), params, "type", false));
		m_quality = ParseActorItemQuality(GetParamString(UnitPtr(), params, "quality", false, "common"));
		m_dlc = GetParamString(UnitPtr(), params, "dlc", false);
	}

	int opCmp(const BestiaryEntry &in other)
	{
		int s = int(m_quality);
		int o = int(other.m_quality);

		if (s > o)
			return 1;
		else if (o > s)
			return -1;
		return 0;
	}
}

class ItemiaryEntry
{
	int m_count;
	ActorItem@ m_item;
	
	ItemiaryEntry(ActorItem@ item, int count)
	{
		@m_item = item;
		m_count = count;
	}
}

class FountainPreset
{
	array<uint> effects;

	void Save(SValueBuilder@ builder)
	{
		builder.PushDictionary();
		builder.PushArray("effects");
		for (uint i = 0; i < effects.length(); i++)
			builder.PushInteger(effects[i]);
		builder.PopArray();
		builder.PopDictionary();
	}

	void Load(SValue@ data)
	{
		effects.removeRange(0, effects.length());
		auto arrEffects = GetParamArray(UnitPtr(), data, "effects", false);
		if (arrEffects !is null)
		{
			for (uint i = 0; i < arrEffects.length(); i++)
				effects.insertLast(arrEffects[i].GetInteger());
		}
	}
}

class TownRecord
{
	bool m_local;

	// Userdata that can be used by mods. This does NOT save by itself.
	dictionary m_userdata;

	array<TownBuilding@> m_buildings;

	array<TownStatue@> m_statues;
	array<string> m_statuePlacements;
	array<BestiaryEntry@> m_bestiary;
	array<ItemiaryEntry@> m_itemiary;

	Stats::StatList@ m_statistics;
	Stats::StatList@ m_statisticsMercenaries;

	pint m_gold;
	pint m_ore;
	pint m_legacyPoints;

	pint m_fountainGold;

	pint m_reputationPresented;

	pint m_currentNgp;
	DungeonNgpList m_highestNgps;
	pint m_lastGladiatorRank;

	pint m_earnedLegacyPoints;

	array<uint> m_bossesKilled;

	array<string> m_townFlags;

	array<uint> m_forgeBlueprints;
	array<Materials::Dye@> m_dyes;
	array<PlayerTrails::TrailDef@> m_trails;
	array<PlayerFrame@> m_frames;
	array<uint> m_petSkins;
	array<uint> m_comboStyles;
	array<uint> m_gravestones;

	array<uint> m_survivalBlueprints;

	array<uint> m_savedFountainEffects;

	array<FountainPreset@> m_fountainPresets;

	TownRecord(bool local = false)
	{
		m_local = local;

		for (int i = 0; i < 4; i++)
			m_fountainPresets.insertLast(FountainPreset());

		m_buildings.insertLast(TownBuilding(this, "townhall", 1));
		m_buildings.insertLast(TownBuilding(this, "guildhall", 1));
		m_buildings.insertLast(TownBuilding(this, "generalstore", 1));
		m_buildings.insertLast(TownBuilding(this, "blacksmith", 0));
		m_buildings.insertLast(TownBuilding(this, "oretrader", 0));
		m_buildings.insertLast(TownBuilding(this, "apothecary", 0));
		m_buildings.insertLast(TownBuilding(this, "fountain", 0));
		m_buildings.insertLast(TownBuilding(this, "magicshop", 0));
		m_buildings.insertLast(TownBuilding(this, "chapel", 0));
		m_buildings.insertLast(TownBuilding(this, "tavern", 0));
		m_buildings.insertLast(TownBuilding(this, "treasury", 1));
		m_buildings.insertLast(TownBuilding(this, "sculptor", 0));
		m_buildings.insertLast(TownBuilding(this, "forge", 0));

		@m_statistics = Stats::LoadList("tweak/stats.sval");
		@m_statisticsMercenaries = Stats::LoadList("tweak/stats.sval");

		for (int i = 0; i < 7 + 2 + 3; i++)
			m_bossesKilled.insertLast(0);

		m_gold = 500;
	}

	void RefreshModifiers()
	{
		for (uint i = 0; i < m_buildings.length(); i++)
			m_buildings[i].RefreshModifiers();
	}

	void FoundItem(ActorItem@ item)
	{
		for (uint i = 0; i < m_itemiary.length(); i++)
		{
			if (m_itemiary[i].m_item !is item)
				continue;
			
			m_itemiary[i].m_count++;
			return;
		}
		
		m_itemiary.insertLast(ItemiaryEntry(item, 1));
	}
	
	void KilledEnemy(Actor@ actor)
	{
		UnitProducer@ prod = null;
	
		auto enemy = cast<CompositeActorBehavior>(actor);
		if (enemy !is null && enemy.m_bestiaryOverride != "")
			@prod = Resources::GetUnitProducer(enemy.m_bestiaryOverride);
	
		if (prod is null)
			@prod = actor.m_unit.GetUnitProducer();
	
		for (uint i = 0; i < m_bestiary.length(); i++)
		{
			if (m_bestiary[i].m_producer !is prod)
				continue;
			
			m_bestiary[i].m_kills++;
			return;
		}
		
		m_bestiary.insertLast(BestiaryEntry(prod, 1, 0));
	}

	void EnemyKilledPlayer(Actor@ actor)
	{
		UnitProducer@ prod = null;
	
		auto enemy = cast<CompositeActorBehavior>(actor);
		if (enemy !is null && enemy.m_bestiaryOverride != "")
			@prod = Resources::GetUnitProducer(enemy.m_bestiaryOverride);
	
		if (prod is null)
			@prod = actor.m_unit.GetUnitProducer();
	
		for (uint i = 0; i < m_bestiary.length(); i++)
		{
			if (m_bestiary[i].m_producer !is prod)
				continue;
			
			m_bestiary[i].m_killer++;
			return;
		}
		
		m_bestiary.insertLast(BestiaryEntry(prod, 0, 1));
	}
	
	array<BestiaryEntry@>@ GetBestiary(string type)
	{
		uint filter = HashString(type);
		array<BestiaryEntry@> ret;
		
		for (uint i = 0; i < m_bestiary.length(); i++)
		{
			if (m_bestiary[i].m_type != filter)
				continue;

			ret.insertLast(m_bestiary[i]);
		}
		
		return ret;
	}
	
	BestiaryEntry@ GetBestiaryEntry(UnitProducer@ prod, bool makeNew = false)
	{
		for (uint i = 0; i < m_bestiary.length(); i++)
		{
			if (m_bestiary[i].m_producer is prod)
				return m_bestiary[i];
		}
		
		if (makeNew)
		{
			BestiaryEntry@ entry = BestiaryEntry(prod, 0, 0);
			m_bestiary.insertLast(entry);
			return entry;
		}
		
		return null;
	}

	int GetReputation()
	{
		return m_statistics.GetReputationPoints();
	}

	int GetReputationPresented()
	{
		return m_reputationPresented;
	}

	void CheckForNewTitle()
	{
		if (cast<Town>(g_gameMode) !is null)
		{
			while(true)
			{
				auto nextTitle = GetNextTitleFromPoints(m_reputationPresented);
				if (nextTitle is null)
					break;

				if (nextTitle.m_points > GetReputation())
					break;

				OnNewTitle(nextTitle);
				m_reputationPresented = nextTitle.m_points;
			}
		}
	}

	void OnNewTitle(Titles::Title@ title)
	{
		print("New guild title: \"" + title.m_name + "\"");

		m_gold += title.m_unlockGold;
		m_ore += title.m_unlockOre;

		auto gm = cast<Campaign>(g_gameMode);
		gm.RefreshTownModifiers();
		gm.SaveLocalTown();

		dictionary paramsTitle = { { "title", Resources::GetString(title.m_name) } };
		auto notif = gm.m_notifications.Add(
			Resources::GetString(".hud.newtitle.guild", paramsTitle),
			ParseColorRGBA("#" + Tweak::NotificationColors_NewTitle + "FF")
		);

		if (title.m_unlockGold > 0)
			notif.AddSubtext("icon-gold", formatThousands(title.m_unlockGold));
		if (title.m_unlockOre > 0)
			notif.AddSubtext("icon-ore", formatThousands(title.m_unlockOre));
		if (title.m_skillPoints > 0)
			notif.AddSubtext("icon-star", formatThousands(title.m_skillPoints));
	}

	Titles::Title@ GetTitle()
	{
		auto gm = cast<Campaign>(g_gameMode);
		return gm.m_titlesGuild.GetTitleFromPoints(GetReputation());
	}

	Titles::Title@ GetNextTitle()
	{
		return GetNextTitleFromPoints(GetReputation());
	}

	Titles::Title@ GetNextTitleFromPoints(int points)
	{
		auto gm = cast<Campaign>(g_gameMode);
		return gm.m_titlesGuild.GetNextTitleFromPoints(points);
	}

	void GiveStatue(string id, int level)
	{
		auto statueDef = Statues::GetStatue(id);
		if (statueDef is null)
		{
			PrintError("Tried giving statue \"" + id + "\" level " + level + " but the statue does not exist!");
			return;
		}

		TownStatue@ statue = GetStatue(id);
		if (statue is null)
		{
			@statue = TownStatue();
			statue.m_id = id;
			m_statues.insertLast(statue);
		}

		if (level >= statue.m_level)
		{
			print("Received statue \"" + id + "\" level " + level);
			statue.m_level = level;
		}
	}

	TownStatue@ GetStatue(string id)
	{
		for (uint i = 0; i < m_statues.length(); i++)
		{
			if (m_statues[i].m_id == id)
				return m_statues[i];
		}
		return null;
	}

	array<TownStatue@> GetPlacedStatues()
	{
		array<TownStatue@> ret;
		for (uint i = 0; i < m_statuePlacements.length(); i++)
		{
			auto statue = GetStatue(m_statuePlacements[i]);
			if (statue !is null)
				ret.insertLast(statue);
		}
		return ret;
	}

	array<TownStatue@> GetStatues()
	{
		return m_statues;
	}
	
	int GetStatuePlacement(string id)
	{
		for (uint i = 0; i < m_statuePlacements.length(); i++)
		{
			if (m_statuePlacements[i] == id)
				return i;
		}
		return -1;
	}

	TownBuilding@ GetBuilding(string typeName)
	{
		for (uint i = 0; i < m_buildings.length(); i++)
		{
			if (m_buildings[i].m_typeName == typeName)
				return m_buildings[i];
		}
		return null;
	}

	array<Materials::Dye@> GetOwnedDyes(Materials::Category category)
	{
		array<Materials::Dye@> ret;

		for (uint i = 0; i < Materials::g_dyes.length(); i++)
		{
			auto dye = Materials::g_dyes[i];
			if (dye.m_default && dye.m_category == category)
				ret.insertLast(dye);
		}

		for (uint i = 0; i < m_dyes.length(); i++)
		{
			auto dye = m_dyes[i];
			if (dye.m_category == category)
				ret.insertLast(dye);
		}

		return ret;
	}

	bool OwnsDye(Materials::Dye@ dye)
	{
		return (dye.m_default || m_dyes.findByRef(dye) != -1);
	}

	bool OwnsTrail(PlayerTrails::TrailDef@ trail)
	{
		return m_trails.findByRef(trail) != -1;
	}

	bool OwnsFrame(PlayerFrame@ frame)
	{
		return m_frames.findByRef(frame) != -1;
	}

	bool OwnsComboStyle(PlayerComboStyle@ style)
	{
		if (style.m_owned)
			return true;

		return m_comboStyles.find(style.m_idHash) != -1;
	}

	bool OwnsGravestone(PlayerCorpseGravestone@ gravestone)
	{
		return m_gravestones.find(gravestone.m_idHash) != -1;
	}

	void GiveDye(Materials::Dye@ dye)
	{
		if (OwnsDye(dye))
		{
			PrintError("Town already owns dye with category " + int(dye.m_category) + " and ID \"" + dye.m_id + "\"");
			return;
		}

		m_dyes.insertLast(dye);
	}

	bool OwnsSurvivalBlueprint(Spectacular::BlueprintDef@ def)
	{
		return (m_survivalBlueprints.find(def.m_idHash) != -1);
	}

	void Save(SValueBuilder& builder, bool saveFlags)
	{
		if (Network::IsServer())
			m_currentNgp = int(float(g_ngp));

		Hooks::Call("TownRecordSave", @this, builder);

		builder.PushInteger("gold", max(0, m_gold));
		builder.PushInteger("ore", max(0, m_ore));
		builder.PushInteger("legacy-points", max(0, m_legacyPoints));

		builder.PushInteger("fountain-gold", max(0, m_fountainGold));

		builder.PushInteger("current-ngp", m_currentNgp);
		m_highestNgps.Save(builder, "highest-ngps");
		builder.PushInteger("last-gladiator-rank", m_lastGladiatorRank);

		builder.PushInteger("earned-legacy-points", m_earnedLegacyPoints);

		builder.PushDictionary("buildings");
		for (uint i = 0; i < m_buildings.length(); i++)
			m_buildings[i].Save(builder);
		builder.PopDictionary();

		builder.PushDictionary("statistics");
		m_statistics.Save(builder);
		builder.PopDictionary();

		builder.PushDictionary("statistics-mercenaries");
		m_statisticsMercenaries.Save(builder);
		builder.PopDictionary();

		builder.PushInteger("rep-presented", max(0, m_reputationPresented));

		builder.PushDictionary("statues");
		for (uint i = 0; i < m_statues.length(); i++)
			m_statues[i].Save(builder);
		builder.PopDictionary();

		builder.PushArray("statue-placements");
		for (uint i = 0; i < m_statuePlacements.length(); i++)
			builder.PushString(m_statuePlacements[i]);
		builder.PopArray();
		
		builder.PushArray("bestiary");
		for (uint i = 0; i < m_bestiary.length(); i++)
		{
			builder.PushArray();
			builder.PushInteger(m_bestiary[i].m_producer.GetResourceHash());
			builder.PushInteger(m_bestiary[i].m_kills);
			builder.PushInteger(m_bestiary[i].m_killer);
			builder.PopArray();
		}
		builder.PopArray();
		
		builder.PushArray("itemiary");
		for (uint i = 0; i < m_itemiary.length(); i++)
		{
			builder.PushInteger(m_itemiary[i].m_item.idHash);
			builder.PushInteger(m_itemiary[i].m_count);
		}
		builder.PopArray();
		
		builder.PushArray("tavern-drinks");
		for (uint i = 0; i < g_tavernDrinks.length(); i++)
		{
			if (g_tavernDrinks[i].localCount < 0)
				continue;
			
			builder.PushInteger(g_tavernDrinks[i].idHash);
			builder.PushInteger(g_tavernDrinks[i].localCount);
		}
		builder.PopArray();
		
		builder.PushArray("flags");
		//if (saveFlags)
		{
			for (uint i = 0; i < m_townFlags.length(); i++)
				builder.PushString(m_townFlags[i]);
		
			auto flagKeys = g_flags.m_flags.getKeys();
			for (uint i = 0; i < flagKeys.length(); i++)
			{
				int64 state;
				g_flags.m_flags.get(flagKeys[i], state);
				
				FlagState flag = FlagState(state);
				if (flag == FlagState::Town /* || flag == FlagState::TownAll || flag == FlagState::HostTown */)
					builder.PushString(flagKeys[i]);
			}
		}
		builder.PopArray();

		builder.PushArray("random");
		for (int i = 0; i < int(RandomContext::NumContexts); i++)
			builder.PushInteger(RandomBank::GetSeed(RandomContext(i)));
		builder.PopArray();

		builder.PushArray("bosses-killed");
		for (uint i = 0; i < m_bossesKilled.length(); i++)
			builder.PushInteger(int(m_bossesKilled[i]));
		builder.PopArray();

		builder.PushArray("forge-blueprints");
		for (uint i = 0; i < m_forgeBlueprints.length(); i++)
			builder.PushInteger(m_forgeBlueprints[i]);
		builder.PopArray();

		builder.PushArray("dyes");
		for (uint i = 0; i < m_dyes.length(); i++)
		{
			auto dye = m_dyes[i];
			if (dye.m_default)
				continue;

			builder.PushArray();
			builder.PushInteger(int(dye.m_category));
			builder.PushInteger(dye.m_idHash);
			builder.PopArray();
		}
		builder.PopArray();

		builder.PushArray("trails");
		for (uint i = 0; i < m_trails.length(); i++)
			builder.PushInteger(m_trails[i].m_idHash);
		builder.PopArray();

		builder.PushArray("frames");
		for (uint i = 0; i < m_frames.length(); i++)
			builder.PushInteger(m_frames[i].m_idHash);
		builder.PopArray();

		builder.PushArray("pet-skins");
		for (uint i = 0; i < m_petSkins.length(); i++)
			builder.PushInteger(m_petSkins[i]);
		builder.PopArray();

		builder.PushArray("combo-styles");
		for (uint i = 0; i < m_comboStyles.length(); i++)
			builder.PushInteger(m_comboStyles[i]);
		builder.PopArray();

		builder.PushArray("gravestones");
		for (uint i = 0; i < m_gravestones.length(); i++)
			builder.PushInteger(m_gravestones[i]);
		builder.PopArray();

		builder.PushArray("survival-blueprints");
		for (uint i = 0; i < m_survivalBlueprints.length(); i++)
			builder.PushInteger(int(m_survivalBlueprints[i]));
		builder.PopArray();

		if (Network::IsServer())
		{
			builder.PushArray("fountain-effects");
			for (uint i = 0; i < m_savedFountainEffects.length(); i++)
				builder.PushInteger(m_savedFountainEffects[i]);
			builder.PopArray();
		}

		builder.PushArray("fountain-presets");
		for (uint i = 0; i < m_fountainPresets.length(); i++)
			m_fountainPresets[i].Save(builder);
		builder.PopArray();
	}

	void Load(SValue@ sv)
	{
		if (sv is null)
			return;

		m_gold = GetParamInt(UnitPtr(), sv, "gold");
		m_ore = GetParamInt(UnitPtr(), sv, "ore");
		m_legacyPoints = GetParamInt(UnitPtr(), sv, "legacy-points", false);

		m_fountainGold = GetParamInt(UnitPtr(), sv, "fountain-gold", false);

		m_currentNgp = GetParamInt(UnitPtr(), sv, "current-ngp", false, -1);

		// Highest NGPs
		m_highestNgps.Load(sv, "highest-ngps", false);

		// Last gladiator rank
		m_lastGladiatorRank = GetParamInt(UnitPtr(), sv, "last-gladiator-rank", false, -1);

		// Earned legacy points
		auto svEarnedLegacyPoints = sv.GetDictionaryEntry("earned-legacy-points");
		if (svEarnedLegacyPoints !is null && svEarnedLegacyPoints.GetType() == SValueType::Integer)
			m_earnedLegacyPoints = svEarnedLegacyPoints.GetInteger();
		else
		{
			int totalPoints = 0;

			auto allChars = HwrSaves::GetCharacters();
			for (uint i = 0; i < allChars.length(); i++)
			{
				auto svChar = allChars[i];

				bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
				bool mercenaryLocked = GetParamBool(UnitPtr(), svChar, "mercenary-locked", false);
				if (!mercenary || !mercenaryLocked)
					continue;

				int legacyPoints = GetParamInt(UnitPtr(), svChar, "mercenary-points-reward", false);
				totalPoints += legacyPoints;
			}

			m_earnedLegacyPoints = totalPoints;
		}

		// Highest NGPs compatibility (different names as the character ones)
		int base_ngp = GetParamInt(UnitPtr(), sv, "highest-ngp", false, -1);
		int pop_ngp = GetParamInt(UnitPtr(), sv, "highest-dngp", false, -1);
		int mt_ngp = GetParamInt(UnitPtr(), sv, "highest-mngp", false, -1);

		if (base_ngp != -1)
			m_highestNgps.Get("base", true).SetBoth(base_ngp);
		if (pop_ngp != -1)
			m_highestNgps.Get("pop", true).SetBoth(pop_ngp);
		if (mt_ngp != -1)
			m_highestNgps.Get("mt", true).SetBoth(mt_ngp);

		{ // Make sure highest NGPs are set properly according to character list (very old save compatibility)
			auto allChars = HwrSaves::GetCharacters();
			array<DungeonNgpList@> allCharsNgps;
			for (uint i = 0; i < allChars.length(); i++)
			{
				auto svChar = allChars[i];
				auto newNgps = DungeonNgpList();
				newNgps.Load(svChar, "ngps");
				allCharsNgps.insertLast(newNgps);
			}

			for (uint i = 0; i < DungeonProperties::Instances.length(); i++)
			{
				auto dungeon = DungeonProperties::Instances[i];
				if (m_highestNgps.Has(dungeon.m_idHash))
					continue;

				int highestNgp = 0;
				for (uint j = 0; j < allCharsNgps.length(); j++)
				{
					int ngp = allCharsNgps[j][dungeon.m_idHash];
					if (ngp > highestNgp)
						highestNgp = ngp;
				}

				print("Setting initial town NGP for \"" + dungeon.m_id + "\": " + highestNgp);
				m_highestNgps.Get(dungeon.m_idHash, true).SetBoth(highestNgp);
			}
		}

		int highestBaseNgp = m_highestNgps["base"];
		if (m_currentNgp > highestBaseNgp)
			m_currentNgp = highestBaseNgp;
		if (m_currentNgp == -1)
			m_currentNgp = highestBaseNgp;

		auto dictBuildings = GetParamDictionary(UnitPtr(), sv, "buildings", false);
		if (dictBuildings !is null)
		{
			auto keys = dictBuildings.GetDictionary().getKeys();
			for (uint i = 0; i < keys.length(); i++)
			{
				TownBuilding@ building = GetBuilding(keys[i]);
				if (building is null)
				{
					PrintError("Couldn't load building type \"" + keys[i] + "\"");
					continue;
				}
				building.Load(dictBuildings.GetDictionaryEntry(keys[i]));
			}
		}

		auto dictStatistics = GetParamDictionary(UnitPtr(), sv, "statistics", false);
		if (dictStatistics !is null)
			m_statistics.Load(dictStatistics);

		auto dictStatisticsMercenaries = GetParamDictionary(UnitPtr(), sv, "statistics-mercenaries", false);
		if (dictStatisticsMercenaries !is null)
			m_statisticsMercenaries.Load(dictStatisticsMercenaries);

		m_reputationPresented = GetParamInt(UnitPtr(), sv, "rep-presented", false, GetReputation());

		auto dictStatues = GetParamDictionary(UnitPtr(), sv, "statues", false);
		if (dictStatues !is null)
		{
			auto keys = dictStatues.GetDictionary().getKeys();
			for (uint i = 0; i < keys.length(); i++)
			{
				auto statueDef = Statues::GetStatue(keys[i]);
				if (statueDef is null)
				{
					PrintError("Couldn't find statue with ID \"" + keys[i] + "\"");
					continue;
				}

				auto newStatue = TownStatue();
				newStatue.m_id = statueDef.m_id;
				newStatue.Load(dictStatues.GetDictionaryEntry(keys[i]));
				m_statues.insertLast(newStatue);
			}
		}

		for (uint i = 0; i < Statues::g_statues.length(); i++)
		{
			auto statueDef = Statues::g_statues[i];
			if (!statueDef.m_unlocked)
				continue;

			if (GetStatue(statueDef.m_id) is null)
			{
				auto newStatue = TownStatue();
				newStatue.m_id = statueDef.m_id;
				newStatue.m_level = 0;
				m_statues.insertLast(newStatue);
			}
		}

		auto arrPlacements = GetParamArray(UnitPtr(), sv, "statue-placements", false);
		if (arrPlacements !is null)
		{
			for (uint i = 0; i < arrPlacements.length(); i++)
			{
				TownStatue@ statue = GetStatue(arrPlacements[i].GetString());
				if (statue !is null)
					m_statuePlacements.insertLast(statue.m_id);
				else
					m_statuePlacements.insertLast("");
			}
		}
		
		auto arrBestiary = GetParamArray(UnitPtr(), sv, "bestiary", false);
		if (arrBestiary !is null && arrBestiary.length() > 0)
		{
			if (arrBestiary[0].GetType() == SValueType::Array)
			{
				for (uint i = 0; i < arrBestiary.length(); i++)
				{
					auto arrUnit = arrBestiary[i].GetArray();

					uint prodHash = uint(arrUnit[0].GetInteger());
					auto prod = Resources::GetUnitProducer(prodHash);
					if (prod is null)
						continue;

					int numKills = arrUnit[1].GetInteger();
					int numKiller = arrUnit[2].GetInteger();

					auto newEntry = BestiaryEntry(prod, numKills, numKiller);
					m_bestiary.insertLast(newEntry);
				}
			}
			else if (arrBestiary[0].GetType() == SValueType::Integer)
			{
				for (uint i = 0; i < arrBestiary.length(); i += 3)
				{
					uint prodHash = uint(arrBestiary[i].GetInteger());
					auto prod = Resources::GetUnitProducer(prodHash);
					if (prod is null)
						continue;

					int numKills = arrBestiary[i + 1].GetInteger();
					int numKiller = arrBestiary[i + 2].GetInteger();
					m_bestiary.insertLast(BestiaryEntry(prod, numKills, numKiller));
				}
			}
		}
		
		auto arrItemiary = GetParamArray(UnitPtr(), sv, "itemiary", false);
		if (arrItemiary !is null)
		{
			for (uint i = 0; i < arrItemiary.length(); i += 2)
			{
				auto item = g_items.GetItem(arrItemiary[i].GetInteger());
				if (item is null)
					continue;
			
				m_itemiary.insertLast(ItemiaryEntry(item, arrItemiary[i + 1].GetInteger()));
			}
		}
		
		auto arrTDrinks = GetParamArray(UnitPtr(), sv, "tavern-drinks", false);
		if (m_local && arrTDrinks !is null)
		{
			for (uint i = 0; i < arrTDrinks.length(); i += 2)
			{
				auto drink = GetTavernDrink(arrTDrinks[i].GetInteger());
				if (drink is null)
					continue;
			
				drink.localCount = arrTDrinks[i + 1].GetInteger();
			}
		}
		
		auto arrFlags = GetParamArray(UnitPtr(), sv, "flags", false);
		if (arrFlags !is null)
		{
			/*
			for (uint i = 0; i < arrFlags.length(); i++)
				m_townFlags.insertLast(arrFlags[i].GetString());
			*/
			auto flag = m_local ? FlagState::Town : FlagState::HostTown;
			for (uint i = 0; i < arrFlags.length(); i++)
				g_flags.Set(arrFlags[i].GetString(), flag);
		}

		auto arrRandom = GetParamArray(UnitPtr(), sv, "random", false);
		if (arrRandom !is null)
		{
			for (int i = 0; i < min(int(arrRandom.length()), int(RandomContext::NumContexts)); i++)
				RandomBank::SetSeed(RandomContext(i), arrRandom[i].GetInteger());
		}

		auto arrBossesKilled = GetParamArray(UnitPtr(), sv, "bosses-killed", false);
		if (arrBossesKilled !is null)
		{
			for (int i = 0; i < min(m_bossesKilled.length(), arrBossesKilled.length()); i++)
				m_bossesKilled[i] = uint(arrBossesKilled[i].GetInteger());
		}

		auto arrForgeBlueprints = GetParamArray(UnitPtr(), sv, "forge-blueprints", false);
		if (arrForgeBlueprints !is null)
		{
			for (uint i = 0; i < arrForgeBlueprints.length(); i++)
			{
				if (arrForgeBlueprints[i].GetType() != SValueType::Integer)
					continue;

				auto item = g_items.GetItem(arrForgeBlueprints[i].GetInteger());
				if (item is null || !item.hasBlueprints)
					continue;

				if (m_forgeBlueprints.find(item.idHash) != -1)
					continue;

				m_forgeBlueprints.insertLast(item.idHash);
			}
		}

		auto arrDyes = GetParamArray(UnitPtr(), sv, "dyes", false);
		if (arrDyes !is null)
		{
			for (uint i = 0; i < arrDyes.length(); i++)
			{
				auto arrDye = arrDyes[i].GetArray();

				Materials::Category category = Materials::Category(arrDye[0].GetInteger());
				uint id = uint(arrDye[1].GetInteger());

				auto dye = Materials::GetDye(category, id);

				if (dye is null)
				{
					PrintError("Couldn't find dye with category " + int(category) + " and ID " + id);
					continue;
				}

				if (dye.m_default)
					continue;

				m_dyes.insertLast(dye);
			}
		}

		auto arrTrails = GetParamArray(UnitPtr(), sv, "trails", false);
		if (arrTrails !is null)
		{
			for (uint i = 0; i < arrTrails.length(); i++)
			{
				uint id = uint(arrTrails[i].GetInteger());
				auto trail = PlayerTrails::GetTrail(id);

				if (trail is null)
				{
					PrintError("Couldn't find trail with ID " + id);
					continue;
				}

				m_trails.insertLast(trail);
			}
		}

		auto arrFrames = GetParamArray(UnitPtr(), sv, "frames", false);
		if (arrFrames !is null)
		{
			for (uint i = 0; i < arrFrames.length(); i++)
			{
				uint id = uint(arrFrames[i].GetInteger());
				auto frame = PlayerFrame::Get(id);

				if (frame is null)
				{
					PrintError("Couldn't find frame with ID " + id);
					continue;
				}

				m_frames.insertLast(frame);
			}
		}

		auto arrPetSkins = GetParamArray(UnitPtr(), sv, "pet-skins", false);
		if (arrPetSkins !is null)
		{
			for (uint i = 0; i < arrPetSkins.length(); i++)
				m_petSkins.insertLast(uint(arrPetSkins[i].GetInteger()));
		}

		auto arrComboStyles = GetParamArray(UnitPtr(), sv, "combo-styles", false);
		if (arrComboStyles !is null)
		{
			for (uint i = 0; i < arrComboStyles.length(); i++)
				m_comboStyles.insertLast(uint(arrComboStyles[i].GetInteger()));
		}

		auto arrGravestones = GetParamArray(UnitPtr(), sv, "gravestones", false);
		if (arrGravestones !is null)
		{
			for (uint i = 0; i < arrGravestones.length(); i++)
				m_gravestones.insertLast(uint(arrGravestones[i].GetInteger()));
		}

		auto arrSurvivalBlueprints = GetParamArray(UnitPtr(), sv, "survival-blueprints", false);
		if (arrSurvivalBlueprints !is null)
		{
			for (uint i = 0; i < arrSurvivalBlueprints.length(); i++)
				m_survivalBlueprints.insertLast(uint(arrSurvivalBlueprints[i].GetInteger()));
		}

		auto arrFountainEffects = GetParamArray(UnitPtr(), sv, "fountain-effects", false);
		if (arrFountainEffects !is null)
		{
			for (uint i = 0; i < arrFountainEffects.length(); i++)
				m_savedFountainEffects.insertLast(uint(arrFountainEffects[i].GetInteger()));
		}

		for (uint i = 0; i < m_fountainPresets.length(); i++)
			@m_fountainPresets[i] = FountainPreset();

		auto arrFountainPresets = GetParamArray(UnitPtr(), sv, "fountain-presets", false);
		if (arrFountainPresets !is null)
		{
			uint num = min(arrFountainPresets.length(), m_fountainPresets.length());
			for (uint i = 0; i < num; i++)
			{
				auto newPreset = FountainPreset();
				newPreset.Load(arrFountainPresets[i]);
				@m_fountainPresets[i] = newPreset;
			}
		}

		Hooks::Call("TownRecordLoad", @this, @sv);
	}
}
