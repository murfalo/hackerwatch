class DungeonSettingsMenu : ScriptWidgetHost
{
	TextWidget@ m_wNgp;
	SpriteButtonWidget@ m_wNgpLeft;
	SpriteButtonWidget@ m_wNgpRight;

	CheckBoxWidget@ m_wDownscaling;

	int m_lastNgp = -1;

	DungeonSettingsMenu(SValue& sval)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wNgp = cast<TextWidget>(m_widget.GetWidgetById("ngp"));
		@m_wNgpLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-left"));
		@m_wNgpRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-right"));

		@m_wDownscaling = cast<CheckBoxWidget>(m_widget.GetWidgetById("downscaling"));

		UpdateNgp();
	}

	float GetNgp()
	{
		return g_ngp;
	}

	int GetHighestNgp()
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (Network::IsServer())
			return gm.m_townLocal.m_highestNgps.GetHighest();
		else
			return gm.m_town.m_highestNgps.GetHighest();
	}

	void SetNgp(float ngp)
	{
		g_ngp = ngp;
	}

	void UpdateNgp()
	{
		bool isHost = Network::IsServer();

		float ngp = GetNgp();
		int highestNgp = GetHighestNgp();

		if (ngp > highestNgp)
		{
			ngp = highestNgp;
			SetNgp(ngp);
		}

		m_wNgp.SetText("+" + int(ngp));
		m_wNgpLeft.m_enabled = (isHost && int(ngp) > 0);
		m_wNgpRight.m_enabled = (isHost && int(ngp) < highestNgp);

		DoLayout();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Update(int dt) override
	{
		float ngp = GetNgp();

		if (m_lastNgp != int(ngp))
		{
			m_lastNgp = int(ngp);
			UpdateNgp();
		}

		m_wDownscaling.SetChecked(g_downscaling);
		m_wDownscaling.m_enabled = Network::IsServer();

		ScriptWidgetHost::Update(dt);
	}

	void OnNgpChanged()
	{
		float ngp = GetNgp();

		(Network::Message("SetNgp") << int(ngp)).SendToAll();

		if (Network::IsServer() && Lobby::IsInLobby())
		{
			SValueBuilder builder;
			builder.PushInteger(int(ngp));
			SendSystemMessage("SetNGP", builder.Build());
		}
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Stop();
		else if (name == "ngp-prev" && Network::IsServer())
		{
			float ngp = GetNgp();

			ngp = int(ngp) - 1;
			if (ngp < 0)
				ngp = 0;

			SetNgp(ngp);
			OnNgpChanged();
		}
		else if (name == "ngp-next" && Network::IsServer())
		{
			float ngp = GetNgp();

			ngp = int(ngp) + 1;

			int highestNgp = GetHighestNgp();
			if (int(ngp) > highestNgp)
				ngp = int(highestNgp);

			SetNgp(ngp);
			OnNgpChanged();
		}
		else if (name == "downscaling-changed" && Network::IsServer())
		{
			auto checkable = cast<ICheckableWidget>(sender);
			g_downscaling = checkable.IsChecked();

			(Network::Message("SetDownscaling") << g_downscaling).SendToAll();

			if (Lobby::IsInLobby())
			{
				SValueBuilder builder;
				builder.PushBoolean(g_downscaling);
				SendSystemMessage("SetDownscaling", builder.Build());
			}
		}
		else
			ScriptWidgetHost::OnFunc(sender, name);
	}
}
