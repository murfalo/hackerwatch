namespace WorldScript
{
	[WorldScript color="#B0C4DE" icon="system/icons.png;352;352;32;32"]
	class OpenInterface
	{
		ScriptWidgetHost@ m_interface;
		bool m_loadRequired;

		[Editable]
		UnitFeed ForPlayer;

		[Editable]
		string UserWindowID;

		[Editable]
		string Filename;

		[Editable]
		bool MakeRoot;

		[Editable]
		string Class;

		[Editable]
		string Param;

		SValue@ Save()
		{
			SValueBuilder builder;
			builder.PushBoolean(m_interface !is null && m_interface.ShouldSaveExistance());
			return builder.Build();
		}

		void Load(SValue@ data)
		{
			if (data is null || data.GetType() != SValueType::Boolean)
				return;

			m_loadRequired = data.GetBoolean();
		}

		void Update(int dt)
		{
			if (m_loadRequired)
			{
				m_loadRequired = false;
				Start(true);
			}
		}

		void Start(bool loaded)
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			if (gm is null)
			{
				PrintError("OpenInterface only works on BaseGameMode!");
				return;
			}

			if (UserWindowID != "")
				gm.ShowUserWindow(UserWindowID);
			else
			{
				if (m_interface !is null)
					Stop();

				if (Class == "")
					@m_interface = ScriptWidgetHost();
				else
				{
					SValueBuilder svb;
					svb.PushString(Param);
					@m_interface = cast<ScriptWidgetHost>(InstantiateClass(Class, svb.Build()));
				}

				m_interface.LoadWidget(g_gameMode.m_guiBuilder, Filename);
				@m_interface.m_script = this;

				gm.m_widgetScriptHosts.insertLast(m_interface);

				if (MakeRoot)
					gm.AddWidgetRoot(m_interface);

				m_interface.Initialize(loaded);
			}
		}

		void Stop()
		{
			if (m_interface is null)
				return;

			auto gm = cast<BaseGameMode>(g_gameMode);
			if (gm is null)
			{
				PrintError("OpenInterface only works on BaseGameMode!");
				return;
			}

			int index = gm.m_widgetScriptHosts.findByRef(m_interface);
			if (index != -1)
				gm.m_widgetScriptHosts.removeAt(index);

			if (MakeRoot)
				gm.RemoveWidgetRoot(m_interface);

			@m_interface = null;
		}

		SValue@ ServerExecute()
		{
			int peerId = -1;

			UnitPtr unit = ForPlayer.FetchFirst();
			if (unit.IsValid())
			{
				auto player = cast<PlayerBase>(unit.GetScriptBehavior());
				if (player !is null)
					peerId = player.m_record.peer;
			}

			SValueBuilder builder;
			builder.PushInteger(peerId);
			auto data = builder.Build();

			ClientExecute(data);
			return data;
		}

		void ClientExecute(SValue@ sval)
		{
			if (sval.GetType() != SValueType::Integer)
				return;

			int peerId = sval.GetInteger();
			if (peerId != -1)
			{
				auto record = GetLocalPlayerRecord();
				if (record is null)
					return;

				if (int(record.peer) != peerId)
					return;
			}

			Start(false);
		}
	}
}
