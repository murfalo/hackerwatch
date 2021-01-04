class ForgeBlueprint : IUsable
{
	UnitPtr m_unit;

	ActorItem@ m_item;

	ForgeBlueprint(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	void Initialize(ActorItem@ item)
	{
		if (item is null)
			return;
	
		@m_item = item;

		UnitScene@ scrollScene;

		if (item.quality == ActorItemQuality::Common)
			@scrollScene = m_unit.GetUnitScene("common");
		else if (item.quality == ActorItemQuality::Uncommon)
			@scrollScene = m_unit.GetUnitScene("uncommon");
		else if (item.quality == ActorItemQuality::Rare)
			@scrollScene = m_unit.GetUnitScene("rare");
		else if (item.quality == ActorItemQuality::Epic)
			@scrollScene = m_unit.GetUnitScene("epic");
		else if (item.quality == ActorItemQuality::Legendary)
			@scrollScene = m_unit.GetUnitScene("legendary");

		ScriptSprite@ sprite = m_item.icon;

		if (sprite.m_texture is null)
			PrintError("Item \"" + m_item.id + "\" is missing a texture for its icon sprite!");

		array<vec4> frames;
		for (uint i = 0; i < sprite.m_frames.length(); i++)
			frames.insertLast(sprite.m_frames[i].frame);

		CustomUnitScene unitScene;
		unitScene.AddScene(scrollScene, 0, vec2(), 0, 0);
		unitScene.AddSprite(CustomUnitSprite(vec2(6, 6), sprite.m_texture, Resources::GetMaterial("system/default.mats:proj-prop"), frames, { 100 }, true, 0), 0, vec2(0, -1), 0, 0);

		m_unit.SetUnitScene(unitScene, false);
	}

	SValue@ Save()
	{
		if (m_item is null)
			return null;

		SValueBuilder sval;
		sval.PushInteger(m_item.idHash);
		return sval.Build();
	}

	void Load(SValue@ data)
	{
		Initialize(g_items.GetItem(uint(data.GetInteger())));
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
		GiveForgeBlueprintImpl(m_item, player, true);
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

void GiveForgeBlueprintImpl(ActorItem@ item, PlayerBase@ player, bool showFloatingText)
{
	if (cast<Player>(player) is null)
		return;

	auto gm = cast<Campaign>(g_gameMode);
	if (cast<Player>(player) !is null)
		gm.m_townLocal.m_forgeBlueprints.insertLast(item.idHash);

	Stats::Add("blueprints-found", 1, player.m_record);

	if (showFloatingText)
	{
		AddFloatingText(FloatingTextType::Pickup, Resources::GetString(item.name), player.m_unit.GetPosition() + vec3(0, -5, 0));

		vec3 pos = player.m_unit.GetPosition();
		if (item.quality == ActorItemQuality::Common)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_common"), pos);
		else if (item.quality == ActorItemQuality::Uncommon)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_uncommon"), pos);
		else if (item.quality == ActorItemQuality::Rare)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_rare"), pos);
		else if (item.quality == ActorItemQuality::Epic)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_epic"), pos);
		else if (item.quality == ActorItemQuality::Legendary)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_legendary"), pos);
	}
}
