namespace WorldScript
{
	[WorldScript color="63 92 198" icon="system/icons.png;416;64;32;32"]
	class UseTeleport : IUsable
	{
		bool Enabled;
		vec3 Position;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable]
		string ScriptLinkTarget;
		
		[Editable max=1 validation=IsValid]
		UnitFeed ScriptLinkTargetCurrent;

		[Editable type=enum default=6]
		UsableIcon Icon;

		UnitSource Teleported;

		bool IsScriptLink(UnitPtr unit)
		{
			return cast<ScriptLink>(unit.GetScriptBehavior()) !is null;
		}		

		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
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
					
					auto current = WorldScript::GetWorldScript(g_scene, ScriptLinkTargetCurrent.FetchFirst().GetScriptBehavior());
					if (current !is null)
					{
						for (uint i = 0; i < res.length(); i++)
						{
							if (res[i] is current)
							{
								startIdx = i + 1;
								break;
							}
						}
					}

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

		Player@ GetPlayer(UnitPtr unit)
		{
			if (!unit.IsValid())
				return null;

			ref@ behavior = unit.GetScriptBehavior();

			if (behavior is null)
				return null;

			return cast<Player>(behavior);
		}

		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			Player@ plr = GetPlayer(unit);
			if (plr !is null)
				plr.AddUsable(this);
		}

		void OnExit(UnitPtr unit)
		{
			Player@ plr = GetPlayer(unit);
			if (plr !is null)
				plr.RemoveUsable(this);
		}

		SValue@ ServerExecute()
		{
			return null;
		}

		UnitPtr GetUseUnit()
		{
			return WorldScript::GetWorldScript(g_scene, this).GetUnit();
		}

		bool CanUse(PlayerBase@ player)
		{
			return Enabled;
		}

		void Use(PlayerBase@ player)
		{
			Teleported.Replace(player.m_unit);

			auto telPos = GetPosition();
			(Network::Message("UnitTeleported") << player.m_unit << xy(telPos)).SendToAll();
			player.m_unit.SetPosition(telPos);

			WorldScript::GetWorldScript(g_scene, this).Execute();
		}

		void NetUse(PlayerHusk@ player)
		{
			Use(player);
		}

		UsableIcon GetIcon(Player@ player)
		{
			return Icon;
		}

		int UsePriority(IUsable@ other) { return 0; }
	}
}
