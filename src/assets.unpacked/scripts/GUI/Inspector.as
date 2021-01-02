class WidgetInspector
{
	Widget@ m_currentWidget;

	WidgetInspector()
	{
	}

	void Update(int dt)
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm is null)
			return;

		@m_currentWidget = null;

		for (uint i = 0; i < gm.m_widgetRoots.length(); i++)
		{
			auto w = gm.m_widgetRoots[i].m_widget;
			while (w.m_hovering)
			{
				bool found = false;

				for (uint j = 0; j < w.m_children.length(); j++)
				{
					if (w.m_children[j].m_hovering)
					{
						@w = w.m_children[j];
						found = true;
					}
				}

				if (!found)
					break;
			}

			if (w.m_hovering)
				@m_currentWidget = w;
		}
	}

	string GetWidgetDebugName(Widget@ w)
	{
		string ret = Reflect::GetTypeName(w);
		if (w.m_id != "")
			ret += " \\cffffff\"" + w.m_id + "\"";
		return ret;
	}

	void Draw(SpriteBatch& sb, int idt)
	{
		if (m_currentWidget is null)
			return;

		vec4 p = m_currentWidget.GetRectangle().GetVec4();
		sb.DrawSprite(null, p, p, vec4(1, 1, 1, 0.1f));

		string textDebug = "";

		auto w = m_currentWidget;
		do
		{
			string part = GetWidgetDebugName(w);

			if (w is m_currentWidget)
				part = "\\ceeeeee" + part;
			else
				part = "\\caaaaaa" + part;

			textDebug = part + "\n" + textDebug;
			@w = w.m_parent;
		} while(w !is null);

		for (uint i = 0; i < m_currentWidget.m_children.length(); i++)
			textDebug += "  \\caaaaaa" + GetWidgetDebugName(m_currentWidget.m_children[i]) + "\n";

		textDebug = "\\cff0000Widget tree\n" + textDebug;

		textDebug += "\n\\cff0000Properties\n";

		textDebug += "\\caaaaaaOrigin: \\cffffff" + m_currentWidget.m_origin + "\n";
		textDebug += "\\caaaaaaAnchor: \\cffffff" + m_currentWidget.m_anchor + "\n";
		textDebug += "\\caaaaaaSize: \\cffffff(" + m_currentWidget.m_width + ", " + m_currentWidget.m_height + ")\n";

		if (m_currentWidget.m_widthScalar != -1 || m_currentWidget.m_heightScalar != -1)
			textDebug += "\\caaaaaaSize scalar: \\cffffff(" + m_currentWidget.m_widthScalar + ", " + m_currentWidget.m_heightScalar + ")\n";

		vec2 originParentOffset = m_currentWidget.m_origin;
		if (m_currentWidget.m_parent !is null)
			originParentOffset -= m_currentWidget.m_parent.m_origin;
		textDebug += "\\caaaaaaOffset: \\cffffff" + originParentOffset + "\n";

		textDebug += "\\caaaaaaCan focus: \\cffffff" + m_currentWidget.m_canFocus + "\n";

		if (m_currentWidget.m_tooltipText != "" || m_currentWidget.m_tooltipTitle != "")
		{
			textDebug += "\\caaaaaaTooltip:\\cffffff\n";
			textDebug += "  \\caaaaaatitle: \"" + m_currentWidget.m_tooltipTitle + "\"\n";
			for (uint i = 0; i < m_currentWidget.m_tooltipSubtexts.length(); i++)
				textDebug += "  \\caaaaaasub: \"" + m_currentWidget.m_tooltipSubtexts[i].m_text + "\"\n";
			textDebug += "  \\caaaaaatext: \"" + m_currentWidget.m_tooltipText + "\"\n";
		}

		auto wSprite = cast<SpriteWidget>(m_currentWidget);
		if (wSprite !is null)
		{
			textDebug += "\n\\cff0000Sprite properties\n";
			textDebug += "\\caaaaaaSource: \\cffffff\"" + wSprite.m_spriteSrc + "\"\n";
			if (wSprite.m_sprite !is null)
				textDebug += "\\caaaaaaSprite size: \\cffffff(" + wSprite.m_sprite.GetWidth() + ", " + wSprite.m_sprite.GetHeight() + ")\n";
			if (wSprite.m_ssprite !is null)
				textDebug += "\\caaaaaaScriptSprite size: \\cffffff(" + wSprite.m_ssprite.GetWidth() + ", " + wSprite.m_ssprite.GetHeight() + ")\n";
			if (wSprite.m_sprite is null && wSprite.m_ssprite is null)
				textDebug += "\\caaaaaa(There is no sprite!)\n";
		}

		auto wText = cast<TextWidget>(m_currentWidget);
		if (wText !is null)
		{
			textDebug += "\n\\cff0000Text properties\n";
			textDebug += "\\caaaaaaText: \\cffffff\"" + wText.m_str + "\"\n";
			textDebug += "\\caaaaaaFont: \\cffffff\"" + wText.m_fontName + "\"";
		}

		auto wScrollable = cast<ScrollableWidget>(m_currentWidget);
		if (wScrollable !is null)
		{
			textDebug += "\n\\cff0000Scrollable properties\n";
			textDebug += "\\caaaaaaScrollable: \\cffffff" + wScrollable.m_autoScroll + "\n";
			textDebug += "\\caaaaaaHeight: \\cffffff" + wScrollable.m_autoScrollHeight + "\n";
			textDebug += "\\caaaaaaValue: \\cffffff" + wScrollable.m_autoScrollValue + "\n";
		}

		auto wClip = cast<ClipWidget>(m_currentWidget);
		if (wClip !is null)
		{
			textDebug += "\n\\cff0000Clip properties\n";
			textDebug += "\\caaaaaaClipping: \\cffffff" + wClip.m_clipping + "\n";
			textDebug += "\\caaaaaaPadding: \\cffffff" + wClip.m_clipPadding + "\n";
		}

		BitmapFont@ fontDebug = Resources::GetBitmapFont("system/system_small.fnt");
		BitmapString@ text = fontDebug.BuildText(textDebug);

		vec2 pos;

		if (g_gameMode !is null)
		{
			pos = vec2(
				g_gameMode.m_wndWidth - 10 - text.GetWidth(),
				g_gameMode.m_wndHeight - 10 - text.GetHeight() - (98 / g_gameMode.m_wndScale) /* steam overlay notification */
			);
		}

		sb.FillRectangle(vec4(pos.x, pos.y, text.GetWidth(), text.GetHeight()), vec4(0, 0, 0, 0.7f));
		sb.DrawString(pos, text);
	}
}
