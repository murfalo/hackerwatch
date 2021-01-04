class AGameMode
{
	uint64 m_gameTime;

	int m_wndWidth;
	int m_wndHeight;
	float m_wndAspect;
	float m_wndScale;
	mat4 m_wndInvScaleTransform;

	Widget@ m_widgetUnderCursor;
	Widget@ m_widgetInputFocus;

	GameInput@ m_currInput;
	MenuInput@ m_currInputMenu;
	Platform::CursorInfo@ m_currCursor;
	
	DialogWindow@ m_dialogWindow;
	
	GUIBuilder m_guiBuilder;
	
	
	
	void ShowDialog(string id, string question, string buttonYes, string buttonNo, IWidgetHoster@ returnHost) {}
	void ShowDialog(string id, string message, string button, IWidgetHoster@ returnHost) {}
	void ShowInputDialog(string id, string message, IWidgetHoster@ returnHost, string defaultInput = "") {}
	HUD@ GetHUD() { return null; }

	void ClearWidgetRoot() {}
	void SetExclusiveWidgetRoot(IWidgetHoster@ host) {}
	void ReplaceWidgetRoot(IWidgetHoster@ find, IWidgetHoster@ replace) {}
	void ReplaceTopWidgetRoot(IWidgetHoster@ host) {}
	void AddWidgetRoot(IWidgetHoster@ host) {}
	void RemoveWidgetRoot(IWidgetHoster@ host) {}
	
	void SpawnPlayer(int i, vec2 pos = vec2(-1, -1), int unitId = 0, uint team = 0) {}
	void SpawnPlayerCorpse(int i, vec2 pos = vec2(-1, -1)) {}
	void AttemptRespawn(uint8 peer) {}

	float FilterAction(Actor@ a, Actor@ owner, float selfDmg, float teamDmg, float enemyDmg, uint teamOverride = 1) { return 1; }
}