namespace WorldScript
{
	[WorldScript color="210 30 30" icon="system/icons.png;384;224;32;32"]
	class Sarcophagus : IUsable
	{
		SarcophagusUI@ m_interface;

		bool Enabled;
		vec3 Position;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;

		[Editable validation=IsExecutable]
		UnitFeed OnPlayerUsed;

		UnitSource LastUsed;

		bool m_used = false;

		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
			}
		}

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
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

		UnitPtr GetUseUnit()
		{
			return WorldScript::GetWorldScript(g_scene, this).GetUnit();
		}

		bool CanUse(PlayerBase@ player)
		{
			if (!Enabled)
				return false;

			if (m_used && player.m_record.local)
				return false;

			if (cast<PlayerHusk>(player) !is null)
				return true;

			return true;
		}

		void Use(PlayerBase@ player)
		{
			@m_interface = SarcophagusUI();

			auto gm = cast<Campaign>(g_gameMode);

			m_interface.LoadWidget(g_gameMode.m_guiBuilder, "gui/sarcophagus.gui");
			@m_interface.m_sarcophagusScript = this;

			gm.m_widgetScriptHosts.insertLast(m_interface);
			gm.AddWidgetRoot(m_interface);

			PauseGame(true, true);

			m_interface.Initialize(false);
		}

		void Stop()
		{
			auto gm = cast<Campaign>(g_gameMode);

			int index = gm.m_widgetScriptHosts.findByRef(m_interface);
			if (index != -1)
				gm.m_widgetScriptHosts.removeAt(index);

			gm.RemoveWidgetRoot(m_interface);

			@m_interface = null;

			PauseGame(false, true);
		}

		void OnUsed()
		{
			if (UseScene != "")
			{
				auto units = Unit.FetchAll();
				for (uint i = 0; i < units.length(); i++)
					units[i].SetUnitScene(UseScene, true);
			}

			m_used = true;

			auto player = GetLocalPlayer();
			if (player !is null)
				LastUsed.Replace(player.m_unit);

			if (Network::IsServer())
				NetOnUse();
			else
			{
				auto ws = WorldScript::GetWorldScript(g_scene, this);
				(Network::Message("SarcophagusUsed") << ws.GetUnit()).SendToHost();
			}
		}

		void NetOnUse()
		{
			if (!Network::IsServer())
				return;

			auto toExec = OnPlayerUsed.FetchAll();
			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
		}

		SValue@ Save()
		{
			SValueBuilder sval;
			sval.PushBoolean(m_used);
			return sval.Build();
		}

		void Load(SValue@ data)
		{
			m_used = data.GetBoolean();
		}

		UsableIcon GetIcon(Player@ player)
		{
			if (!CanUse(player))
				return Cross;

			return Generic;
		}

		int UsePriority(IUsable@ other) { return 0; }

		void NetUse(PlayerHusk@ player) { }
	}
}
