class RadialSpriteWidget : Widget
{
	Sprite@ m_sprite;
	float m_scale;

	RadialSpriteWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		RadialSpriteWidget@ w = RadialSpriteWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		auto def = ctx.GetGUIDef();

		string src = ctx.GetString("src");
		if (src != "")
			@m_sprite = def.GetSprite(src);

		m_scale = ctx.GetFloat("scale", false, 0.0f);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_scale <= 0.0f)
			return;

		sb.DrawSpriteRadial(pos, m_sprite, g_menuTime, m_scale);
	}
}

ref@ LoadRadialSpriteWidget(WidgetLoadingContext &ctx)
{
	RadialSpriteWidget@ w = RadialSpriteWidget();
	w.Load(ctx);
	return w;
}
