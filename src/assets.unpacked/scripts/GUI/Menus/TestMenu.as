namespace Menu
{
	class TestMenu : Menu
	{
		Widget@ m_wList;
		Widget@ m_wTemplate;

		TestMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			Menu::Initialize(def);

			@m_wList = m_widget.GetWidgetById("testlist");
			@m_wTemplate = m_widget.GetWidgetById("template");
		}

		void Update(int dt) override
		{
			Menu::Update(dt);
		}

		bool Close() override
		{
			return false;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "add")
			{
				auto wNewItem = m_wTemplate.Clone();
				wNewItem.SetID("");
				wNewItem.m_visible = true;
				m_wList.AddChild(wNewItem);
			}
			else if (name == "delete")
			{
				if (m_wList.m_children.length() > 0)
					m_wList.m_children[m_wList.m_children.length() - 1].RemoveFromParent();
			}
			Menu::OnFunc(sender, name);
		}
	}
}
