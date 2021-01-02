class TavernDrink
{
	string id;
	uint idHash;
	string name;
	string desc;
	ScriptSprite@ icon;
	ActorItemQuality quality;
	int cost;
	bool unlocked;
	string dlc;

	bool inUse;

	ActorBuffDef@ buff;
	array<Modifiers::Modifier@> modifiers;
	
	int localCount;
	
	int opCmp(const TavernDrink &other)
	{
		if (quality > other.quality)
			return -1;
		else if (quality < other.quality)
			return 1;

		//TODO: Compare the translated strings instead of the keys?
		if (name < other.name)
			return -1;
		else if (name > other.name)
			return 1;

		return 0;
	}
}

TavernDrink@ GetTavernDrink(ActorItemQuality quality)
{
	array<TavernDrink@> availableDrinks;

	int start = -1;
	int end = -1;

	for (uint i = 0; i < g_tavernDrinks.length(); i++)
	{
		auto drink = g_tavernDrinks[i];

		if (drink.quality == quality && start < 0)
			start = i;
		if (drink.quality != quality && start >= 0 && end < 0)
			end = i;

		if (drink.quality != quality)
			continue;

		if (drink.inUse)
			continue;

		if (!HasDLC(drink.dlc))
			continue;

		availableDrinks.insertLast(drink);
	}

	if (availableDrinks.length() > 0)
		return availableDrinks[randi(availableDrinks.length())];

	if (g_tavernDrinks.length() > 0)
		return g_tavernDrinks[randi(end - start) + start];

	return null;
}

TavernDrink@ TakeTavernDrink(ActorItemQuality quality)
{
	auto ret = GetTavernDrink(quality);
	ret.inUse = true;
	return ret;
}

TavernDrink@ GetTavernDrink(uint idHash)
{
	for (uint i = 0; i < g_tavernDrinks.length(); i++)
	{
		if (g_tavernDrinks[i].idHash == idHash)
			return g_tavernDrinks[i];
	}
	
	return null;
}

TavernDrink@ TakeTavernDrink(uint idHash)
{
	for (uint i = 0; i < g_tavernDrinks.length(); i++)
	{
		auto drink = g_tavernDrinks[i];
		if (drink.idHash == idHash)
		{
			drink.inUse = true;
			return drink;
		}
	}

	return null;
}
	
void AddDrinkFile(SValue@ sval)
{
	auto drinksData = sval.GetDictionary();
	array<string>@ drinksKeys = drinksData.getKeys();

	for (uint i = 0; i < drinksKeys.length(); i++)
	{
		auto drinkData = cast<SValue>(drinksData[drinksKeys[i]]);
		auto iconArray = GetParamArray(UnitPtr(), drinkData, "icon", false);

		TavernDrink@ tDrink = TavernDrink();
	
		tDrink.id = drinksKeys[i];
		tDrink.idHash = HashString(drinksKeys[i]);
		tDrink.name = GetParamString(UnitPtr(), drinkData, "name", false, "unknown");
		tDrink.desc = GetParamString(UnitPtr(), drinkData, "desc", false, "unknown");
		@tDrink.icon = ScriptSprite(iconArray);
		tDrink.quality = ParseActorItemQuality(GetParamString(UnitPtr(), drinkData, "quality", false, "common"));
		tDrink.cost = GetParamInt(UnitPtr(), drinkData, "cost", false, 0);
		tDrink.unlocked = GetParamBool(UnitPtr(), drinkData, "unlocked", false, false);
		tDrink.dlc = GetParamString(UnitPtr(), drinkData, "dlc", false);
		
		@tDrink.buff = LoadActorBuff(GetParamString(UnitPtr(), drinkData, "buff", false));
		tDrink.modifiers = Modifiers::LoadModifiers(UnitPtr(), drinkData, "", Modifiers::SyncVerb::Drink, tDrink.idHash);
		
		tDrink.localCount = -1;
		
		g_tavernDrinks.insertLast(tDrink);
	}
	
	g_tavernDrinks.sortDesc();
}


array<TavernDrink@> g_tavernDrinks;