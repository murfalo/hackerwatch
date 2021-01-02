namespace WorldScript
{
	[WorldScript color="232 230 77" icon="system/icons.png;384;0;32;32"]
	class WaypointRemove
	{
		vec3 Position;

		[Editable validation=IsValid]
		UnitFeed AddScripts;

		bool IsValid(UnitPtr unit)
		{
			return cast<WaypointAdd>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
%if	!MOD_NO_HUD
			array<UnitPtr>@ units = AddScripts.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				WaypointAdd@ script = cast<WaypointAdd>(units[i].GetScriptBehavior());
				if (script is null)
					continue;

				for (uint j = 0; j < script.m_waypoints.length(); j++)
					script.m_waypoints[j].m_shouldStay = false;
			}
%endif
		}
	}
}
