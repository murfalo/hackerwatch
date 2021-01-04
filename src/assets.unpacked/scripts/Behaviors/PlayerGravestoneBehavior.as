class PlayerGravestoneBehavior : IUsable
{
	UnitPtr m_unit;

	bool m_initialized;

	string m_charName;
	string m_charClass;
	int m_charLevel;
	int m_charLegacyPoints;

	Stats::StatList@ m_charLifetimeStats;

	DungeonProperties@ m_diedDungeon;
	int m_diedLevel;

	uint m_charFrame;
	int m_charFace;
	array<Materials::Dye@> m_charDyes;

	int m_titleIndex;

	PlayerGravestoneBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	void Initialize(SValue@ svChar)
	{
		m_initialized = true;

		m_charName = GetParamString(UnitPtr(), svChar, "name");
		m_charClass = GetParamString(UnitPtr(), svChar, "class");
		m_charLevel = GetParamInt(UnitPtr(), svChar, "level");
		m_charLegacyPoints = GetParamInt(UnitPtr(), svChar, "mercenary-points-reward");

		@m_charLifetimeStats = Stats::LoadList("tweak/stats.sval");
		auto svStats = svChar.GetDictionaryEntry("statistics");
		if (svStats !is null)
			m_charLifetimeStats.Load(svStats);

		@m_diedDungeon = DungeonProperties::Get(GetParamString(UnitPtr(), svChar, "mercenary-died-dungeon"));
		m_diedLevel = GetParamInt(UnitPtr(), svChar, "mercenary-died-level");

		m_charFrame = uint(GetParamInt(UnitPtr(), svChar, "current-frame", false, HashString("default")));
		m_charFace = GetParamInt(UnitPtr(), svChar, "face");
		m_charDyes = Materials::DyesFromSval(svChar);

		m_titleIndex = g_classTitles.m_titlesMercenary.GetTitleIndexFromPoints(m_charLegacyPoints);

		m_unit.SetUnitScene("" + (m_titleIndex + 1), true);

		if (Network::IsServer())
			(Network::Message("SpawnTownGravestone") << m_unit << Save()).SendToAll();
	}

	SValue@ Save()
	{
		if (!m_initialized)
			return null;

		SValueBuilder builder;
		builder.PushDictionary();

		builder.PushString("name", m_charName);
		builder.PushString("class", m_charClass);
		builder.PushInteger("level", m_charLevel);
		builder.PushInteger("mercenary-points-reward", m_charLegacyPoints);

		builder.PushDictionary("statistics");
		m_charLifetimeStats.Save(builder);
		builder.PopDictionary();

		if (m_diedDungeon !is null)
			builder.PushString("mercenary-died-dungeon", m_diedDungeon.m_id);
		builder.PushInteger("mercenary-died-level", m_diedLevel);

		builder.PushInteger("current-frame", int(m_charFrame));
		builder.PushInteger("face", m_charFace);
		builder.PushArray("colors");
		for (uint i = 0; i < m_charDyes.length(); i++)
		{
			auto dye = m_charDyes[i];

			builder.PushArray();
			builder.PushInteger(int(dye.m_category));
			builder.PushInteger(dye.m_idHash);
			builder.PopArray();
		}
		builder.PopArray();

		builder.PopDictionary();
		return builder.Build();
	}

	void Load(SValue@ save)
	{
		if (!Network::IsServer())
			Initialize(save);
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
		auto gm = cast<Town>(g_gameMode);
		gm.m_gravestoneInterface.Show();
		gm.m_gravestoneInterface.Set(this);
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
