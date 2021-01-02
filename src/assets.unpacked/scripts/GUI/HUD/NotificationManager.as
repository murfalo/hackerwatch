class NotificationManager : IWidgetHoster
{
	Widget@ m_wList;
	Widget@ m_wTemplate;
	Widget@ m_wTemplateSubtext;

	array<Notification@> m_notifications;
	Notification@ m_currentNotification;

	NotificationManager(GUIBuilder@ builder)
	{
		LoadWidget(builder, "gui/notifications.gui");

		@m_wList = m_widget.GetWidgetById("notifications");
		@m_wTemplate = m_widget.GetWidgetById("template");
		@m_wTemplateSubtext = m_widget.GetWidgetById("template-subtext");
	}

	void Update(int dt) override
	{
		if (m_currentNotification is null && m_notifications.length() > 0)
		{
			@m_currentNotification = m_notifications[0];
			m_currentNotification.m_targetY = 40;
			m_notifications.removeAt(0);
		}

		if (m_currentNotification !is null)
		{
			m_currentNotification.Update(dt);
			if (m_currentNotification.m_timeC <= 0)
			{
				m_currentNotification.m_widget.RemoveFromParent();
				@m_currentNotification = null;
			}
		}

		IWidgetHoster::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (m_currentNotification !is null)
			m_currentNotification.PreDraw(idt);

		IWidgetHoster::Draw(sb, idt);
	}

	Notification@ Add(string text, vec4 colorFrom = vec4(1, 0, 0, 1), vec4 colorTo = vec4(1, 1, 1, 1))
	{
		auto wNewNotification = m_wTemplate.Clone();
		wNewNotification.m_visible = false;
		wNewNotification.SetID("");

		Notification@ notif = Notification(this, wNewNotification, text);
		notif.m_startColor = colorFrom;
		notif.m_endColor = colorTo;
		@notif.m_wTemplateSubtext = m_wTemplateSubtext;
		m_notifications.insertLast(notif);

		m_wList.AddChild(wNewNotification);

		return notif;
	}
}
