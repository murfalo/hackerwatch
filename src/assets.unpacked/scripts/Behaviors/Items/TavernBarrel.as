class TavernBarrel : IUsable
{
	UnitPtr m_unit;

	TavernDrink@ m_drink;

	TavernBarrel(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	void SetQualityScene()
	{
		if (m_drink.quality == ActorItemQuality::Common)
			m_unit.SetUnitScene("common", false);
		else if (m_drink.quality == ActorItemQuality::Uncommon)
			m_unit.SetUnitScene("uncommon", false);
		else if (m_drink.quality == ActorItemQuality::Rare)
			m_unit.SetUnitScene("rare", false);
		else if (m_drink.quality == ActorItemQuality::Epic)
			m_unit.SetUnitScene("epic", false);
		else if (m_drink.quality == ActorItemQuality::Legendary)
			m_unit.SetUnitScene("legendary", false);
	}
	
	void Initialize(ActorItemQuality quality)
	{
		array<TavernDrink@> drinks;
		for (int i = 0; i < (3 + g_ngp); i++)
			drinks.insertLast(GetTavernDrink(quality));
		
		TavernDrink@ bestDrink = null;
		for (uint i = 0; i < drinks.length(); i++)
		{
			if (bestDrink is null || drinks[i].localCount < bestDrink.localCount)
				@bestDrink = drinks[i];
		}
		
		if (bestDrink !is null)
			Initialize(bestDrink);
		else
			Initialize(GetTavernDrink(quality));
	}

	void Initialize(TavernDrink@ drink)
	{
		@m_drink = drink;
		if (m_drink is null)
		{
			PrintError("Barrel was initialized with a null drink!");
			m_unit.Destroy();
			return;
		}
		SetQualityScene();
	}
	
	SValue@ Save()
	{
		if (m_drink is null)
			return null;

		SValueBuilder sval;
		sval.PushInteger(m_drink.idHash);
		return sval.Build();
	}
	
	void Load(SValue@ data)
	{
		uint drinkId = uint(data.GetInteger());

		TavernDrink@ drink = GetTavernDrink(drinkId);
		if (drink is null)
		{
			PrintError("Couldn't find drink with ID " + drinkId);
			m_unit.Destroy();
			return;
		}

		Initialize(drink);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		if (fxSelf.IsSensor())
			player.AddUsable(this);
	}

	void EndCollision(UnitPtr unit, Fixture@ fxSelf, Fixture@ fxOther)
	{
		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		if (fxSelf.IsSensor())
			player.RemoveUsable(this);
	}

	UnitPtr GetUseUnit()
	{
		return m_unit;
	}

	bool CanUse(PlayerBase@ player)
	{
		return true;
	}

	void Use(PlayerBase@ player)
	{
		m_unit.Destroy();
		GiveTavernBarrelImpl(m_drink, player, true);
	}

	void NetUse(PlayerHusk@ player)
	{
	}

	UsableIcon GetIcon(Player@ player)
	{
		return UsableIcon::Generic;
	}

	int UsePriority(IUsable@ other) { return 0; }
}

void GiveTavernBarrelImpl(TavernDrink@ drink, PlayerBase@ player, bool showFloatingText)
{
	if (player.IsHusk())
		return;
		
	if (drink is null)
		return;
	
	int mul = 1;
	auto gm = cast<Campaign>(g_gameMode);
	if (gm !is null)
		mul += gm.m_townLocal.GetBuilding("tavern").m_level;
		
	if (drink.localCount < 0)
		drink.localCount = 0;

	if (drink.quality == ActorItemQuality::Common)
		drink.localCount = min(mul * 8, drink.localCount + 6 + int(g_ngp / 2.0f));
	else if (drink.quality == ActorItemQuality::Uncommon)
		drink.localCount = min(mul * 6, drink.localCount + 5 + int(g_ngp / 3.0f));
	else if (drink.quality == ActorItemQuality::Rare)
		drink.localCount = min(mul * 4, drink.localCount + 4 + int(g_ngp / 4.0f));
	else if (drink.quality == ActorItemQuality::Epic)
		drink.localCount = min(mul * 1, drink.localCount + 1);
	else if (drink.quality == ActorItemQuality::Legendary)
		drink.localCount = min(mul * 1, drink.localCount + 1);

	Stats::Add("drinks-found", 1, player.m_record);

	/*
	Stats::Add("items-picked", 1, player.m_record);
	Stats::Add("items-picked-" + GetItemQualityName(item.quality), 1, player.m_record);
	Stats::Add("avg-items-picked", 1, player.m_record);

	auto gm = cast<Campaign>(g_gameMode);
	if (gm !is null)
	{
		ivec3 level = CalcLevel(gm.m_levelCount);
		Stats::Add("avg-items-picked-act-" + (level.x + 1), 1, player.m_record);
	}
	*/
	
	if (showFloatingText)
	{
		AddFloatingText(FloatingTextType::Pickup, Resources::GetString(drink.name), player.m_unit.GetPosition() + vec3(0, -5, 0));

		vec3 pos = player.m_unit.GetPosition();
		if (drink.quality == ActorItemQuality::Common)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_common"), pos);
		else if (drink.quality == ActorItemQuality::Uncommon)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_uncommon"), pos);
		else if (drink.quality == ActorItemQuality::Rare)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_rare"), pos);
		else if (drink.quality == ActorItemQuality::Epic)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_epic"), pos);
		else if (drink.quality == ActorItemQuality::Legendary)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_legendary"), pos);
	}
}