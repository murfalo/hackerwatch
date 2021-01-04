namespace Menu
{
	class OptionsMenu : Menu
	{
		OptionsMenu(MenuProvider@ provider)
		{
			super(provider);

			m_isPopup = true;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "cfg-game")
				OpenMenu(Menu::GameOptionsMenu(m_provider), "gui/main_menu/options_game.gui");
			else if (name == "cfg-graphics")
				OpenMenu(Menu::GraphicsMenu(m_provider), "gui/main_menu/options_graphics.gui");
			else if (name == "cfg-sound")
				OpenMenu(Menu::SoundMenu(m_provider), "gui/main_menu/options_sound.gui");
			else if (name == "cfg-controls")
				OpenMenu(Menu::ControlsMenu(m_provider), "gui/main_menu/options_controls.gui");
			else
				Menu::OnFunc(sender, name);
		}
	}
}
