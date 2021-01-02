class SpeedrunSplit
{
	uint64 m_time;
	int m_levelCount;
	bool m_shortcut;
}

class HUDSpeedrun : IWidgetHoster
{
	bool m_initialized;
	bool m_finished;

	uint64 m_totalTime;
	array<SpeedrunSplit@> m_splits;

	Widget@ m_wContainer;
	TextWidget@ m_wTotalTime;

	Widget@ m_wSplits;
	Widget@ m_wSplitTemplate;

	TextWidget@ m_wCurrentTime;
	SpeedrunSplit@ m_currentSplit;

	HUDSpeedrun(GUIBuilder@ b)
	{
		LoadWidget(b, "gui/speedrun.gui");
	}

	void Initialize()
	{
		@m_wContainer = m_widget.GetWidgetById("container");

		@m_wTotalTime = cast<TextWidget>(m_widget.GetWidgetById("total-time"));

		@m_wSplits = m_widget.GetWidgetById("splits");
		@m_wSplitTemplate = m_widget.GetWidgetById("split-template");

		if (m_splits.length() == 0)
		{
			AddCurrentSplit();
			ReloadSplits();
		}
	}

	string FormattedTime(uint64 time)
	{
		return formatTime(time / 1000.0f, true);
	}

	vec4 ColorForSplit(SpeedrunSplit@ split)
	{
		float alpha = 0.25f;

		if (split.m_shortcut)
			return vec4(0.2f, 0.2f, 0.2f, alpha);

		ivec3 level = CalcLevel(split.m_levelCount);
		switch (level.x)
		{
			case 0: return vec4(0.5f, 0.5f, 0.5f, alpha); // mines
			case 1: return vec4(0.2f, 0.2f, 0.7f, alpha); // prison
			case 2: return vec4(0.7f, 0.2f, 0.2f, alpha); // armory
			case 3: return vec4(0.2f, 0.7f, 0.2f, alpha); // archives
			case 4: return vec4(0.7f, 0.7f, 0.2f, alpha); // chambers
			case 5: return vec4(0.9f, 0.0f, 0.0f, alpha); // top
		}
		return vec4(0.0f, 0.0f, 0.0f, alpha);
	}

	string NameForSplit(SpeedrunSplit@ split)
	{
		if (split.m_shortcut)
			return "Shortcut";

		auto gm = cast<BaseGameMode>(g_gameMode);
		auto dungeon = gm.m_dungeon;
		auto level = dungeon.GetLevel(split.m_levelCount);
		string act = dungeon.GetActName(level, true);
		return act + " " + (level.m_level + 1);
	}

	void AddCurrentSplit()
	{
		auto newSplit = SpeedrunSplit();
		newSplit.m_time = 0;
		newSplit.m_levelCount = cast<Campaign>(g_gameMode).m_levelCount;
		newSplit.m_shortcut = (cast<ShortcutLevel>(g_gameMode) !is null);
		m_splits.insertLast(newSplit);
	}

	void ReloadSplits()
	{
		@m_wCurrentTime = null;
		m_wSplits.ClearChildren();

		for (uint i = 0; i < m_splits.length(); i++)
		{
			auto split = m_splits[i];

			auto wNewSplit = cast<RectWidget>(m_wSplitTemplate.Clone());
			wNewSplit.SetID("");
			wNewSplit.m_visible = true;
			wNewSplit.m_color = tocolor(ColorForSplit(split));

			auto wName = cast<TextWidget>(wNewSplit.GetWidgetById("name"));
			if (wName !is null)
				wName.SetText(NameForSplit(split));

			auto wTime = cast<TextWidget>(wNewSplit.GetWidgetById("time"));
			if (wTime !is null)
			{
				wTime.SetText(FormattedTime(split.m_time));
				@m_wCurrentTime = wTime;
			}

			m_wSplits.AddChild(wNewSplit, 0);

			@m_currentSplit = split;
		}
	}

	void Save(SValueBuilder& builder)
	{
		builder.PushString("total-time", "" + m_totalTime);
		builder.PushArray("splits");
		for (uint i = 0; i < m_splits.length(); i++)
		{
			auto split = m_splits[i];
			builder.PushDictionary();
			builder.PushString("time", "" + split.m_time);
			builder.PushInteger("level", split.m_levelCount);
			builder.PushBoolean("shortcut", split.m_shortcut);
			builder.PopDictionary();
		}
		builder.PopArray();
	}

	void Load(SValue@ sval)
	{
		if (!m_initialized)
			Initialize();

		m_totalTime = parseUInt(GetParamString(UnitPtr(), sval, "total-time"));

		m_splits.removeRange(0, m_splits.length());

		auto arrSplits = GetParamArray(UnitPtr(), sval, "splits");
		for (uint i = 0; i < arrSplits.length(); i++)
		{
			auto svSplit = arrSplits[i];

			auto newSplit = SpeedrunSplit();
			newSplit.m_time = parseUInt(GetParamString(UnitPtr(), svSplit, "time"));
			newSplit.m_levelCount = GetParamInt(UnitPtr(), svSplit, "level");
			newSplit.m_shortcut = GetParamBool(UnitPtr(), svSplit, "shortcut");
			m_splits.insertLast(newSplit);
		}

		AddCurrentSplit();
		ReloadSplits();
	}

	void End()
	{
		m_finished = true;

		uint64 totalTime = 0;
		for (uint i = 0; i < m_splits.length(); i++)
			totalTime += m_splits[i].m_time;

		print("-----------------------");
		print("Speedrun results:");
		print("  Total time: " + FormattedTime(totalTime));
		print("  Splits:");
		for (uint i = 0; i < m_splits.length(); i++)
		{
			auto split = m_splits[i];
			print("    " + NameForSplit(split) + ": " + FormattedTime(split.m_time));
		}
	}

	void Update(int dt) override
	{
		if (!m_initialized)
		{
			m_initialized = true;
			Initialize();
		}

		int runType = GetVarInt("ui_speedrun");
		if (runType == 1)
		{
			bool updateLayout = (m_wSplits.m_visible == true);
			m_wContainer.m_height = 14;
			m_wSplits.m_visible = false;
			if (updateLayout)
				Invalidate();
		}
		else
		{
			bool updateLayout = (m_wSplits.m_visible == false);
			m_wContainer.m_height = 214;
			m_wSplits.m_visible = true;
			if (updateLayout)
				Invalidate();
		}

		IWidgetHoster::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (IsPaused())
			idt = 0;

		if (!m_finished && m_wCurrentTime !is null && m_currentSplit !is null)
		{
			m_currentSplit.m_time = g_gameMode.m_gameTime + idt;
			m_wCurrentTime.SetText(FormattedTime(m_currentSplit.m_time));
		}

		if (m_wTotalTime !is null)
		{
			uint64 totalTime = 0;
			for (uint i = 0; i < m_splits.length(); i++)
				totalTime += m_splits[i].m_time;
			m_wTotalTime.SetText(FormattedTime(totalTime));
		}

		IWidgetHoster::Draw(sb, idt);
	}
}
