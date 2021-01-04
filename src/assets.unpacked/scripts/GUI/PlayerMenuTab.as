class PlayerMenuTab : MenuTab
{
	string GetGuiFilename() override
	{
		return "gui/playermenu/" + m_id + ".gui";
	}
}
