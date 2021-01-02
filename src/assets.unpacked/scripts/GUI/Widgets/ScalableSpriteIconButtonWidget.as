class ScalableSpriteIconButtonWidget : ScalableSpriteButtonWidget
{
	Sprite@ m_icon;
	int m_iconSpacing;

	bool m_iconAfterText;
	bool m_iconVisible;

	GUIDef@ m_def;

	ScalableSpriteIconButtonWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		ScalableSpriteIconButtonWidget@ w = ScalableSpriteIconButtonWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		ScalableSpriteButtonWidget::Load(ctx);

		@m_def = ctx.GetGUIDef();

		@m_icon = m_def.GetSprite(ctx.GetString("icon", false));
		m_iconSpacing = ctx.GetInteger("icon-spacing", false, 2);

		m_iconAfterText = ctx.GetBoolean("icon-after-text", false, true);
		m_iconVisible = ctx.GetBoolean("icon-visible", false, true);
	}

	void SetIcon(string icon)
	{
		@m_icon = m_def.GetSprite(icon);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		ScalableSpriteButtonWidget::DoDraw(sb, pos);

		if (m_iconVisible && m_icon !is null)
		{
			vec2 posIcon;
			if (m_iconAfterText)
			{
				posIcon = vec2(
					round(m_width / 2.0f + (m_text !is null ? m_text.GetWidth() : 0) / 2.0f + m_iconSpacing),
					round(m_height / 2.0f - m_icon.GetHeight() / 2.0f + m_textOffset.y)
				);
			}
			else
			{
				posIcon = vec2(
					round(m_width - m_icon.GetWidth() - m_iconSpacing),
					round(m_height / 2.0f - m_icon.GetHeight() / 2.0f + m_textOffset.y)
				);
			}

			sb.DrawSprite(pos + posIcon, m_icon, g_menuTime);
		}
	}
}

ref@ LoadScalableSpriteIconButtonWidget(WidgetLoadingContext &ctx)
{
	ScalableSpriteIconButtonWidget@ w = ScalableSpriteIconButtonWidget();
	w.Load(ctx);
	return w;
}
