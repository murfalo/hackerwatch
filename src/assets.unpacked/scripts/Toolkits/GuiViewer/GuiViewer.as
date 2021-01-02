%if TOOLKIT
namespace Toolkits
{
	[Toolkit]
	class GuiViewer : IWidgetHoster
	{
		ToolkitScript@ m_script;
		ToolkitGameMode@ m_gm;

		MarkovName@ m_randomNameGen;

		GUIDef@ m_def;
		GUIBuilder m_builder;

		vec2 m_mousePos;
		vec2 m_mouseWheelDelta;

		array<Widget@> m_widgetsWithIds;

		Widget@ m_wCurrentList;
		Widget@ m_wCurrentTemplate;

		WidgetInspector@ m_widgetInspector;

		string m_listId = "list";
		string m_templateId = "template";
		int m_numItems;

		float m_scale = 2.0f;
		vec2 m_offset;

		GuiViewer(ToolkitScript@ script)
		{
			@g_gameMode = @m_gm = ToolkitGameMode();
			@m_script = script;

			WidgetProducers::LoadBase(m_builder);
			WidgetProducers::LoadIngame(m_builder);
			WidgetProducers::LoadMainMenu(m_builder);

			array<string> names = {
				"Alkmaar", "Amstelveen", "Amsterdam", "Den Helder", "Edam", "Enkhuizen", "Haarlem", "Heerhugowaard", "Hilversum", "Hoofddorp", "Hoorn",
				"Laren", "Medemblik", "Monnickendam", "Muiden", "Naarden", "Purmerend", "Schagen", "Velsen", "Volendam", "Weesp", "Zaanstad", "Almelo",
				"Blokzijl", "Deventer", "Enschede", "Genemuiden", "Hasselt", "Hengelo", "Kampen", "Oldenzaal", "Steenwijk", "Vollenhove", "Zwolle",
				"Alphen aan den Rijn", "Delft", "Dordrecht", "Gorinchem", "Gouda", "Leiden", "Rotterdam", "Spijkenisse", "The Hague", "Zoetermeer",
				"Amersfoort", "Baarn", "Bunschoten", "Eemnes", "Hagestein", "Houten", "Leerdam", "Montfoort", "Nieuwegein", "Oudewater", "Rhenen",
				"Utrecht", "Veenendaal", "Vianen", "Wijk bij Duurstede", "Woerden", "IJsselstein", "Zeist", "Arnemuiden", "Goes", "Hulst", "Middelburg",
				"Sluis", "Terneuzen", "Veere", "Vlissingen", "Zierikzee", "Heiloo"
			};
			@m_randomNameGen = MarkovName(names);

			@m_widgetInspector = WidgetInspector();
		}

		void Save(SValueBuilder@ builder)
		{
			builder.PushString("file", m_filenameDef);

			builder.PushString("list-id", m_listId);
			builder.PushString("template-id", m_templateId);
			builder.PushInteger("num-items", m_numItems);

			builder.PushFloat("scale", m_scale);
			builder.PushVector2("offset", m_offset);
		}

		void Load(SValue@ data)
		{
			string filename = GetParamString(UnitPtr(), data, "file", false, m_filenameDef);
			if (filename != "")
				LoadGUI(filename);

			m_listId = GetParamString(UnitPtr(), data, "list-id", false, m_listId);
			m_templateId = GetParamString(UnitPtr(), data, "template-id", false, m_templateId);
			m_numItems = GetParamInt(UnitPtr(), data, "num-items", false, m_numItems);

			m_scale = GetParamFloat(UnitPtr(), data, "scale", false, m_scale);
			m_offset = GetParamVec2(UnitPtr(), data, "offset", false, m_offset);

			UpdateSize();
			Invalidate();

			UpdateListItems(m_numItems);
		}

		void UpdateSize()
		{
			vec2 size = Window::GetWindowSize();
			float scale = m_gm.m_wndScale = m_scale;
			float width = m_gm.m_wndWidth = int(size.x / m_gm.m_wndScale);
			float height = m_gm.m_wndHeight = int(size.y / m_gm.m_wndScale);
		}

		void ResourcesToReload(array<string>@ res)
		{
			res.insertLast(m_filenameDef);
		}

		void OnResourcesReloaded()
		{
			int numItems = m_numItems;

			LoadGUI(m_filenameDef);

			UpdateListItems(numItems);
		}

		void IterateForIds(Widget@ w)
		{
			if (w.m_id != "")
				m_widgetsWithIds.insertLast(w);

			if (!w.m_visible)
				return;

			for (uint i = 0; i < w.m_children.length(); i++)
				IterateForIds(w.m_children[i]);
		}

		void LoadGUI(const string &in guiPath)
		{
			@m_def = LoadWidget(m_builder, guiPath);
			if (m_widget is null)
				return;

			UpdateSize();
			Invalidate();

			m_widgetsWithIds.removeRange(0, m_widgetsWithIds.length());
			IterateForIds(m_widget);

			m_numItems = 0;

			@m_wCurrentList = m_widget.GetWidgetById(m_listId);
			@m_wCurrentTemplate = m_widget.GetWidgetById(m_templateId);

			m_script.UpdateFileWatch();
		}

		string GetTextHint(Widget@ w)
		{
			switch (w.m_hint)
			{
				case WidgetHint::NumberLow: return formatThousands(randi(10));
				case WidgetHint::NumberMid: return formatThousands(randi(1000));
				case WidgetHint::NumberHigh: return formatThousands(randi(100000));
				case WidgetHint::Name: return m_randomNameGen.GenerateName();
				case WidgetHint::Resource: return Resources::GetString(w.m_hintResource);
			}
			return "??";
		}

		vec4 GetColorHint()
		{
			vec4 ret;
			ret.x = randf();
			ret.y = randf();
			ret.z = randf();
			ret.w = 1.0f;
			return ret;
		}

		void FillTemplateInfo(Widget@ w)
		{
			if (w.m_hint != WidgetHint::None)
			{
				auto wText = cast<TextWidget>(w);
				if (wText !is null)
					wText.SetText(GetTextHint(wText));

				auto wCheckbox = cast<CheckBoxWidget>(w);
				if (wCheckbox !is null)
					wCheckbox.SetText(GetTextHint(wCheckbox));

				auto wButton = cast<ScalableSpriteButtonWidget>(w);
				if (wButton !is null)
					wButton.SetText(GetTextHint(wButton));

				auto wSprite = cast<SpriteWidget>(w);
				if (wSprite !is null && wSprite.m_hint == WidgetHint::Resource)
					wSprite.SetSprite(wSprite.m_hintResource);

				auto wUnit = cast<UnitWidget>(w);
				if (wUnit !is null && wUnit.m_hint == WidgetHint::Resource)
				{
					wUnit.ClearUnits();

					auto prod = Resources::GetUnitProducer(wUnit.m_hintResource);
					if (prod !is null)
					{
						auto scenes = prod.GetUnitScenes();
						int sceneIndex = randi(scenes.length());

						wUnit.AddUnit(scenes[sceneIndex]);
					}
				}
			}

			for (uint i = 0; i < w.m_children.length(); i++)
				FillTemplateInfo(w.m_children[i]);
		}

		void UpdateListItems(int newItemCount)
		{
			if (m_wCurrentTemplate is null)
			{
				m_numItems = 0;
				return;
			}

			if (newItemCount < 0)
				newItemCount = 0;

			while (m_numItems < newItemCount)
			{
				auto wNewItem = m_wCurrentTemplate.Clone();
				wNewItem.SetID("");
				wNewItem.m_visible = true;
				m_wCurrentList.AddChild(wNewItem);

				FillTemplateInfo(wNewItem);

				m_numItems++;
			}

			while (m_numItems > newItemCount)
			{
				int lastIndex = m_wCurrentList.m_children.length() - 1;
				m_wCurrentList.m_children[lastIndex].RemoveFromParent();

				m_numItems--;
			}
		}

		void Update(int dt) override
		{
			UpdateSize();

			if (m_widget !is null)
			{
				IWidgetHoster::Update(dt);

				UpdateInput(
					vec2(),
					vec2(m_gm.m_wndWidth, m_gm.m_wndHeight),
					vec3(
						(m_mousePos.x - m_offset.x) / m_scale,
						(m_mousePos.y - m_offset.y) / m_scale,
						m_mouseWheelDelta.y
					)
				);
			}
			m_mouseWheelDelta = vec2();
		}

		void OnMouseDown(vec2 pos, int button)
		{
			m_mousePos = pos;

			Widget@ wb = m_gm.m_widgetUnderCursor;
			if (wb !is null && wb.m_hovering)
			{
				while (wb !is null)
				{
					vec2 mousePosRel = (m_mousePos / m_gm.m_wndScale) - wb.m_origin;
					if (wb.OnMouseDown(mousePosRel))
						break;
					@wb = wb.m_parent;
				}
			}
		}

		void OnMouseUp(vec2 pos, int button)
		{
			m_mousePos = pos;

			Widget@ wb = m_gm.m_widgetUnderCursor;
			if (wb !is null && wb.m_hovering)
			{
				while (wb !is null)
				{
					bool propogate = true;
					vec2 mousePosRel = (m_mousePos / m_gm.m_wndScale) - wb.m_origin;
					if (wb.m_canDoubleClick && wb.m_doubleClickTime > 0 && (int(wb.m_doubleClickPos.x) == int(mousePosRel.x) && int(wb.m_doubleClickPos.y) == int(mousePosRel.y)))
					{
						wb.m_doubleClickTime = 0;
						propogate = !wb.OnDoubleClick(mousePosRel);
					}
					else
					{
						wb.m_doubleClickTime = g_doubleClickTime;
						wb.m_doubleClickPos = mousePosRel;
						propogate = !wb.OnClick(mousePosRel);
					}
					if (wb.OnMouseUp(mousePosRel) || !propogate)
						break;
					@wb = wb.m_parent;
				}
			}
		}

		void OnMouseMove(vec2 pos)
		{
			m_mousePos = pos;
		}

		void OnMouseWheel(vec2 delta)
		{
			m_mouseWheelDelta = delta;
		}

		void Render(SpriteBatch& sb, int idt)
		{
			mat4 tform;
			tform = mat::translate(tform, vec3(m_offset.x, m_offset.y, 0.0f));
			tform = mat::scale(tform, m_scale);
			sb.PushTransformation(tform);

			if (m_widget !is null)
			{
				Draw(sb, idt);
				m_widgetInspector.Draw(sb, idt);
			}

			sb.PopTransformation();

			if (UI::Begin("GUI", UI::WindowFlags(0)))
			{
				if (UI::Button("Invalidate"))
					Invalidate();

				float newScale = UI::InputFloat("Scale", m_scale, 1.0f);
				if (newScale != m_scale)
				{
					m_scale = newScale;
					if (m_scale < 1.0f)
						m_scale = 1.0f;

					UpdateSize();
					Invalidate();
				}

				vec2 windowSize = Window::GetWindowSize();
				m_offset = UI::SliderFloat2("Offset", m_offset,
					min(-windowSize.x, -windowSize.y),
					max(windowSize.x, windowSize.y)
				);

				if (UI::BeginCombo("List", m_wCurrentList !is null ? m_wCurrentList.m_id : ""))
				{
					for (uint i = 0; i < m_widgetsWithIds.length(); i++)
					{
						auto w = m_widgetsWithIds[i];
						if (UI::Selectable(w.m_id, w is m_wCurrentList))
						{
							if (m_wCurrentList !is w && m_wCurrentList !is null)
								m_wCurrentList.ClearChildren();

							@m_wCurrentList = w;
							m_listId = w.m_id;

							m_numItems = m_wCurrentList.m_children.length();
							UpdateListItems(m_numItems);
						}

						if (w is m_wCurrentList)
							UI::SetItemDefaultFocus();
					}
					UI::EndCombo();
				}

				if (UI::BeginCombo("Template", m_wCurrentTemplate !is null ? m_wCurrentTemplate.m_id : ""))
				{
					for (uint i = 0; i < m_widgetsWithIds.length(); i++)
					{
						auto w = m_widgetsWithIds[i];
						if (UI::Selectable(w.m_id, w is m_wCurrentTemplate))
						{
							@m_wCurrentTemplate = w;
							m_templateId = w.m_id;
						}

						if (w is m_wCurrentTemplate)
							UI::SetItemDefaultFocus();
					}
					UI::EndCombo();
				}

				if (m_wCurrentList !is null && m_wCurrentTemplate !is null)
				{
					int newItemCount = UI::InputInt("Number of items", m_numItems);
					UpdateListItems(newItemCount);
				}
			}
			UI::End();

			@m_widgetInspector.m_currentWidget = null;

			if (UI::Begin("Inspector", UI::WindowFlags(0)))
			{
				g_debugWidgets = UI::Checkbox("Debug widgets", g_debugWidgets);
				RenderInspect(m_widget);
			}
			UI::End();
		}

		void RenderInspect(Widget@ widget, const string &in label = "")
		{
			if (widget is null)
				return;

			string treeLabel = Reflect::GetTypeName(widget);

			if (widget.m_id != "")
				treeLabel += " (\"" + widget.m_id + "\")";

			if (label != "")
				treeLabel += " " + label;

			bool treeIsOpen = UI::TreeNode(treeLabel);

			if (UI::IsItemHovered())
			{
				@m_widgetInspector.m_currentWidget = widget;
				/*
				UI::BeginTooltip();
				UI::Text("Size: " + widget.m_width + ", " + widget.m_height);
				UI::EndTooltip();
				*/
			}

			if (treeIsOpen)
			{
				for (uint i = 0; i < widget.m_children.length(); i++)
				{
					auto child = widget.m_children[i];
					RenderInspect(child, "index " + i);
				}
				UI::TreePop();
			}
		}

		void RenderMenu()
		{
			if (UI::BeginMenu("GUI Viewer"))
			{
				if (UI::MenuItem("Open GUI"))
				{
					string guiPath;
					if (Window::OpenFileDialog("gui", guiPath))
						LoadGUI(guiPath);
				}
				UI::EndMenu();
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			print("OnFunc: \"" + name + "\"");
		}
	}
}
%endif
