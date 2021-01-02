class FilteredListWidget : ScrollableWidget
{
	FilteredListWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		FilteredListWidget@ w = FilteredListWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		ScrollableWidget::Load(ctx);

		if (ctx.GetBoolean("scrolling", false, true))
			m_clipping = m_autoScroll = true;
		else
			m_clipping = m_autoScroll = false;

		LoadWidthHeight(ctx);
	}

	void ShowAll()
	{
		for (uint i = 0; i < m_children.length(); i++)
			m_children[i].m_visible = true;
	}

	int SetFilter(string filter)
	{
		if (filter == "")
		{
			ShowAll();
			return int(m_children.length());
		}

		filter = filter.toLower();

		int visible = 0;
		for (uint i = 0; i < m_children.length(); i++)
		{
			auto child = m_children[i];
			child.m_visible = child.PassesFilter(filter);
			if (child.m_visible)
				visible++;
		}
		m_autoScrollHeight = 0;

		return visible;
	}
}

ref LoadFilteredListWidget(WidgetLoadingContext &ctx)
{
	FilteredListWidget@ w = FilteredListWidget();
	w.Load(ctx);
	return w;
}
