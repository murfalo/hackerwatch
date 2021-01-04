class WaypointMarkersWidget : Widget
{
	array<Waypoint@> m_waypoints;

	WaypointMarkersWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		auto def = ctx.GetGUIDef();

		Widget::Load(ctx);
	}

	void AddWaypoint(Waypoint@ wp)
	{
		m_waypoints.insertLast(wp);
	}

	void Update(int dt) override
	{
		for (uint i = 0; i < m_waypoints.length(); i++)
		{
			m_waypoints[i].Update(dt);
			if (!m_waypoints[i].ShouldStay())
				m_waypoints.removeAt(i--);
		}

		Widget::Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		Player@ ply = GetLocalPlayer();
		if (ply is null)
			return;

		vec3 centerPosWorld = ply.m_unit.GetPosition();

		for (uint i = 0; i < m_waypoints.length(); i++)
		{
			Waypoint@ wp = m_waypoints[i];
			wp.m_fromPos = centerPosWorld;

			Sprite@ sprite = wp.m_sprite;
			if (sprite is null)
				continue;

			vec2 wayPos = ToScreenspace(wp.m_pos) / g_gameMode.m_wndScale;

			if (!wp.ShouldShow(wayPos))
				continue;

			wp.Draw(sb, wp.GetScreenPosition(wayPos));
		}
	}
}

ref@ LoadWaypointMarkersWidget(WidgetLoadingContext &ctx)
{
	WaypointMarkersWidget@ w = WaypointMarkersWidget();
	w.Load(ctx);
	return w;
}
