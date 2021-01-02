namespace Menu
{
	class BackdropLayer
	{
		Widget@ m_widget;

		bool m_offsetPrevSet;
		vec2 m_offsetPrev;
		vec2 m_offset;

		vec2 m_weight;

		BackdropLayer(Widget@ w)
		{
			@m_widget = w;
		}

		void SetOffset(vec2 offset)
		{
			if (m_offsetPrevSet)
				m_offsetPrev = m_offset;
			else
				m_offsetPrev = offset;
			m_offset = offset;
			m_offsetPrevSet = true;
		}

		void Draw(int idt)
		{
			m_widget.m_offset = lerp(m_offsetPrev, m_offset, idt / 33.0f);
			m_widget.CalculateOrigin(m_widget.m_parent.m_origin, vec2(m_widget.m_parent.m_width, m_widget.m_parent.m_height));
		}
	}

	class Backdrop : IWidgetHoster
	{
		bool m_clipping;
		Rect m_clippingRect;

		array<BackdropLayer@> m_layers;

		Backdrop(GUIBuilder@ b, string fnm, string fnmParallax = "")
		{
			LoadWidget(b, fnm);

			if (m_widget is null)
				return;

			auto wContainer = m_widget.GetWidgetById("container");
			if (wContainer !is null)
			{
				SmoothWidgets(wContainer);
				for (uint i = 0; i < wContainer.m_children.length(); i++)
					m_layers.insertLast(BackdropLayer(wContainer.m_children[i]));

				auto sval = Resources::GetSValue(fnmParallax);
				if (sval !is null && sval.GetType() == SValueType::Array)
				{
					auto arr = sval.GetArray();
					for (uint i = 0; i < m_layers.length(); i++)
					{
						if (i >= arr.length())
						{
							PrintError("The parallax sval file doesn't have enough weights!");
							break;
						}
						m_layers[i].m_weight = arr[i].GetVector2();
					}
				}
			}
		}

		void SmoothWidgets(Widget@ widget)
		{
			if (widget is null)
				return;

			widget.m_pixelPerfect = false;
			for (uint i = 0; i < widget.m_children.length(); i++)
				SmoothWidgets(widget.m_children[i]);
		}

		void Update(int dt) override
		{
			if (m_layers.length() > 0)
			{
				auto gm = cast<BaseGameMode>(g_gameMode);

				vec2 mousePos = gm.m_mice[0].GetPos(0) / gm.m_wndScale;
				vec2 mouseOffset = mousePos - vec2(gm.m_wndWidth / 2.0f, gm.m_wndHeight / 2.0f);
				mouseOffset.x /= gm.m_wndWidth / 2.0f;
				mouseOffset.y /= gm.m_wndHeight / 2.0f;
				mouseOffset *= -1.0f;

				for (uint i = 0; i < m_layers.length(); i++)
				{
					auto layer = m_layers[i];
					layer.SetOffset(vec2(
						layer.m_weight.x * mouseOffset.x,
						layer.m_weight.y * mouseOffset.y
					));
				}
			}

			Invalidate();

			IWidgetHoster::Update(dt);
		}

		void DoLayout() override
		{
%PROFILE_START DoLayout
			while (m_invalidated) {
				m_invalidated = false;
				m_widget.DoLayout(vec2(), vec2(g_gameMode.m_wndWidth, g_gameMode.m_wndHeight) * GetUIScale());
			}
%PROFILE_STOP
		}

		void Draw(SpriteBatch& sb, int idt) override
		{
			sb.PushTransformation(mat::scale(mat4(), 1.0f / GetUIScale()));

			if (m_clipping)
				sb.PushClipping(m_clippingRect.GetVec4(), true);

			for (uint i = 0; i < m_layers.length(); i++)
				m_layers[i].Draw(idt);

			IWidgetHoster::Draw(sb, idt);

			if (m_clipping)
				sb.PopClipping();

			sb.PopTransformation();
		}
	}
}
