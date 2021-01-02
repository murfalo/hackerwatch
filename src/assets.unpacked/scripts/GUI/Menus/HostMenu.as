namespace Menu
{
	class HostMenu : Menu
	{
		ScalableSpriteButtonWidget@ m_wButtonOK;
		TextInputWidget@ m_wName;

		SliderWidget@ m_wMaxPlayers;
		SliderWidget@ m_wMaxLevel;
		SliderWidget@ m_wMinLevel;

		TextWidget@ m_wNgpLabel;
		TextWidget@ m_wNgp;
		SpriteButtonWidget@ m_wNgpLeft;
		SpriteButtonWidget@ m_wNgpRight;

		CheckBoxWidget@ m_wDownscaling;
		CheckBoxWidget@ m_wAllowModded;

		bool m_isMercenaryLobby;

		HostMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			Menu::Initialize(def);

			@m_wButtonOK = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("ok"));

			@m_wName = cast<TextInputWidget>(m_widget.GetWidgetById("name"));
			if (m_wName !is null)
				m_wName.SetText(Resources::GetString(".mainmenu.host.name", { { "name", Lobby::GetPlayerName(0) } }));

			@m_wMaxPlayers = cast<SliderWidget>(m_widget.GetWidgetById("max-players"));
			if (m_wMaxPlayers !is null)
			{
				int maxLimit = GetVarInt("g_multiplayer_limit");
				if (maxLimit < 4)
					maxLimit = 4;
				m_wMaxPlayers.m_max = float(maxLimit);
				m_wMaxPlayers.m_default = float(maxLimit);
				m_wMaxPlayers.Reset();
			}

			@m_wMaxLevel = cast<SliderWidget>(m_widget.GetWidgetById("max-level"));
			@m_wMinLevel = cast<SliderWidget>(m_widget.GetWidgetById("min-level"));

			int highestLevel = int(m_wMaxLevel.m_max);
			auto arrCharacters = HwrSaves::GetCharacters();
			for (uint i = 0; i < arrCharacters.length(); i++)
			{
				auto svChar = arrCharacters[i];
				int level = GetParamInt(UnitPtr(), svChar, "level", false, 1);
				if (level > highestLevel)
					highestLevel = level;
			}

			m_wMaxLevel.m_max = (floor(float(highestLevel) / 10.0f) + 1) * 10.0f + 1;
			m_wMaxLevel.UpdateText();

			@m_wNgpLabel = cast<TextWidget>(m_widget.GetWidgetById("ngp-label"));
			@m_wNgp = cast<TextWidget>(m_widget.GetWidgetById("ngp"));
			@m_wNgpLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-left"));
			@m_wNgpRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-right"));

			@m_wDownscaling = cast<CheckBoxWidget>(m_widget.GetWidgetById("downscaling"));
			@m_wAllowModded = cast<CheckBoxWidget>(m_widget.GetWidgetById("allowmodded"));

			m_wAllowModded.m_enabled = !HwrSaves::IsModded();
			m_wAllowModded.m_checked = HwrSaves::IsModded();

			auto svChar = HwrSaves::LoadCharacter();
			if (svChar !is null)
			{
				m_isMercenaryLobby = GetParamBool(UnitPtr(), svChar, "mercenary", false);
				if (m_isMercenaryLobby)
				{
					m_wDownscaling.m_enabled = false;
					m_wNgpLeft.m_enabled = false;
					m_wNgpRight.m_enabled = false;
					m_wNgpLabel.SetColor(vec4(0.25, 0.25, 0.25, 1));
				}
			}

			UpdateNgp();

			cast<MainMenu>(g_gameMode).m_hostPrivate = false;
		}

		void UpdateNgp()
		{
			auto gm = cast<MainMenu>(g_gameMode);
			auto highestBaseNgp = gm.m_town.m_highestNgps["base"];

			if (m_isMercenaryLobby)
				m_wNgp.SetText("-");
			else
			{
				m_wNgp.SetText("+" + gm.m_hostNgp);
				m_wNgpLeft.m_enabled = (gm.m_hostNgp > 0);
				m_wNgpRight.m_enabled = (gm.m_hostNgp < highestBaseNgp);
			}

			Invalidate();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "privacy-changed")
			{
				auto checkable = cast<ICheckableWidget>(sender);
				cast<MainMenu>(g_gameMode).m_hostPrivate = (checkable.IsChecked());
			}
			else if (name == "host")
			{
				auto gm = cast<MainMenu>(g_gameMode);

				int maxLevel = m_wMaxLevel.GetValueInt();
				if (maxLevel == int(m_wMaxLevel.m_max))
					maxLevel = -1;

				gm.m_hostName = m_wName.m_text.plain();
				gm.m_hostMaxPlayers = m_wMaxPlayers.GetValueInt();
				gm.m_hostMaxLevel = maxLevel;
				gm.m_hostMinLevel = m_wMinLevel.GetValueInt();
				gm.m_hostDownscaling = m_wDownscaling.IsChecked();
				gm.m_hostAllowModded = m_wAllowModded.IsChecked();

				m_wButtonOK.m_enabled = false;
				Lobby::CreateLobby();
			}
			else if (name == "levels-changed")
			{
				int maxLevel = m_wMaxLevel.GetValueInt();
				int minLevel = m_wMinLevel.GetValueInt();

				if (minLevel > maxLevel)
					m_wMinLevel.SetValueInt(maxLevel);
			}
			else if (name == "ngp-prev")
			{
				auto gm = cast<MainMenu>(g_gameMode);

				gm.m_hostNgp--;
				if (gm.m_hostNgp < 0)
					gm.m_hostNgp = 0;

				UpdateNgp();
			}
			else if (name == "ngp-next")
			{
				auto gm = cast<MainMenu>(g_gameMode);
				auto highestBaseNgp = gm.m_town.m_highestNgps["base"];

				gm.m_hostNgp++;
				if (gm.m_hostNgp > highestBaseNgp)
					gm.m_hostNgp = highestBaseNgp;

				UpdateNgp();
			}
			else
				Menu::OnFunc(sender, name);
		}
	}
}
