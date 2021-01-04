interface IBuffWidgetInfo
{
	ScriptSprite@ GetBuffIcon();
	int GetBuffIconDuration();
	int GetBuffIconMaxDuration();
	int GetBuffIconCount();
}

class BuffWidget : Widget
{
	IBuffWidgetInfo@ m_buff;

	TextWidget@ m_wStackText;

	BuffWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		BuffWidget@ w = BuffWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		Widget::Load(ctx);

		m_width = 12;
		m_height = 12;
	}

	void AddedToParent() override
	{
		@m_wStackText = cast<TextWidget>(GetWidgetById("stack-count"));
	}

	void Update(int dt) override
	{
		Widget::Update(dt);

		if (m_buff is null)
			return;

		if (m_buff.GetBuffIconDuration() <= 0)
		{
			RemoveFromParent();
			return;
		}

		int count = m_buff.GetBuffIconCount();
		if (count == 0)
		{
			RemoveFromParent();
			return;
		}
		else if (count != -1 && m_wStackText !is null)
		{
			m_wStackText.m_visible = true;
			m_wStackText.SetText("" + count);
		}
		else if (count == -1 && m_wStackText !is null)
			m_wStackText.m_visible = false;
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_buff is null)
			return;

		auto icon = m_buff.GetBuffIcon();
		if (icon is null)
			return;

		sb.EnableColorize(vec4(0, 0, 0, 1), vec4(0.125, 0.125, 0.125, 1), vec4(0.25, 0.25, 0.25, 1));
		icon.Draw(sb, pos, g_menuTime, vec4(0.5, 0.5, 0.5, 1));
		sb.DisableColorize();

		float radius = m_buff.GetBuffIconDuration() / float(m_buff.GetBuffIconMaxDuration());
		icon.DrawRadial(sb, pos, radius, g_menuTime);
	}
}

ref@ LoadBuffWidget(WidgetLoadingContext &ctx)
{
	BuffWidget@ w = BuffWidget();
	w.Load(ctx);
	return w;
}
