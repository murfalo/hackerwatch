class TransportPoint : SVO
{
	[Param="icon" Required] string m_icon;
	[Param="name" Required] string m_name;

	[Param="dlc"] string m_dlc;
	[Param="link"] string m_link;

	TransportPoint(SValue& params)
	{
		super(params);
	}

	bool IsEnabled()
	{
		if (m_dlc == "")
			return true;

		return Platform::HasDLC(m_dlc);
	}

	string GetTooltip()
	{
		if (m_dlc != "" && !Platform::HasDLC(m_dlc))
			return Resources::GetString(".town.transport.required-dlc", { { "dlc", Resources::GetString(".dlc." + m_dlc) } });

		return "";
	}

	bool RequireNetsync() { return true; }

	WorldScript@ GetLink()
	{
		auto res = g_scene.FetchAllWorldScriptsWithComment("ScriptLink", m_link);
		if (res.length() == 0)
		{
			PrintError("No scriptlinks found with comment \"" + m_link + "\"!");
			return null;
		}
		else if (res.length() > 1)
		{
			PrintError("Found more than 1 scriptlink with comment \"" + m_link + "\"");
			return null;
		}
		return res[0];
	}

	void TeleportToLink(PlayerBase@ player)
	{
		auto link = GetLink();
		if (link is null)
			return;

		auto linkUnit = link.GetUnit();
		player.m_unit.SetPosition(linkUnit.GetPosition());

		if (Network::IsServer())
			link.Execute();
	}

	SValue@ Teleport(Player@ player)
	{
		TeleportToLink(player);
		return null;
	}

	void TeleportNet(PlayerHusk@ player, SValue@ params)
	{
		TeleportToLink(player);
	}
}
