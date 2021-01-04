class ClosableScriptInterface : ScriptWidgetHost
{
	ClosableScriptInterface(SValue& params)
	{
		super();
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
