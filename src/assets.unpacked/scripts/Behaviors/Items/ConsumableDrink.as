class ConsumableDrink : IUsable
{
	UnitPtr m_unit;
	TavernDrink@ m_drink;

	ConsumableDrink(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		auto quality = ParseActorItemQuality(GetParamString(unit, params, "quality", false, "common"));
		Initialize(TakeTavernDrink(quality));
	}

	void Initialize(TavernDrink@ drink)
	{
		if (drink is null)
		{
			PrintError("Initializing consumable drink with null");
			return;
		}

		@m_drink = drink;
	}

	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushInteger(m_drink.idHash);
		return sval.Build();
	}

	void PostLoad(SValue@ data)
	{
		if (data.GetType() == SValueType::Integer)
			Initialize(TakeTavernDrink(uint(data.GetInteger())));

		if (m_drink is null)
			m_unit.Destroy();
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
		ConsumeDrinkImpl(m_drink, player, true);
	}

	void NetUse(PlayerHusk@ player)
	{
	}

	UsableIcon GetIcon(Player@ player)
	{
		return UsableIcon::Generic;
	}

	int UsePriority(IUsable@ other) { return 1; }
}

void ConsumeDrinkImpl(TavernDrink@ drink, PlayerBase@ player, bool showFloatingText)
{
	player.AddDrink(drink);
	player.RefreshModifiers();

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
