class StatueBehavior : IUsable
{
	UnitPtr m_unit;

	WorldScript::SpawnTownStatue@ m_spawnScript;

	TownStatue@ m_statue;

	SpeechBubble@ m_currentBubble;
	int m_bubbleTime;

	StatueBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	}

	void Initialize(WorldScript::SpawnTownStatue@ spawnScript)
	{
		@m_spawnScript = spawnScript;
	}

	void SetStatue(TownStatue@ statue)
	{
		@m_statue = statue;
		UnitScene@ scene = null;

		if (statue is null)
			@scene = m_spawnScript.GetDefaultScene();
		else
			@scene = statue.GetDef().m_scene;

		if (scene !is null)
			m_unit.SetUnitScene(scene, true);
	}

	void Update(int dt)
	{
		if (m_bubbleTime > 0)
		{
			m_bubbleTime -= dt;
			if (m_bubbleTime <= 0)
				HideBubble();
		}
	}

	UnitPtr GetUseUnit() { return m_unit; }
	bool CanUse(PlayerBase@ player) { return m_statue !is null; }

	void Use(PlayerBase@ player)
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		if (m_currentBubble !is null)
			HideBubble();

		auto statueDef = m_statue.GetDef();

		string title = Resources::GetString(statueDef.m_name);
		string text = Resources::GetString(statueDef.m_useText);

		@m_currentBubble = gm.m_hud.m_speechBubbles.Show();
		m_currentBubble.SetStyle("gui/speechbubbles/stone.sval");
		m_currentBubble.SetText(title, text);
		m_currentBubble.m_unit = m_unit;//player.m_unit;
		m_currentBubble.m_offset.y = 0;//TODO?
		m_currentBubble.OnShown();

		m_bubbleTime = 5000;
	}

	void NetUse(PlayerHusk@ player)
	{
	}

	UsableIcon GetIcon(Player@ player)
	{
		if (!CanUse(player))
			return UsableIcon::None;
		return UsableIcon::Question;
	}

	int UsePriority(IUsable@ other) { return 0; }

	void HideBubble()
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		gm.m_hud.m_speechBubbles.Hide(m_currentBubble);
		@m_currentBubble = null;
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		auto player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		player.AddUsable(this);
	}

	void EndCollision(UnitPtr unit, Fixture@ fxSelf, Fixture@ fxOther)
	{
		auto player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		player.RemoveUsable(this);
	}
}
