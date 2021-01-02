namespace Menu
{
	class IntroMenu : Menu
	{
		int m_tmLogo;

		array<SpriteWidget@> m_logos;
		uint m_currentLogo;

		IntroMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		bool ShouldDisplayCursor() override { return false; }

		void Initialize(GUIDef@ def) override
		{
			Widget@ wMenu = m_widget.GetWidgetById("menu");
			for (uint i = 0; i < wMenu.m_children.length(); i++)
			{
				SpriteWidget@ wSprite = cast<SpriteWidget>(wMenu.m_children[i]);
				if (wSprite is null)
					continue;

				m_logos.insertLast(wSprite);
			}

			ShowLogo(0);
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

		void ShowLogo(uint index)
		{
			if (index > 0)
				m_logos[m_currentLogo].FinishAnimations();

			m_currentLogo = index;

			vec4 colVisible = vec4(1, 1, 1, 1);
			vec4 colHidden = vec4(1, 1, 1, 0);

			SpriteWidget@ wSprite = m_logos[m_currentLogo];

			wSprite.Animate(WidgetVec4Animation("color", colHidden, colVisible, 750).WithEasing(EasingFunction::Cubic));
			wSprite.Animate(WidgetVec4Animation("color", colVisible, colHidden, 750, 2000).WithEasing(EasingFunction::Cubic));

			m_tmLogo = 2750;
		}

		bool Close() override
		{
			if (m_closing)
				return true;

			SetVar("g_intro_logos_shown", true);

			FrontMenu@ newFrontMenu = FrontMenu(m_provider);
			OpenMenu(newFrontMenu, "gui/main_menu/main.gui", 0);
			m_closing = true;

			return true;
		}

		void NextLogo()
		{
			if (m_currentLogo < m_logos.length() - 1)
				ShowLogo(m_currentLogo + 1);
			else
				Close();
		}

		void Update(int dt) override
		{
			Menu::Update(dt);

			MenuInput@ input = GetMenuInput();
			if (input.Forward.Pressed)
				NextLogo();

			if (m_tmLogo > 0)
			{
				m_tmLogo -= dt;
				if (m_tmLogo <= 0)
					NextLogo();
			}
		}
	}
}
