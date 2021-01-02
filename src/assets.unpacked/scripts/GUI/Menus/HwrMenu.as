namespace Menu
{
	class HwrMenu : Menu
	{
		HwrMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void ShowCharacterSelection(string context)
		{
			if (GetVarInt("g_save_slot") == 0 && HwrSaves::GetCharacters().length() == 0)
				OpenMenu(CharacterCreationMenu(m_provider, context), "gui/main_menu/character_creation.gui");
			else
				OpenMenu(CharacterSelectionMenu(m_provider, context), "gui/main_menu/character_selection.gui");
		}

		void FinishContext(string context)
		{
			if (context == "")
				cast<MainMenu>(g_gameMode).PlayGame(GetVarInt("g_start_sessions"));
			else if (context == "multi-host")
				OpenMenu(Menu::HostMenu(m_provider), "gui/main_menu/host.gui");
			else if (context == "multi-serverlist")
				OpenMenu(Menu::ServerlistMenu(m_provider), "gui/main_menu/serverlist.gui");
			else if (context == "multi-invite")
			{
				auto char = HwrSaves::LoadCharacter();
				int charLevel = GetParamInt(UnitPtr(), char, "level", false, 1);
				bool mercenary = GetParamBool(UnitPtr(), char, "mercenary", false);

				auto gm = cast<MainMenu>(g_gameMode);
				if (charLevel < gm.m_inviteAcceptMinLevel || (gm.m_inviteAcceptMaxLevel != -1 && charLevel > gm.m_inviteAcceptMaxLevel))
				{
					g_gameMode.ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.level", {
						{ "min", gm.m_inviteAcceptMinLevel },
						{ "max", gm.m_inviteAcceptMaxLevel == -1 ? "-" : "" + gm.m_inviteAcceptMaxLevel }
					}), Resources::GetString(".menu.ok"), null);
					return;
				}

				if (gm.m_inviteAcceptMercenary && !mercenary)
				{
					g_gameMode.ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.notmercenary"), Resources::GetString(".menu.ok"), null);
					return;
				}
				else if (!gm.m_inviteAcceptMercenary && mercenary)
				{
					g_gameMode.ShowDialog("", Resources::GetString(".menu.notifier.joinfailed.mercenary"), Resources::GetString(".menu.ok"), null);
					return;
				}

				gm.JoiningLobby();
				Lobby::JoinLobby(gm.m_inviteAcceptID);
			}
		}
	}
}
