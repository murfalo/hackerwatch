class BossBarWidget : BarWidget
{
	Actor@ m_actor;

	float m_checkpoint = -1;

	BitmapFont@ m_font;
	BitmapString@ m_text;
	vec4 m_textColor;

	Sprite@ m_spriteBarInvuln;
	Sprite@ m_spriteBarCheckpoint;

	vec2 m_textOffset;

	BossBarWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		BossBarWidget@ w = BossBarWidget();
		CloneInto(w);
		return w;
	}

	void Remove() override
	{
		array<Widget@>@ arr = m_parent.m_children;

		BarWidget::Remove();

		for (uint i = 0; i < arr.length(); i++)
		{
			auto wBar = cast<BossBarWidget>(arr[i]);
			if (wBar is null)
				continue;
			wBar.UpdateAppearance();
		}
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		BarWidget::Load(ctx);

		@m_font = Resources::GetBitmapFont(ctx.GetString("text-font", false));
		m_textOffset = ctx.GetVector2("text-offset", false);

		GUIDef@ def = ctx.GetGUIDef();
		@m_spriteBarInvuln = def.GetSprite(ctx.GetString("bar-invuln", false));
		@m_spriteBarCheckpoint = def.GetSprite(ctx.GetString("bar-checkpoint", false));
	}

	Sprite@ GetBarSprite(float factor) override
	{
		if (factor < m_scale && m_actor.IsImmortal())
			return m_spriteBarInvuln;
		if (m_checkpoint >= 0 && factor > m_scale && factor > m_checkpoint)
			return m_spriteBarCheckpoint;
		return BarWidget::GetBarSprite(factor);
	}

	void Update(int dt) override
	{
		UpdateAppearance();
		BarWidget::Update(dt);
	}

	void SetText(string str)
	{
		if (str == "")
			@m_text = null;
		else
		{
			@m_text = m_font.BuildText(str);
			m_text.SetColor(m_textColor);
		}
	}

	void SetTextColor(const vec4 &in color)
	{
		m_textColor = color;

		if (m_text !is null)
			m_text.SetColor(m_textColor);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		BarWidget::DoDraw(sb, pos);

		if (m_text is null)
			return;

		sb.DrawString(pos + vec2(
			m_width / 2 - m_text.GetWidth() / 2,
			m_height / 2 - m_text.GetHeight() / 2
		) + m_textOffset, m_text);
	}

	void UpdateAppearance()
	{
		if (m_actor is null)
			return;

		if (m_actor.IsDead() || m_actor.m_unit.IsDestroyed())
		{
			Remove();
			return;
		}

		int numBars = m_parent.m_children.length() - 2; // -2 because of the 2 sprite widgets inside of boss-bars in HoH
		float barWidth = m_parent.m_width / float(numBars);

		int index = m_parent.m_children.findByRef(this) - 2;
		if (index < 0)
			return;

		m_offset.x = index * int(barWidth);
		if (index == numBars - 1)
			m_width = int(ceil(barWidth));
		else
			m_width = int(barWidth);

		//print("num bars: " + numBars + ", index: " + index);

		SetScale(m_actor.GetHealth());
		m_colorValue = vec4(1 - m_scale, m_scale, 0, 1);

		auto enemy = cast<CompositeActorBehavior>(m_actor);
		if (enemy !is null)
			SetText(formatThousands(int(round(m_actor.GetHealth() * enemy.GetMaxHp()))));
	}
}

ref@ LoadBossBarWidget(WidgetLoadingContext &ctx)
{
	BossBarWidget@ w = BossBarWidget();
	w.Load(ctx);
	return w;
}
