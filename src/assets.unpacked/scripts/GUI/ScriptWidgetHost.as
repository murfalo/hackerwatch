class ScriptWidgetHost : IWidgetHoster
{
	GUIDef@ m_def;

	WorldScript::OpenInterface@ m_script;

	ScriptWidgetHost()
	{
		super();
	}

	GUIDef@ LoadWidget(GUIBuilder@ b, string filename) override
	{
		@m_def = IWidgetHoster::LoadWidget(b, filename);
		return m_def;
	}

	void Initialize(bool loaded) { }
	bool ShouldFreezeControls() { return false; }
	bool ShouldDisplayCursor() { return false; }
	bool ShouldSaveExistance() { return true; }

	void Stop()
	{
		m_script.Stop();

		CloseTooltip();
	}

	void CloseTooltip()
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm !is null)
			gm.m_tooltip.Hide();
	}
}
