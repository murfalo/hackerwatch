class ScriptWaypoint : Waypoint
{
	UnitPtr m_attached;

	bool m_shouldStay;

	float m_fadeStart;
	float m_fadeEnd;

	float m_fadeNearStart;
	float m_fadeNearEnd;

	ScriptWaypoint(string sprite, vec3 pos)
	{
		m_shouldStay = true;

		HUD@ hud = GetHUD();
		if (hud is null)
			return;

		super(hud.m_guiDef.GetSprite(sprite), pos);
	}

	void Update(int dt) override
	{
		if (m_attached.IsValid())
			m_pos = m_attached.GetPosition();

		Waypoint::Update(dt);
	}

	bool ShouldStay() override
	{
		if (m_attached.IsValid())
		{
			Actor@ actor = cast<Actor>(m_attached.GetScriptBehavior());
			if (actor !is null)
				return m_shouldStay && !actor.IsDead();
		}

		return m_shouldStay;
	}

	bool ShouldShow(vec2 screenPos) override
	{
		float distance = dist(m_fromPos, m_pos);
		if (m_fadeNearStart > -1)
		{
			if (distance < m_fadeNearEnd)
				return false;
		}
		return (distance < m_fadeEnd);
	}

	vec4 GetColor() override
	{
		float distance = dist(m_fromPos, m_pos);

		float a = 1.0f;
		if (distance > m_fadeEnd)
			a = 0.0f;
		else if (distance > m_fadeStart)
			a = 1.0f - (distance - m_fadeStart) / (m_fadeEnd - m_fadeStart);

		if (m_fadeNearStart > -1)
		{
			if (distance < m_fadeNearEnd)
				a = 0.0f;
			else if (distance < m_fadeNearStart)
				a = 1.0f - (distance - m_fadeNearStart) / (m_fadeNearEnd - m_fadeNearStart);
		}

		a *= GetVarFloat("ui_waypoint_world");

		return vec4(1, 1, 1, a);
	}

	vec2 GetScreenPosition(vec2 plyPos) override
	{
		vec2 centerPos = vec2(g_gameMode.m_wndWidth / 2.0, g_gameMode.m_wndHeight / 2.0);
		float arrowDistance = min(min(g_gameMode.m_wndWidth, g_gameMode.m_wndHeight) * 0.4, dist(centerPos, plyPos));
		vec2 dir = normalize(plyPos - centerPos) * Tweak::WaypointShape;
		return centerPos + dir * arrowDistance;
	}
}
