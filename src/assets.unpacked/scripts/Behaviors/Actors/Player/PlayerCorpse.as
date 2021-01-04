class PlayerCorpse : IUsable, IPreRenderable
{
	UnitPtr m_unit;
	PlayerRecord@ m_record;
	CustomUnitScene@ m_unitScene;
	EffectParams@ m_effectParams;

	array<Materials::IDyeState@> m_dyeStates;

	PlayerCorpseGravestone@ m_gravestone;
	int m_timeGravestone;
	bool m_changedToGravestone;

	UnitScene@ m_fxGravestoneTransition;

	PlayerCorpse(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		@m_unitScene = CustomUnitScene();
		@m_effectParams = m_unit.CreateEffectParams();

		@m_fxGravestoneTransition = Resources::GetEffect("effects/animations/dust_blue.effect");
	}

	void Initialize(PlayerRecord@ record)
	{
		@m_record = record;
		
		m_unitScene.Clear();
		m_unitScene.AddScene(m_unit.GetUnitScene("death"), 0, vec2(), 0, 0);
		auto body = Resources::GetUnitProducer("players/" + m_record.charClass + ".unit");
		m_unitScene.AddScene(body.GetUnitScene("death"), 0, vec2(), 0, 0);
		m_unit.SetUnitScene(m_unitScene, true);

		@m_gravestone = PlayerCorpseGravestone::Get(record.currentCorpse);
		if (m_gravestone !is null)
			m_timeGravestone = m_unitScene.Length();

		m_dyeStates = Materials::MakeDyeStates(m_record);
		for (uint i = 0; i < m_dyeStates.length(); i++)
			SetShades(i, m_dyeStates[i].GetShades(0));

		auto color = ParseColorRGBA("#" + GetPlayerColor(m_record.peer) + "ff");
		m_effectParams.Set("color_r", color.r);
		m_effectParams.Set("color_g", color.g);
		m_effectParams.Set("color_b", color.b);

		m_preRenderables.insertLast(this);
	}
	
	void SetShades(int c, array<vec4> shades)
	{
		m_unit.SetMultiColor(c, shades[0], shades[1], shades[2]);
	}

	void NetUse(PlayerHusk@ player) { }
	UnitPtr GetUseUnit() { return m_unit; }
	bool CanUse(PlayerBase@ player) { return true; }
	UsableIcon GetIcon(Player@ player) { return UsableIcon::Revive; }
	int UsePriority(IUsable@ other) { return -1; }

	void Use(PlayerBase@ player) 
	{
		(Network::Message("ReviveCorpse") << m_record.peer).SendToAll();
		NetRevive(GetLocalPlayerRecord());
	}
	
	void NetRevive(PlayerRecord@ reviver, bool overridePosUsed = false, vec3 overridePos = vec3())
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		if (m_record.local)
			gm.StopSpectating();

%if HARDCORE
		if (!g_isTown)
		{
			m_record.mercenaryLocked = false;
			print("Unlocked Mercenary - Revive");
		}
%endif

		// Reviver is ourselves when using revive cheat
		if (!g_isTown && reviver !is null && reviver !is m_record)
		{
			int soulLinkOrigin = m_record.soulLinkedBy;
			if (soulLinkOrigin == -1)
				soulLinkOrigin = reviver.soulLinkedBy;
			if (soulLinkOrigin == -1)
				soulLinkOrigin = reviver.peer;

			m_record.soulLinks.insertLast(reviver.peer);
			m_record.soulLinkedBy = soulLinkOrigin;

			reviver.soulLinks.insertLast(m_record.peer);
			reviver.soulLinkedBy = soulLinkOrigin;
			reviver.hp *= 0.5;
		}

		SValueBuilder builder;
		if (reviver !is null)
		{
			builder.PushString(Resources::GetString(".menu.lobby.chat.revive", { 
				{ "reviver", "\\c" + GetPlayerColor(reviver.peer) + gm.GetPlayerDisplayName(reviver, false) + "\\d" },
				{ "revivee", "\\c" + GetPlayerColor(m_record.peer) + gm.GetPlayerDisplayName(m_record, false) + "\\d" }
			}));
		}
		else
		{
			builder.PushString(Resources::GetString(".menu.lobby.chat.revive.free", {
				{ "revivee", "\\c" + GetPlayerColor(m_record.peer) + gm.GetPlayerDisplayName(m_record, false) + "\\d" }
			}));
		}
		
		SendSystemMessage("AddChat", builder.Build());

		vec3 pos = m_unit.GetPosition();
		if (overridePosUsed)
			pos = overridePos;

		if (!g_isTown && reviver !is null)
			AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".misc.soulslinked"), pos);

		PlayEffect("effects/players/revive.effect", xy(pos));

		m_record.hp = 0.5;
		m_record.mana = 0.5;
	
		if (Network::IsServer())
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (m_record !is g_players[i])
					continue;

				g_gameMode.SpawnPlayer(i, xy(pos));
			}
		}
		
		m_unit.Destroy();
	}
	
	void Destroyed()
	{
		if (m_record.corpse is this)
			@m_record.corpse = null;
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

	void Update(int dt)
	{
		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_dyeStates[i].Update(dt);

		if (m_timeGravestone > 0)
		{
			m_timeGravestone -= dt;
			if (m_timeGravestone <= 0)
			{
				m_unit.DisableMultiColor();
				m_changedToGravestone = true;

				m_unitScene.Clear();
				m_unitScene.AddScene(m_unit.GetUnitScene("shared"), 0, vec2(), 0, 0);
				m_unitScene.AddScene(m_gravestone.GetScene(), 0, vec2(), 0, 0);
				m_unit.SetUnitScene(m_unitScene, true);

				PlayEffect(m_fxGravestoneTransition, m_unit);
			}
		}
	}

	bool PreRender(int idt)
	{
		if (m_unit.IsDestroyed())
			return true;

		if (!m_changedToGravestone)
		{
			for (uint i = 0; i < m_dyeStates.length(); i++)
				SetShades(i, m_dyeStates[i].GetShades(idt));
		}

		return false;
	}
}
