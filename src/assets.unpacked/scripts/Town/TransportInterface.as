class TransportInterface : ScriptWidgetHost
{
	string m_currentId;

	TransportInterface(SValue& sval)
	{
		super();

		m_currentId = sval.GetString();
	}

	void Initialize(bool loaded) override
	{
		Widget@ wList = m_widget.GetWidgetById("list");
		Widget@ wTemplate = m_widget.GetWidgetById("template");
		Widget@ wTemplateCurrent = m_widget.GetWidgetById("template-current");

		wList.ClearChildren();

		auto tpCurrent = TransportPoint::Get(m_currentId);
		if (tpCurrent !is null)
		{
			auto wNewCurrent = wTemplateCurrent.Clone();
			wNewCurrent.SetID("");
			wNewCurrent.m_visible = true;

			wNewCurrent.m_tooltipText = tpCurrent.GetTooltip();

			auto wName = cast<TextWidget>(wNewCurrent.GetWidgetById("name"));
			if (wName !is null)
				wName.SetText(Resources::GetString(tpCurrent.m_name));

			wList.AddChild(wNewCurrent);
		}

		for (uint i = 0; i < TransportPoint::Instances.length(); i++)
		{
			auto tp = TransportPoint::Instances[i];

			if (m_currentId == tp.m_id)
				continue;

			auto wNewItem = wTemplate.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wButton = cast<ScalableSpriteIconButtonWidget>(wNewItem.GetWidgetById("button"));
			if (wButton !is null)
			{
				wButton.SetIcon(tp.m_icon);
				wButton.SetText(Resources::GetString(tp.m_name));

				wButton.m_func = "teleport " + tp.m_id;
				wButton.m_enabled = tp.IsEnabled();

				wButton.m_tooltipText = tp.GetTooltip();
			}

			wList.AddChild(wNewItem);
		}
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "stop")
			Stop();
		else if (parse[0] == "teleport")
		{
			auto tp = TransportPoint::Get(parse[1]);
			if (tp is null)
			{
				PrintError("Unable to find transport point \"" + parse[1] + "\"");
				return;
			}

			if (tp.RequireNetsync())
			{
				auto params = tp.Teleport(GetLocalPlayer());
				(Network::Message("PlayerTransport") << tp.m_id << params).SendToAll();
			}
			else
				tp.Teleport(GetLocalPlayer());

			Stop();
		}
	}
}
