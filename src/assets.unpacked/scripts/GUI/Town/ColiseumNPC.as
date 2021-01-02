class ColiseumNPC : ScriptWidgetHost
{
	Widget@ m_wContentMain;
	Widget@ m_wContentTrials;
	Widget@ m_wContentSpectacular;

	SpriteButtonWidget@ m_wButtonLeft;
	SpriteButtonWidget@ m_wButtonRight;
	TextWidget@ m_wRating;

	int m_startRating;

	array<SpriteWidget@> m_arrProgress;

	ColiseumSwitchesDialog@ m_switches;

	ColiseumNPC(SValue& params)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wContentMain = m_widget.GetWidgetById("main");
		@m_wContentTrials = m_widget.GetWidgetById("trials");
		@m_wContentSpectacular = m_widget.GetWidgetById("spectacular");

		@m_wButtonLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("g-rating-left"));
		@m_wButtonRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("g-rating-right"));
		@m_wRating = cast<TextWidget>(m_widget.GetWidgetById("g-rating"));

		auto wButtonStart = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("start-button"));
		if (wButtonStart !is null)
			wButtonStart.m_enabled = Network::IsServer();

		auto wButtonSwitches = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("switches-button"));
		if (wButtonSwitches !is null)
			wButtonSwitches.m_enabled = Network::IsServer();

		int progressNumber = 1;
		while (true)
		{
			auto sprite = cast<SpriteWidget>(m_widget.GetWidgetById("progress-" + progressNumber));
			if (sprite is null)
				break;
			m_arrProgress.insertLast(sprite);
			progressNumber++;
		}

		auto gm = cast<Campaign>(g_gameMode);
		m_startRating = gm.m_townLocal.m_lastGladiatorRank;
		if (m_startRating == -1)
			m_startRating = GetMaxRating();
		else
			m_startRating = min(m_startRating, GetMaxRating());

		UpdateRating();
	}

	void Update(int dt) override
	{
		ScriptWidgetHost::Update(dt);

		if (m_switches !is null)
			m_switches.Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		ScriptWidgetHost::Draw(sb, idt);

		if (m_switches !is null)
			m_switches.Draw(sb, idt);
	}

	int GetMaxRating()
	{
%if HARDCORE
		int ret = 0;
		for (uint i = 0; i < g_players.length(); i++)
		{
			auto player = g_players[i];
			if (player.peer == 255)
				continue;

			int rank = player.GladiatorRank();
			if (rank > ret)
				ret = rank;
		}
		return ret;
%else
		auto record = GetLocalPlayerRecord();
		auto gm = cast<Campaign>(g_gameMode);

		int highestNgp = gm.m_townLocal.m_highestNgps.GetHighest();
		int gladiatorRank = record.GladiatorRank();

		return max(highestNgp * 5, gladiatorRank);
%endif
	}

	void UpdateRating()
	{
		auto gm = cast<Campaign>(g_gameMode);
		gm.m_townLocal.m_lastGladiatorRank = m_startRating;

%if HARDCORE
		m_wButtonLeft.m_enabled = false;
		m_wButtonRight.m_enabled = false;
%else
		m_wButtonLeft.m_enabled = (m_startRating > 0);
		m_wButtonRight.m_enabled = (m_startRating < GetMaxRating());
%endif
		m_wRating.SetText("" + m_startRating);

		auto record = GetLocalPlayerRecord();
		int pointsRequired = m_startRating * Tweak::PointsPerGladiatorRank;

		for (uint i = 0; i < m_arrProgress.length(); i++)
		{
			if (record.gladiatorPoints >= pointsRequired + (i + 1))
				m_arrProgress[i].SetSprite("icon-progress-on");
			else
				m_arrProgress[i].SetSprite("icon-progress-off");
		}

		DoLayout();
	}

	void UpdateBlueprints()
	{
		auto wList = m_widget.GetWidgetById("blueprint-list");
		auto wTemplate = m_widget.GetWidgetById("blueprint-template");

		wList.ClearChildren();

		auto gm = cast<Campaign>(g_gameMode);

		array<Spectacular::BlueprintDef@> blueprints;
		for (uint i = 0; i < Spectacular::g_blueprints.length(); i++)
		{
			auto blueprint = Spectacular::g_blueprints[i];
			if (blueprint.m_unlocked)
				blueprints.insertLast(blueprint);
		}

		for (uint i = 0; i < gm.m_town.m_survivalBlueprints.length(); i++)
		{
			auto blueprint = Spectacular::GetBlueprint(gm.m_town.m_survivalBlueprints[i]);
			if (blueprint is null || blueprints.findByRef(blueprint) != -1)
				continue;
			blueprints.insertLast(blueprint);
		}

		for (uint i = 0; i < blueprints.length(); i++)
		{
			auto blueprint = blueprints[i];

			auto wNewBlueprint = cast<ScalableSpriteButtonWidget>(wTemplate.Clone());
			wNewBlueprint.SetID("");
			wNewBlueprint.m_visible = true;

			wNewBlueprint.SetText(blueprint.m_name);
			wNewBlueprint.m_tooltipTitle = blueprint.m_name;
			wNewBlueprint.m_tooltipText = blueprint.m_description;
			wNewBlueprint.m_func = "start-spectacular " + blueprint.m_id;

			wList.AddChild(wNewBlueprint);
		}
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Stop() override
	{
		if (m_switches !is null)
		{
			g_gameMode.RemoveWidgetRoot(m_switches);
			@m_switches = null;
		}

		ScriptWidgetHost::Stop();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "stop")
			Stop();
		else if (parse[0] == "back")
		{
			m_wContentMain.m_visible = true;
			m_wContentTrials.m_visible = false;
			m_wContentSpectacular.m_visible = false;
		}
%if !HARDCORE
		else if (parse[0] == "g-rating-prev")
		{
			if (m_startRating > 0)
				m_startRating--;
			UpdateRating();
		}
		else if (parse[0] == "g-rating-next")
		{
			if (m_startRating < GetMaxRating())
				m_startRating++;
			UpdateRating();
		}
%endif
		else if (parse[0] == "trials")
		{
			m_wContentMain.m_visible = false;
			m_wContentTrials.m_visible = true;

			@g_gameMode.m_widgetUnderCursor = null;
		}
		else if (parse[0] == "switches")
		{
			@m_switches = ColiseumSwitchesDialog(g_gameMode.m_guiBuilder, this);
			g_gameMode.AddWidgetRoot(m_switches);
		}
		else if (parse[0] == "start-trials")
		{
			GlobalCache::Set("start_rating", "" + m_startRating);

			Lobby::SetJoinable(false);
			g_startId = "";
			ChangeLevel("levels/arena.lvl");
		}
		else if (parse[0] == "spectacular")
		{
			m_wContentMain.m_visible = false;
			m_wContentSpectacular.m_visible = true;

			@g_gameMode.m_widgetUnderCursor = null;

			UpdateBlueprints();
		}
		else if (parse[0] == "start-spectacular")
		{
			GlobalCache::Set("start_rating", "" + m_startRating);

			auto blueprint = Spectacular::GetBlueprint(parse[1]);
			if (blueprint is null)
			{
				PrintError("Couldn't find blueprint with ID \"" + parse[1] + "\"");
				return;
			}

			for (uint i = 0; i < blueprint.m_flags.length(); i++)
				g_flags.Set(blueprint.m_flags[i], FlagState::Run);

			Lobby::SetJoinable(false);
			g_startId = "";
			ChangeLevel("levels/test/coliseum_spectacular.lvl");
		}
	}
}
