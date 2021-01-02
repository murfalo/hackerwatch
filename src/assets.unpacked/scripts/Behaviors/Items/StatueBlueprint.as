class StatueBlueprint : IUsable
{
	UnitPtr m_unit;
	Statues::StatueDef@ m_statueDef;

	StatueBlueprint(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	void Initialize(Statues::StatueDef@ statue)
	{
		if (statue is null)
			return;

		@m_statueDef = statue;
		m_unit.SetUnitScene(statue.m_id, true);
	}

	SValue@ Save()
	{
		if (m_statueDef is null)
			return null;

		SValueBuilder sval;
		sval.PushString(m_statueDef.m_id);
		return sval.Build();
	}

	void Load(SValue@ data)
	{
		Initialize(Statues::GetStatue(data.GetString()));
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
		if (m_statueDef is null)
			return false;
	
		return true;
	}

	void Use(PlayerBase@ player)
	{
		if (m_statueDef is null)
			return;
	
		m_unit.Destroy();

		auto gm = cast<Campaign>(g_gameMode);

		// Ensure that the statue level 0 is unlocked in town
		gm.m_townLocal.GiveStatue(m_statueDef.m_id, 0);

		// Get the statue and add a blueprint
		auto statue = gm.m_townLocal.GetStatue(m_statueDef.m_id);
		statue.m_blueprint++;

		vec3 pos = player.m_unit.GetPosition();

		Stats::Add("statue-blueprints-found", 1, player.m_record);
		PlaySound3D(Resources::GetSoundEvent("event:/item/item_rare"), pos);
		
		@m_statueDef = null;
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
