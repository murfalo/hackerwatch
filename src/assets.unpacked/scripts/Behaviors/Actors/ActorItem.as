enum ActorItemQuality
{
	None = 0,
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5
}

class ActorItem
{
	string id;
	uint idHash;
	string name;
	string desc;
	ScriptSprite@ iconScene;
	ScriptSprite@ icon;
	ActorItemQuality quality;
	int cost;
	string requiredNgp;
	string requiredFlag;
	string blockedFlag;
	string dlc;
	bool buyInTown;
	bool buyInDungeon;
	bool hasBlueprints;
	bool canAttune;
	array<Modifiers::Modifier@> modifiers;
	bool inUse;
	ActorSet@ set;

	int opCmp(const ActorItem &in item)
	{
		if (int(quality) > int(item.quality))
			return 1;
		else if (int(quality) < int(item.quality))
			return -1;
		return 0;
	}
}

class ActorSet
{
	string name;
	array<ActorSetBonus@> bonuses;
}

class ActorSetBonus
{
	int num;
	string desc;
	array<Modifiers::Modifier@> modifiers;
}

Material@ GetQualityMaterial(ActorItemQuality quality)
{
	if (quality == ActorItemQuality::Common)
		return Resources::GetMaterial("items/items.mats:item-common");
	else if (quality == ActorItemQuality::Uncommon)
		return Resources::GetMaterial("items/items.mats:item-uncommon");
	else if (quality == ActorItemQuality::Rare)
		return Resources::GetMaterial("items/items.mats:item-rare");
	else if (quality == ActorItemQuality::Epic)
		return Resources::GetMaterial("items/items.mats:item-epic");
	else if (quality == ActorItemQuality::Legendary)
		return Resources::GetMaterial("items/items.mats:item-legendary");

	return null;
}

int GetItemAttuneCost(ActorItem@ item)
{
	// Skillpoints
	switch (item.quality)
	{
		case ActorItemQuality::Common: return 3;
		case ActorItemQuality::Uncommon: return 9;
		case ActorItemQuality::Rare: return 18;
		case ActorItemQuality::Epic: return 40;
		case ActorItemQuality::Legendary: return 100;
	}
	return 0;
}

int GetItemCraftCost(ActorItem@ item)
{
	// Ore
	int ret = 1000;
	switch (item.quality)
	{
		case ActorItemQuality::Common: ret = (item.set is null) ? 5 : 10; break;
		case ActorItemQuality::Uncommon: ret = (item.set is null) ? 10 : 20; break;
		case ActorItemQuality::Rare: ret = (item.set is null) ? 25 : 40; break;
		case ActorItemQuality::Epic: ret = 150; break;
		case ActorItemQuality::Legendary: ret = 1000; break;
	}

	// if (cast<Town>(g_gameMode) is null)
		// ret = int(ret * (1.0f + g_ngp * 0.2f));
		
	if (cast<Town>(g_gameMode) is null)
		ret = int(ret + g_ngp);

	return ret;
}

ActorItemQuality ParseActorItemQuality(string quality)
{
	if (quality == "legendary")
		return ActorItemQuality::Legendary;
	else if (quality == "epic")
		return ActorItemQuality::Epic;
	else if (quality == "rare")
		return ActorItemQuality::Rare;
	else if (quality == "uncommon")
		return ActorItemQuality::Uncommon;
	else
		return ActorItemQuality::Common;
}

string GetItemQualityName(ActorItemQuality quality)
{
	if (quality == ActorItemQuality::Common)
		return "common";
	else if (quality == ActorItemQuality::Uncommon)
		return "uncommon";
	else if (quality == ActorItemQuality::Rare)
		return "rare";
	else if (quality == ActorItemQuality::Epic)
		return "epic";
	else if (quality == ActorItemQuality::Legendary)
		return "legendary";
	return "";
}

string GetItemQualityNameFull(ActorItemQuality quality)
{
	return Resources::GetString(".quality." + GetItemQualityName(quality));
}

string SetItemColorString = "ffc800";

string GetItemQualityColorString(ActorItemQuality quality)
{
	if (quality == ActorItemQuality::Common)
		return "ffffff";
	else if (quality == ActorItemQuality::Uncommon)
		return "42ff00";
	else if (quality == ActorItemQuality::Rare)
		return "00c0ff";
	else if (quality == ActorItemQuality::Epic)
		return "ff00ff";
	else if (quality == ActorItemQuality::Legendary)
		return "ff2400";
	return "";
}

string GetItemSetColorString(PlayerRecord@ record, ActorItem@ item)
{
	if (item.set is null)
		return "";

	string ret = "\\c" + SetItemColorString + Resources::GetString(item.set.name);

	OwnedItemSet@ ownedSet = record.GetOwnedItemSet(item.set);
	if (ownedSet !is null)
		ret += " (" + ownedSet.m_count + ")\\d";

	for (uint i = 0; i < item.set.bonuses.length(); i++)
	{
		auto bonus = item.set.bonuses[i];

		ret += "\n  \\c";
		if (ownedSet !is null && ownedSet.IsBonusActive(bonus))
			ret += SetItemColorString;
		else
			ret += "7f7f7f";

		ret += bonus.num + ": " + Resources::GetString(bonus.desc) + "\\d";
	}

	return ret;
}

vec4 GetItemQualityColor(ActorItemQuality quality)
{
	return ParseColorRGBA("#" + GetItemQualityColorString(quality) + "ff");
}

vec4 GetItemQualityBackgroundColor(ActorItemQuality quality)
{
	return desaturate(GetItemQualityColor(quality));
}

void AddItemFile(SValue@ sval)
{
	g_items.AddItemFile(sval);
}

void AddSetFile(SValue@ sval)
{
	g_items.AddSetFile(sval);
}

class ActorItems
{
	array<ActorItem@> m_allItemsList;
	array<ActorSet@> m_sets;

	
	void Clear()
	{
		m_allItemsList.removeRange(0, m_allItemsList.length());
		m_sets.removeRange(0, m_sets.length());
	}	
	
	void AddSetFile(SValue@ sval)
	{
		auto setsData = sval.GetArray();
		if (setsData is null)
			return;

		for (uint i = 0; i < setsData.length(); i++)
		{
			auto setData = cast<SValue>(setsData[i]);
			
			ActorSet set;
			set.name = GetParamString(UnitPtr(), setData, "name", false, "unknown");
			
			array<SValue@>@ items = GetParamArray(UnitPtr(), setData, "items", true);
			for (uint j = 0; j < items.length(); j++)
			{
				auto item = GetItem(items[j].GetString());
				if (item !is null)
					@item.set = set;
				else
					PrintError("Couldn't find item '" + items[j].GetString() + "' for inclusion in a set");
			}
			
			for (uint j = 0; j < items.length(); j++)
			{
				auto bonusData = GetParamDictionary(UnitPtr(), setData, "" + (j + 1), false);
				if (bonusData is null)
					continue;
				
				ActorSetBonus bonus;
				bonus.num = j + 1;
				bonus.desc = GetParamString(UnitPtr(), bonusData, "desc", false, "unknown");
				bonus.modifiers = Modifiers::LoadModifiers(UnitPtr(), bonusData, "", Modifiers::SyncVerb::Set, m_sets.length());
				
				set.bonuses.insertLast(bonus);
			}
			
			m_sets.insertLast(set);			
		}
	}
	
	void AddItemFile(SValue@ sval)
	{
		auto itemsData = sval.GetDictionary();
		array<string>@ itemsKeys = itemsData.getKeys();

		for (uint i = 0; i < itemsKeys.length(); i++)
		{
			auto itemData = cast<SValue>(itemsData[itemsKeys[i]]);
			auto iconArray = GetParamArray(UnitPtr(), itemData, "icon", false);
			auto iconSceneArray = GetParamArray(UnitPtr(), itemData, "icon-scene", false);

			ActorItem@ aItem = ActorItem();
		
			aItem.id = itemsKeys[i];
			aItem.idHash = HashString(itemsKeys[i]);
			aItem.name = GetParamString(UnitPtr(), itemData, "name", false, "unknown");
			aItem.desc = GetParamString(UnitPtr(), itemData, "desc", false, "unknown");
			@aItem.icon = ScriptSprite(iconArray);
			if (iconSceneArray !is null)
				@aItem.iconScene = ScriptSprite(iconSceneArray);
			else
				@aItem.iconScene = aItem.icon;
			aItem.inUse = false;
			aItem.quality = ParseActorItemQuality(GetParamString(UnitPtr(), itemData, "quality", false, "common"));
			aItem.cost = GetParamInt(UnitPtr(), itemData, "cost", false, 0);
			aItem.requiredNgp = GetParamString(UnitPtr(), itemData, "required-ngp", false);
			aItem.requiredFlag = GetParamString(UnitPtr(), itemData, "required-flag", false);
			aItem.blockedFlag = GetParamString(UnitPtr(), itemData, "blocked-flag", false);
			aItem.dlc = GetParamString(UnitPtr(), itemData, "dlc", false);
			aItem.buyInTown = GetParamBool(UnitPtr(), itemData, "buy-in-town", false, true);
			aItem.buyInDungeon = GetParamBool(UnitPtr(), itemData, "buy-in-dungeon", false, true);
			aItem.hasBlueprints = GetParamBool(UnitPtr(), itemData, "has-blueprints", false, false);
			aItem.canAttune = GetParamBool(UnitPtr(), itemData, "can-attune", false, true);
			aItem.modifiers = Modifiers::LoadModifiers(UnitPtr(), itemData, "", Modifiers::SyncVerb::Item, aItem.idHash);
			
			m_allItemsList.insertLast(aItem);
		}
	}
	
	ActorItem@ TakeRandomItem(ActorItemQuality quality, bool mustNotBeInUse = true)
	{
		array<ActorItem@> matchingItems;

		auto record = GetLocalPlayerRecord();
		if (record is null)
		{
			PrintError("Warning: Local player record is null while taking random item! NGP-dependent items will not drop!");
			DumpStack();
		}

		for (uint i = 0; i < m_allItemsList.length(); i++)
		{
			auto item = m_allItemsList[i];
			if ((!mustNotBeInUse || !item.inUse) && item.quality == quality)
			{
				if (item.requiredNgp != "" && (record is null || record.ngps[item.requiredNgp] == 0))
					continue;

				if (item.requiredFlag != "" && !g_flags.IsSet(item.requiredFlag))
					continue;

				if (item.blockedFlag != "" && g_flags.IsSet(item.blockedFlag))
					continue;

				if (!HasDLC(item.dlc))
					continue;

				matchingItems.insertLast(item);
			}
		}

		if (matchingItems.length() == 0)
		{
			for (uint i = 0; i < m_allItemsList.length(); i++)
			{
				auto item = m_allItemsList[i];
				if (item.quality == quality && item.requiredNgp == "" && item.requiredFlag == "" && item.blockedFlag == "")
					matchingItems.insertLast(item);
			}
		}

		if (matchingItems.length() == 0)
		{
			if (quality > ActorItemQuality::Common)
				return TakeRandomItem(ActorItemQuality(quality - 1), mustNotBeInUse);
			return null;
		}

		auto item = matchingItems[randi(matchingItems.length())];
		if (mustNotBeInUse)
			item.inUse = true;
		
		return item;
	}

	ActorItem@ TakeItem(string id)
	{
		ActorItem@ item = GetItem(HashString(id));
		if (item is null)
		{
			PrintError("Couldn't find item with ID \"" + id + "\"");
			return null;
		}
		
		item.inUse = true;
		return item;
	}
	
	ActorItem@ GetItem(string id)
	{
		return GetItem(HashString(id));
	}
	
	ActorItem@ GetItem(uint idHash)
	{
		for (uint i = 0; i < m_allItemsList.length(); i++)
		{
			if (m_allItemsList[i].idHash == idHash)
				return m_allItemsList[i];
		}
		
		return null;
	}
}

ActorItems g_items;
