class Notification
{
	NotificationManager@ m_manager;
	Widget@ m_widget;
	Widget@ m_wTemplateSubtext;

	int m_delayC = 200;
	int m_timeC = 4500;

	float m_targetY = 0;
	float m_newY = 0;
	float m_prevY = 0;
	bool m_animated = false;

	vec4 m_startColor;
	vec4 m_endColor;

	int m_originalHeight;

	Notification(NotificationManager@ manager, Widget@ widget, string text)
	{
		@m_manager = manager;
		@m_widget = widget;

		auto wText = cast<TextWidget>(m_widget.GetWidgetById("text"));
		if (wText !is null)
		{
			wText.SetText(text);
			m_widget.m_width = wText.m_width + 25 * 2;
			m_widget.m_height = wText.m_height + 10;
			m_originalHeight = m_widget.m_height;
		}
	}

	vec4 GetColor()
	{
		int interval = 500;
		int current = (3000 - m_timeC) % (interval * 2);
		float factor = easeQuad((current % interval) / float(interval));
		if (current >= interval)
			return lerp(m_startColor, m_endColor, factor);
		return lerp(m_endColor, m_startColor, factor);
	}

	void AddSubtext(string icon, string subtext)
	{
		auto wList = m_widget.GetWidgetById("subtexts");

		auto newSubtext = m_wTemplateSubtext.Clone();
		newSubtext.SetID("");
		newSubtext.m_visible = true;

		int extraHeight = 15;

		if (icon != "")
		{
			auto wIcon = cast<SpriteWidget>(newSubtext.GetWidgetById("icon"));
			if (wIcon !is null)
			{
				wIcon.SetSprite(icon);
				extraHeight = max(extraHeight, wIcon.m_height + 3);
			}
		}

		auto wText = cast<TextWidget>(newSubtext.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(subtext));

		wList.AddChild(newSubtext);

		// Approximate width for all subtexts
		float approxWidth = wList.m_padding.x;
		for (uint i = 0; i < wList.m_children.length(); i++)
		{
			if (i > 0)
				approxWidth += wList.m_spacing;

			auto child = wList.m_children[i];
			for (uint j = 0; j < child.m_children.length(); j++)
			{
				if (j > 0)
					approxWidth += child.m_spacing;
				approxWidth += child.m_children[j].m_width;
			}
		}

		m_widget.m_width = max(m_widget.m_width, int(approxWidth) + 25 * 2);
		m_widget.m_height = max(m_widget.m_height, m_originalHeight + extraHeight);
	}

	void Update(int dt)
	{
		if (m_delayC > 0)
		{
			m_delayC -= dt;
			if (m_delayC <= 0)
				PlaySound2D(Resources::GetSoundEvent("event:/ui/announce"));
			else
				return;
		}

		m_widget.m_visible = true;

		m_timeC -= dt;
		if (m_timeC <= 0)
			return;

		float diff = m_targetY - m_widget.m_offset.y;
		if (diff > 0.5f)
		{
			m_prevY = m_widget.m_offset.y;
			m_newY = m_widget.m_offset.y + (diff * 0.2f);
			m_animated = true;
		}
		else
			m_animated = false;
	}

	void PreDraw(int idt)
	{
		m_widget.m_offset.y = lerp(m_prevY, m_newY, idt / 33.0f);

		auto wRect = cast<RectWidget>(m_widget);
		if (wRect !is null)
			wRect.m_color = tocolor(GetColor());

		if (m_animated)
		{
			auto wParent = m_widget.m_parent;
			m_widget.DoLayout(vec2(), vec2(wParent.m_width, wParent.m_height));
		}
	}
}
