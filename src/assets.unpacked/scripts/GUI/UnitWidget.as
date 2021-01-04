class UnitWidgetScene
{
	UnitScene@ m_scene;
	vec2 m_offset;
}

class UnitWidget : Widget
{
	array<UnitWidgetScene@> m_scenes;
	int m_timeOffset;

	vec2 m_globalOffset;

	array<array<vec4>> m_multiColors;
	array<Materials::IDyeState@> m_dyeStates;

	UnitWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		UnitWidget@ w = UnitWidget();
		CloneInto(w);
		return w;
	}

	void ClearUnits()
	{
		m_scenes.removeRange(0, m_scenes.length());
	}

	void AddUnit(UnitWidgetScene@ uws)
	{
		m_scenes.insertLast(uws);
	}

	UnitWidgetScene@ AddUnit(UnitScene@ scene)
	{
		UnitWidgetScene@ uws = UnitWidgetScene();
		@uws.m_scene = scene;
		m_scenes.insertLast(uws);
		return uws;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		AddUnit(ctx.GetString("unit", false), ctx.GetString("scene", false));

		m_globalOffset = ctx.GetVector2("unit-offset", false);

		m_timeOffset = g_menuTime;

		LoadWidthHeight(ctx);

		Widget::Load(ctx);
	}

	UnitWidgetScene@ AddUnit(string prodName, string scene)
	{
		if (prodName == "")
			return null;

		UnitProducer@ prod = Resources::GetUnitProducer(prodName);
		if (prod is null)
		{
			PrintError("Unit producer is null for \"" + prodName + "\"");
			return null;
		}

		UnitWidgetScene@ uws = UnitWidgetScene();
		@uws.m_scene = prod.GetUnitScene(scene);
		if (uws.m_scene is null)
		{
			PrintError("Scene is null for \"" + prodName + "\": \"" + scene + "\"");
			return null;
		}

		m_scenes.insertLast(uws);

		return uws;
	}

	void Update(int dt) override
	{
		Widget::Update(dt);

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_dyeStates[i].Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_dyeStates.length() != m_multiColors.length())
			m_multiColors.resize(m_dyeStates.length());

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_multiColors[i] = m_dyeStates[i].GetShades(m_host.m_idt);

		for (uint i = 0; i < m_multiColors.length(); i++)
		{
			array<vec4> colors = m_multiColors[i];
			sb.SetMultiColor(i, colors[0], colors[1], colors[2]);
		}

		for (uint i = 0; i < m_scenes.length(); i++)
		{
			UnitWidgetScene@ uws = m_scenes[i];

			vec2 size = vec2(m_width, m_height);
			sb.DrawUnitScene(pos + size / 2 + uws.m_offset + m_globalOffset, size, uws.m_scene, g_menuTime - m_timeOffset);
		}

		if (m_multiColors.length() > 0)
			sb.DisableMultiColor();
	}
}

ref@ LoadUnitWidget(WidgetLoadingContext &ctx)
{
	UnitWidget@ w = UnitWidget();
	w.Load(ctx);
	return w;
}
