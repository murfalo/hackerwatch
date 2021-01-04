class StatisticsInterface : ScriptWidgetHost
{
	StatisticsInterface(SValue& sval)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		TextWidget@ wText = cast<TextWidget>(m_widget.GetWidgetById("stats-text"));
		if (wText !is null)
			wText.SetText(gm.m_town.m_statistics.ToString());
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Stop();
	}
}
