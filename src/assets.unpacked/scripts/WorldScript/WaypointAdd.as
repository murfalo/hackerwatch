namespace WorldScript
{
	[WorldScript color="232 230 77" icon="system/icons.png;224;386;32;32"]
	class WaypointAdd
	{
		vec3 Position;

		[Editable default="waypoint"]
		string Sprite;

		[Editable]
		UnitFeed AttachTo;

		[Editable default=500]
		float FadeStart;

		[Editable default=550]
		float FadeEnd;

		[Editable default=250]
		float FadeNearStart;

		[Editable default=200]
		float FadeNearEnd;

		[Editable default=false]
		bool ShowDistance;

		[Editable default="gui/fonts/font_hw8.fnt"]
		string ShowDistanceFont;

		array<ScriptWaypoint@> m_waypoints;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
%if	!MOD_NO_HUD
			HUD@ hud = GetHUD();
			if (hud is null || hud.m_waypoints is null)
			{
				PrintError("There is no HUD!");
				return;
			}

			BitmapFont@ textFont;
			if (ShowDistance)
				@textFont = Resources::GetBitmapFont(ShowDistanceFont);

			array<UnitPtr>@ attachUnits = AttachTo.FetchAll();
			if (attachUnits.length() == 0)
			{
				ScriptWaypoint@ newPoint = ScriptWaypoint(Sprite, Position);
				newPoint.m_fadeStart = FadeStart;
				newPoint.m_fadeEnd = FadeEnd;
				newPoint.m_fadeNearStart = FadeNearStart;
				newPoint.m_fadeNearEnd = FadeNearEnd;
				@newPoint.m_font = textFont;
				hud.m_waypoints.AddWaypoint(newPoint);

				m_waypoints.insertLast(newPoint);
			}
			else
			{
				for (uint i = 0; i < attachUnits.length(); i++)
				{
					UnitPtr unit = attachUnits[i];

					ScriptWaypoint@ newPoint = ScriptWaypoint(Sprite, unit.GetPosition());
					newPoint.m_attached = unit;
					newPoint.m_fadeStart = FadeStart;
					newPoint.m_fadeEnd = FadeEnd;
					newPoint.m_fadeNearStart = FadeNearStart;
					newPoint.m_fadeNearEnd = FadeNearEnd;
					@newPoint.m_font = textFont;
					hud.m_waypoints.AddWaypoint(newPoint);

					m_waypoints.insertLast(newPoint);
				}
			}
%endif
		}
	}
}
