class MenuControlInputWidget : ButtonWidget
{
	ControlMap@ m_map;
	bool m_waitingForInput;

	bool m_axisAction;
	ControlBindingSetAxis m_axisSet;

	MenuControlInputWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		MenuControlInputWidget@ w = MenuControlInputWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		ButtonWidget::Load(ctx);

		m_borderColor = ctx.GetColorRGBA("border", false, vec4(0, 0, 0, 0));
		m_borderWidth = ctx.GetInteger("borderwidth", false, 1);

		m_canFocus = true;

		m_textColor = vec4(1, 0.753, 0, 1);
		m_textColorHover = vec4(1, 1, 1, 1);
		SetColor(m_textColor);
	}

	bool OnClick(vec2 mousePos) override
	{
		if (m_func == "")
			return false;

		auto cb = GetControlBindings();
		if (cb !is null)
		{
			auto gm = cast<MainMenu>(g_gameMode);
			if (gm !is null)
			{
				@gm.m_expectingInput = this;
				cb.ExpectInput();
			}
		}

		m_color = vec4(1, 1, 0, 0.25);

		PlaySound2D(m_pressSound);
		RectWidget::OnClick(mousePos);

		return true;
	}

	void Clear()
	{
		array<ControlMapBinding@> existingBindings = GetBindings();
		for (uint i = 0; i < existingBindings.length(); i++)
			m_map.RemoveStaging(existingBindings[i]);
	}

	array<ControlMapBinding@> GetBindings()
	{
		array<ControlMapBinding@> ret;

		array<ControlMapBinding@>@ mapBindings = m_map.GetStaging();
		for (uint i = 0; i < mapBindings.length(); i++)
		{
			ControlMapBinding@ bind = mapBindings[i];
			if (bind.Action == m_func)
			{
				if (m_axisAction && m_axisSet != bind.SetAxis)
					continue;
				ret.insertLast(bind);
			}
		}

		return ret;
	}

	void ExpectedInput(ControllerType type, int key)
	{
		if (type == ControllerType::Keyboard && (key == 42)) // Backspace
		{
			Clear();
			UpdateText();
			return;
		}

		bool isControllerMap = (m_map.Gamepad || m_map.Joystick);
		bool isControllerInput = (type != ControllerType::Keyboard && type != ControllerType::Mouse && type != ControllerType::MouseWheel);
		if (isControllerMap != isControllerInput)
		{
			// Oops, this controller type is restricted in this mapping
			UpdateText();
			return;
		}

		array<ControlMapBinding@> existingBindings = GetBindings();
		if (existingBindings.length() >= 2)
		{
			for (uint i = 0; i < existingBindings.length(); i++)
				m_map.RemoveStaging(existingBindings[i]);
		}

		if (m_axisAction)
			m_map.AddStagingAxis(type, key, m_func, m_axisSet);
		else
			m_map.AddStaging(type, key, m_func);

		UpdateText();
	}

	void UpdateText()
	{
		m_color = vec4(0, 0, 0, 0);

		string text = "";

		array<ControlMapBinding@> bindings = GetBindings();
		for (uint i = 0; i < bindings.length(); i++)
		{
			if (text != "")
				text += ", ";
			string keyID = bindings[i].ID.toUpper();
			keyID = keyID.replace("_", " ");
			text += keyID;
		}

		if (text == "")
			text = Resources::GetString(".menu.none");

		SetText(text);
	}
}

ref@ LoadMenuControlInput(WidgetLoadingContext &ctx)
{
	MenuControlInputWidget@ w = MenuControlInputWidget();
	w.Load(ctx);
	return w;
}
