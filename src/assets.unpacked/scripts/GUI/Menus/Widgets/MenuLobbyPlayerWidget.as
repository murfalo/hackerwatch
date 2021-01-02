class MenuLobbyPlayerWidget : RectWidget
{
	uint8 m_peer;

	MenuLobbyPlayerWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		MenuLobbyPlayerWidget@ w = MenuLobbyPlayerWidget();
		CloneInto(w);
		return w;
	}

	int opCmp(const Widget@ w) override
	{
		auto widget = cast<MenuLobbyPlayerWidget>(w);
		if (widget !is null)
		{
			if (m_peer < widget.m_peer)
				return -1;
			else if (m_peer > widget.m_peer)
				return 1;
		}
		return 0;
	}
}

ref@ LoadMenuLobbyPlayer(WidgetLoadingContext &ctx)
{
	MenuLobbyPlayerWidget@ w = MenuLobbyPlayerWidget();
	w.Load(ctx);
	return w;
}
