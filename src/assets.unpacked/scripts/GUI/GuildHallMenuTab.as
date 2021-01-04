class GuildHallMenuTab : MenuTab
{
	string GetGuiFilename() override
	{
		return "gui/guildhall/" + m_id + ".gui";
	}
}
