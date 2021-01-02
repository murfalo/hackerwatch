class Item : IUsable
{
	UnitPtr m_unit;
	ActorItem@ m_item;

	ActorItemQuality m_quality;
	bool m_specific;
	bool m_initialized;

	Item(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_quality = ParseActorItemQuality(GetParamString(unit, params, "quality", false, "common"));
		m_specific = GetParamBool(unit, params, "specific", false, false);
	}

	void Update(int dt)
	{
		if (!m_initialized && !m_specific)
			Initialize(g_items.TakeRandomItem(m_quality));
	}
	
	void Initialize(ActorItem@ item)
	{
		m_initialized = true;

		if (item is null)
		{
			PrintError("Tried to initialize item with null!");
			DumpStack();
			return;
		}

		@m_item = item;

		auto currentUnitScene = m_unit.GetCurrentUnitScene();
		if (currentUnitScene.GetName() == "hidden")
			return;
		
		ScriptSprite@ sprite = m_item.iconScene;

		if (sprite.m_texture is null)
			PrintError("Item \"" + m_item.id + "\" is missing a texture for its scene sprite!");
		
		array<vec4> frames;
		array<int> frameTimes = { 100 };
		
		for (uint i = 0; i < sprite.m_frames.length(); i++)
			frames.insertLast(sprite.m_frames[i].frame);
		
		Material@ mat = GetQualityMaterial(item.quality);

		vec2 halfSize = vec2(
			sprite.GetWidth() / 2,
			sprite.GetHeight() / 2
		);
		
		CustomUnitScene unitScene;
		unitScene.AddScene(m_unit.GetUnitScene("shared"), 0, vec2(), 0, 0);
		unitScene.AddSprite(CustomUnitSprite(halfSize, sprite.m_texture, mat, frames, frameTimes, true, 0), 0, vec2(), 0, 0);
		
		m_unit.SetUnitScene(unitScene, false);
	}
	
	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushArray();
		sval.PushString(m_item.id);
		sval.PushString(m_unit.GetCurrentUnitScene().GetName());
		sval.PopArray();
		return sval.Build();
	}
	
	void PostLoad(SValue@ data)
	{
		if (data.GetType() == SValueType::Array)
		{
			auto arr = data.GetArray();
			Initialize(g_items.TakeItem(arr[0].GetString()));
			m_unit.SetUnitScene(arr[1].GetString(), false);
		}
		else if (data.GetType() == SValueType::String)
			Initialize(g_items.TakeItem(data.GetString()));

		if (m_item is null)
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
		GiveItemImpl(m_item, player, true);
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

void GiveItemImpl(ActorItem@ item, PlayerBase@ player, bool showFloatingText)
{
	player.AddItem(item);

	Stats::Add("items-picked", 1, player.m_record);
	Stats::Add("items-picked-" + GetItemQualityName(item.quality), 1, player.m_record);
	Stats::Add("avg-items-picked", 1, player.m_record);

	auto gm = cast<Campaign>(g_gameMode);
	if (gm !is null)
	{
		ivec3 level = CalcLevel(gm.m_levelCount);
		Stats::Add("avg-items-picked-act-" + (level.x + 1), 1, player.m_record);
	}

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
