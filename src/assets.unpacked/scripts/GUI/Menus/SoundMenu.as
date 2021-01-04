namespace Menu
{
	class SoundMenu : SubOptionsMenu
	{
		SoundMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}
	}
}
