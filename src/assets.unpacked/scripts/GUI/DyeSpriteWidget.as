class DyeSpriteWidget : SpriteWidget
{
	array<Materials::IDyeState@> m_dyeStates;

	DyeSpriteWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		DyeSpriteWidget@ w = DyeSpriteWidget();
		CloneInto(w);
		return w;
	}

	void SetDyes(array<Materials::Dye@> dyes)
	{
		m_dyeStates = Materials::MakeDyeStates(dyes);
	}

	void Update(int dt) override
	{
		SpriteWidget::Update(dt);

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_dyeStates[i].Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_multiColors.length() != m_dyeStates.length())
			m_multiColors.resize(m_dyeStates.length());

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_multiColors[i] = m_dyeStates[i].GetShades(m_host.m_idt);

		SpriteWidget::DoDraw(sb, pos);
	}
}

ref@ LoadDyeSpriteWidget(WidgetLoadingContext &ctx)
{
	DyeSpriteWidget@ w = DyeSpriteWidget();
	w.Load(ctx);
	return w;
}
