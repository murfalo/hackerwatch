namespace Menu
{
	class InGameNotifier : IWidgetHoster
	{
		int m_showSaved;

		Widget@ m_wSaved;

		InGameNotifier()
		{
			super();
		}

		void Initialize(GUIBuilder@ b, string filename)
		{
			LoadWidget(b, filename);

			@m_wSaved = m_widget.GetWidgetById("saved");
		}

		void Update(int dt) override
		{
			IWidgetHoster::Update(dt);

			if (m_showSaved > 0)
				m_showSaved -= dt;
			m_wSaved.m_visible = (m_showSaved > 0);
		}

		void ShowSaved(int tm)
		{
			m_showSaved = tm;
		}
	}
}
