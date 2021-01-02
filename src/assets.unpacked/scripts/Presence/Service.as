namespace ServicePresence
{
	class StatusKey
	{
		string m_key;
		string m_value;

		StatusKey() { }

		StatusKey(const StatusKey &in copy)
		{
			m_key = copy.m_key;
			m_value = copy.m_value;
		}

		StatusKey(string key, string value)
		{
			m_key = key;
			m_value = value;
		}

		int opCmp(const StatusKey &in key) const
		{
			if (m_key != key.m_key) return 1;
			if (m_value != key.m_value) return 1;
			return 0;
		}
	}

	class Status
	{
		string m_display;
		array<StatusKey> m_keys;

		string m_groupId;
		int m_groupSize;

		int opCmp(const Status &in status) const
		{
			if (m_display != status.m_display) return 1;
			if (m_keys != status.m_keys) return 1;
			if (m_groupId != status.m_groupId) return 1;
			if (m_groupSize != status.m_groupSize) return 1;
			return 0;
		}
	}

	Status g_statusCurrent;
	Status g_status;

	int g_timeC;

	void Update(int ms)
	{
		g_timeC -= ms;
		if (g_timeC <= 0)
		{
			g_timeC = 1000;

			if (Lobby::IsInLobby())
			{
				g_status.m_groupId = Lobby::GetLobbyData("name");
				g_status.m_groupSize = Lobby::GetLobbyPlayerCount();
			}

			if (g_statusCurrent != g_status)
			{
				g_statusCurrent = g_status;

				Platform::Service.ClearRichPresence();
				Platform::Service.SetRichPresence(g_statusCurrent.m_display);
				for (uint i = 0; i < g_statusCurrent.m_keys.length(); i++)
				{
					auto key = g_statusCurrent.m_keys[i];
					Platform::Service.SetRichPresenceKey(key.m_key, key.m_value);
				}
				Platform::Service.SetRichPresenceGroup(g_statusCurrent.m_groupId);
				Platform::Service.SetRichPresenceGroupSize(g_statusCurrent.m_groupSize);
			}
		}
	}

	void Clear()
	{
		g_status = Status();
	}

	void Set(string key)
	{
		g_status.m_display = key;
	}

	void Param(string key, string value)
	{
		g_status.m_keys.insertLast(StatusKey(key, value));
	}
}
