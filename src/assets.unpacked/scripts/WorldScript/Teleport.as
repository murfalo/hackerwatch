namespace WorldScript
{
	[WorldScript color="63 92 198" icon="system/icons.png;416;64;32;32"]
	class Teleport
	{
		vec3 Position;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable]
		string ScriptLinkTarget;
		
		[Editable type=flags default=2]
		AreaFilter Filter;
		
		UnitSource Teleported;
		

		void Initialize()
		{
			if (Network::IsServer())
			{
				for (uint i = 0; i < Areas.length(); i++)
					Areas[i].AddOnEnter(this, "OnEnter");
			}
		}
		
		vec3 GetPosition()
		{
			if (ScriptLinkTarget != "")
			{
				auto res = g_scene.FetchAllWorldScriptsWithComment("ScriptLink", ScriptLinkTarget);
				if (res.length() > 0)
				{
					int startIdx = randi(res.length());
					for (uint i = 0; i < res.length(); i++)
					{
						auto script = res[(startIdx + i) % res.length()];
						if (!script.CanExecuteNow())
							continue;
				
						script.Execute();
						return script.GetUnit().GetPosition();
					}
				}
			}
			
			return Position;
		}

		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			if (!Network::IsServer())
				return;
		
			auto ws = WorldScript::GetWorldScript(g_scene, this);
			if (!ws.IsEnabled() || ws.GetTriggerTimes() == 0)
				return;

			if (!ApplyAreaFilter(unit, Filter))
				return;

			Teleported.Replace(unit);
			auto telPos = GetPosition();
			(Network::Message("UnitTeleported") << unit << xy(telPos)).SendToAll();
			unit.SetPosition(telPos);

			ws.Execute();
		}

		void OnEnabledChanged(bool enabled)
		{
			if (!enabled)
				return;
				
			if (!Network::IsServer())
				return;

			auto script = WorldScript::GetWorldScript(g_scene, this);
			for (uint i = 0; i < Areas.length(); i++)
			{
				auto units = Areas[i].FetchAllInside(g_scene);
				for (uint j = 0; j < units.length(); j++)
				{
					UnitPtr unit = units[j];
					
					if (!ApplyAreaFilter(unit, Filter))
						continue;

					Teleported.Replace(unit);
					auto telPos = GetPosition();
					(Network::Message("UnitTeleported") << unit << xy(telPos)).SendToAll();
					unit.SetPosition(telPos);

					script.Execute();
				}
			}
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
