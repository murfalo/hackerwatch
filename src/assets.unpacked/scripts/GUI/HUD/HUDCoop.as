class CoopPlayerWidget : RectWidget
{
	HUDCoop@ m_hudCoop;

	PlayerRecord@ m_record;

	PortraitWidget@ m_wPortrait;
	BarWidget@ m_wHealth;
	BarWidget@ m_wMana;
	Widget@ m_wIconDead;
	SpriteWidget@ m_wIconSoulLink;
	SpriteWidget@ m_wTriangle;

	int m_lastSoulLink = -1;

	CoopPlayerWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		RectWidget::Load(ctx);
	}

	void SetPeer(PlayerRecord@ record)
	{
		@m_record = record;

		vec4 color = ParseColorRGBA("#" + GetPlayerColor(m_record.peer) + "ff");

		@m_wPortrait = cast<PortraitWidget>(GetWidgetById("portrait"));
		@m_wHealth = cast<BarWidget>(GetWidgetById("health"));
		@m_wMana = cast<BarWidget>(GetWidgetById("mana"));
		@m_wIconDead = GetWidgetById("dead");
		@m_wIconSoulLink = cast<SpriteWidget>(GetWidgetById("soullink"));
		@m_wTriangle = cast<SpriteWidget>(GetWidgetById("triangle"));

		m_wPortrait.BindRecord(m_record);

		m_wTriangle.m_color = color;
	}

	void Update(int dt) override
	{
		RectWidget::Update(dt);

		if (m_record is null || m_record.peer == 255)
		{
			bool haveToLayout = false;
			if (m_visible)
				haveToLayout = true;
			m_visible = false;
			if (haveToLayout)
				m_host.Invalidate();
			return;
		}
		else if (m_record !is null && m_record.peer != 255)
			m_visible = true;

		bool isDead = m_record.IsDead();

		m_wIconDead.m_visible = isDead;
		m_wIconSoulLink.m_visible = (!isDead && m_record.soulLinkedBy != -1);
		if (!isDead && m_lastSoulLink != m_record.soulLinkedBy)
		{
			m_lastSoulLink = m_record.soulLinkedBy;
			m_wIconSoulLink.m_color = ParseColorRGBA("#" + GetPlayerColor(m_record.soulLinkedBy) + "ff");
		}
		m_wPortrait.m_colorize = isDead;

		if (isDead)
		{
			m_wHealth.SetScale(0.0f);
			m_wMana.SetScale(0.0f);
			return;
		}

		if (m_wHealth !is null)
			m_wHealth.SetScale(m_record.hp);

		if (m_wMana !is null)
		{
			m_wMana.m_visible = m_hudCoop.m_showMana;
			m_wMana.SetScale(m_record.mana);
		}
	}

	Widget@ Clone() override
	{
		CoopPlayerWidget@ w = CoopPlayerWidget();
		CloneInto(w);
		return w;
	}
}

ref@ LoadCoopPlayerWidget(WidgetLoadingContext &ctx)
{
	CoopPlayerWidget@ w = CoopPlayerWidget();
	w.Load(ctx);
	return w;
}

class HUDCoop : IWidgetHoster
{
	Widget@ m_wPlayerList;
	Widget@ m_wPlayerTemplate;
	Widget@ m_wSeparatorTemplate;

	array<CoopPlayerWidget@> m_players;

	bool m_localPlayerAdded;

	bool m_showMana;

	HUDCoop(GUIBuilder@ b)
	{
		LoadWidget(b, "gui/hud/coop.gui");

		@m_wPlayerList = m_widget.GetWidgetById("playerlist");
		@m_wPlayerTemplate = m_widget.GetWidgetById("playerlist-template");
		@m_wSeparatorTemplate = m_widget.GetWidgetById("separator-template");
	}

	CoopPlayerWidget@ GetPlayer(uint8 peer)
	{
		for (uint i = 0; i < m_wPlayerList.m_children.length(); i++)
		{
			auto wPlayer = cast<CoopPlayerWidget>(m_wPlayerList.m_children[i]);
			if (wPlayer is null)
				continue;

			if (wPlayer.m_record.peer == peer)
				return wPlayer;
		}
		return null;
	}

	bool ShouldShow()
	{
		if (!GetVarBool("ui_hud_coop"))
			return false;

		if (!GetVarBool("ui_hud_coop_forced"))
		{
			if (!Lobby::IsInLobby())
				return false;
		}

		if (g_players.length() > 4)
			return false;

		return true;
	}

	void Update(int dt) override
	{
		if (!ShouldShow())
			return;

		IWidgetHoster::Update(dt);

		m_showMana = GetVarBool("ui_show_mp_mana");

		if (!m_localPlayerAdded)
		{
			auto localPlayer = GetLocalPlayerRecord();
			if (localPlayer !is null)
			{
				m_localPlayerAdded = true;

				// Add local player
				CoopPlayerWidget@ wNewLocalPlayer = cast<CoopPlayerWidget>(m_wPlayerTemplate.Clone());
				wNewLocalPlayer.SetID("");
				wNewLocalPlayer.m_visible = true;
				@wNewLocalPlayer.m_hudCoop = this;
				wNewLocalPlayer.SetPeer(GetLocalPlayerRecord());
				m_wPlayerList.AddChild(wNewLocalPlayer);

				// Add separator
				auto wNewSeparator = m_wSeparatorTemplate.Clone();
				wNewSeparator.SetID("");
				wNewSeparator.m_visible = true;
				m_wPlayerList.AddChild(wNewSeparator);
			}
			else
				return;
		}

		// Check for new players
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (i >= m_players.length())
			{
				CoopPlayerWidget@ wNewPlayer = cast<CoopPlayerWidget>(m_wPlayerTemplate.Clone());
				wNewPlayer.SetID("");
				wNewPlayer.m_visible = true;
				@wNewPlayer.m_hudCoop = this;
				wNewPlayer.SetPeer(g_players[i]);
				if (!g_players[i].local)
					m_wPlayerList.AddChild(wNewPlayer);
				m_players.insertLast(wNewPlayer);
			}
			else if (m_players[i].m_record !is g_players[i])
				m_players[i].SetPeer(g_players[i]);
		}
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (!ShouldShow())
			return;

		IWidgetHoster::Draw(sb, idt);
	}
}
