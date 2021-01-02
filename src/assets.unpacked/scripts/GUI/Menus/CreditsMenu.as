namespace Menu
{
	class CreditsMenu : Menu
	{
		CreditsMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			auto wCredits = cast<ScrollableWidget>(m_widget.GetWidgetById("credits"));
			if (wCredits !is null)
				wCredits.m_autoScrollValue = -wCredits.m_height;
		}

		void SetStyle(SValue@ svStyle) override
		{
			auto wCrackshell = cast<SpriteWidget>(m_widget.GetWidgetById("crackshell"));
			if (wCrackshell !is null)
			{
				string introLogo = GetParamString(UnitPtr(), svStyle, "intro-logo");
				wCrackshell.SetSprite(introLogo);
			}
		}

		void Update(int dt) override
		{
			auto wCredits = cast<ScrollableWidget>(m_widget.GetWidgetById("credits"));
			if (wCredits !is null && wCredits.m_autoScroll)
			{
				if (wCredits.m_autoScrollValue < -wCredits.m_height || wCredits.m_autoScrollValue >= wCredits.m_autoScrollHeight)
					wCredits.m_autoScrollValue = -wCredits.m_height;

				wCredits.m_autoScrollValue += 1;
			}

			Menu::Menu::Update(dt);
		}

		void UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override
		{
			Menu::UpdateInput(origin, parentSz, mousePos);

			MenuInput@ input = GetMenuInput();
			if (input.Forward.Released)
				Close();
		}
	}
}
