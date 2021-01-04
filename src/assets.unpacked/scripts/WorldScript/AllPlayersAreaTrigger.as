namespace WorldScript
{
	[WorldScript color="100 150 180" icon="system/icons.png;384;128;32;32"]
	class AllPlayersAreaTrigger
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable default=true]
		bool OnlyAlivePlayers;

		[Editable validation=IsExecutable]
		UnitFeed OnAllEntered;

		[Editable validation=IsExecutable]
		UnitFeed OnCanceled;

		UnitSource AllInside;
		UnitSource LastEntered;
		UnitSource LastExited;

		bool m_everyoneInside;
		array<PlayerRecord@> m_playersInside;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
			}
		}

		SValue@ Save()
		{
			SValueBuilder builder;
			builder.PushBoolean(m_everyoneInside);
			return builder.Build();
		}

		void Load(SValue@ save)
		{
			if (save.GetType() == SValueType::Boolean)
				m_everyoneInside = save.GetBoolean();
		}

		bool IsEveryoneInside()
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255)
					continue;
			
				if (OnlyAlivePlayers)
				{
					if (g_players[i].IsDead())
						continue;
				}

				int index = m_playersInside.findByRef(g_players[i]);
				if (index == -1)
					return false;
			}
			return true;
		}

		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			PlayerBase@ player = cast<PlayerBase>(unit.GetScriptBehavior());
			if (player is null)
				return;

			m_playersInside.insertLast(player.m_record);

			if (!Enabled)
				return;

			if (Network::IsServer())
			{
				LastEntered.Replace(unit);
				AllInside.Add(unit);
			}

			if (m_everyoneInside)
				return;

			if (IsEveryoneInside())
			{
				m_everyoneInside = true;

				if (Network::IsServer())
				{
					array<UnitPtr>@ arrExec = OnAllEntered.FetchAll();
					for (uint i = 0; i < arrExec.length(); i++)
						WorldScript::GetWorldScript(g_scene, arrExec[i].GetScriptBehavior()).Execute();
				}
			}
		}

		void OnExit(UnitPtr unit)
		{
			PlayerBase@ player = cast<PlayerBase>(unit.GetScriptBehavior());
			if (player is null)
				return;

			int index = m_playersInside.findByRef(player.m_record);
			if (index != -1)
				m_playersInside.removeAt(index);

			if (!Enabled)
				return;

			if (Network::IsServer())
			{
				LastExited.Replace(unit);
				AllInside.Remove(unit);
			}

			if (!m_everyoneInside)
				return;

			if (!IsEveryoneInside())
			{
				m_everyoneInside = false;

				if (Network::IsServer())
				{
					array<UnitPtr>@ arrExec = OnCanceled.FetchAll();
					for (uint i = 0; i < arrExec.length(); i++)
						WorldScript::GetWorldScript(g_scene, arrExec[i].GetScriptBehavior()).Execute();
				}
			}
		}
	}
}
