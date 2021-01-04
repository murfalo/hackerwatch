class DyeBucket : IUsable, IPreRenderable
{
	UnitPtr m_unit;

	Materials::Dye@ m_dye;
	Materials::IDyeState@ m_dyeState;

	DyeBucket(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushArray();
		sval.PushInteger(int(m_dye.m_category));
		sval.PushInteger(m_dye.m_idHash);
		sval.PopArray();
		return sval.Build();
	}

	void PostLoad(SValue@ data)
	{
		auto arr = data.GetArray();

		auto cat = Materials::Category(arr[0].GetInteger());
		uint id = uint(arr[1].GetInteger());

		auto dye = Materials::GetDye(cat, id);
		if (dye !is null)
			Initialize(dye);
		else
			m_unit.Destroy();
	}

	void Initialize(Materials::Dye@ dye)
	{
		@m_dye = dye;

		if (m_dye.m_quality == ActorItemQuality::Common)
			m_unit.SetUnitScene("common", false);
		else if (m_dye.m_quality == ActorItemQuality::Uncommon)
			m_unit.SetUnitScene("uncommon", false);
		else if (m_dye.m_quality == ActorItemQuality::Rare)
			m_unit.SetUnitScene("rare", false);

		m_preRenderables.insertLast(this);

		@m_dyeState = m_dye.MakeDyeState();
		UpdateColor(0);
	}

	void UpdateColor(int idt)
	{
		if (m_dye is null)
			return;

		array<vec4> color = m_dyeState.GetShades(idt);
		m_unit.SetMultiColor(0, color[0], color[1], color[2]);
	}

	void Update(int dt)
	{
		if (m_dyeState !is null)
			m_dyeState.Update(dt);
	}

	bool PreRender(int idt)
	{
		if (m_unit.IsDestroyed())
			return true;

		UpdateColor(idt);
		return false;
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
		GiveDyeImpl(m_dye, player, true);
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

void GiveDyeImpl(Materials::Dye@ dye, PlayerBase@ player, bool showFloatingText)
{
	if (player.IsHusk())
		return;

	if (dye is null)
		return;

	auto gm = cast<Campaign>(g_gameMode);
	gm.m_townLocal.GiveDye(dye);

	Stats::Add("dyes-found", 1, player.m_record);

	if (showFloatingText)
	{
		AddFloatingText(FloatingTextType::Pickup, Resources::GetString(dye.m_name), player.m_unit.GetPosition() + vec3(0, -5, 0));

		vec3 pos = player.m_unit.GetPosition();
		if (dye.m_quality == ActorItemQuality::Common)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_common"), pos);
		else if (dye.m_quality == ActorItemQuality::Uncommon)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_uncommon"), pos);
		else if (dye.m_quality == ActorItemQuality::Rare)
			PlaySound3D(Resources::GetSoundEvent("event:/item/item_rare"), pos);
	}
}
