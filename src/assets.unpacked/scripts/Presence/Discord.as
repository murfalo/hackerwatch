namespace DiscordPresence
{
	Discord::Status g_statusCurrent;
	Discord::Status g_status;

	int g_timeC;

	void Update(int ms)
	{
		if (!Discord::IsReady())
			return;

		g_timeC -= ms;
		if (g_timeC <= 0)
		{
			g_timeC = 1000;

			if (g_status.LargeImageKey == "")
				g_status.LargeImageKey = "default";

			auto record = GetLocalPlayerRecord();
			if (record !is null)
			{
				g_status.SmallImageKey = "class_" + record.charClass;
				g_status.SmallImageText = record.name + " the level " + record.level + " " + Resources::GetString(".class." + record.charClass, true);
			}

			if (Lobby::IsInLobby())
			{
				g_status.PartySize = Lobby::GetLobbyPlayerCount();
				g_status.PartyMax = Lobby::GetLobbyPlayerCountMax();
				g_status.PartyId = Lobby::GetLobbyData("name");
				if (g_status.PartyId.length() == 0)
					g_status.PartyId = "..";
				else if (g_status.PartyId.length() == 1)
					g_status.PartyId += ".";

				auto gm = cast<Town>(g_gameMode);
				if (gm !is null)
					g_status.JoinSecret = Lobby::GetLobbyId();
			}

			if (g_statusCurrent != g_status)
			{
				g_statusCurrent = g_status;
				Discord::SetStatus(g_statusCurrent);
			}
		}
	}

	void Clear()
	{
		g_status.Clear();
	}

	void SetState(string state)
	{
		g_status.State = state;
	}

	void SetDetails(string details)
	{
		g_status.Details = details;
	}

	void AddDetails(string details)
	{
		g_status.Details += details;
	}

	void SetStartTimestamp(int64 timestamp)
	{
		g_status.StartTimestamp = timestamp;
	}

	void SetLargeImageKey(string key)
	{
		g_status.LargeImageKey = key;
	}

	void SetLargeImageText(string text)
	{
		g_status.LargeImageText = text;
	}
}
