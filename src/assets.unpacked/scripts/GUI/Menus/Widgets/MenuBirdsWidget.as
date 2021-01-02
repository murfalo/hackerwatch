class BackdropBird
{
	Sprite@ m_sprite;

	bool m_delete;

	int m_time;
	int m_timeC;

	vec2 m_start;
	vec2 m_end;
	vec2 m_prev;

	BackdropBird(Sprite@ sprite, int time, float y, float toY)
	{
		@m_sprite = sprite;
		m_timeC = m_time = time;
		m_prev = m_start = vec2(-sprite.GetWidth(), y);
		m_end = vec2(g_gameMode.m_wndWidth, y + toY);
	}

	vec2 CurPos()
	{
		float factor = (m_time - m_timeC) / float(m_time);
		return lerp(m_start, m_end, factor);
	}

	void Update(int dt)
	{
		m_prev = CurPos();
		m_timeC -= dt;

		if (m_prev.x > g_gameMode.m_wndWidth)
			m_delete = true;
	}

	void Draw(SpriteBatch& sb, int idt, vec2 origin)
	{
		vec2 pos = lerp(origin + m_prev, origin + CurPos(), idt / 33.0f);
		sb.DrawSprite(pos, m_sprite, g_menuTime);
	}
}

class MenuBirdsWidget : Widget
{
	// Bird bird bird, bird is the word
	array<Sprite@> m_arrBirdSprites;
	array<BackdropBird@> m_arrBirds;

	int m_birdFlock;
	int m_birdFlockC;
	int m_birdC;

	// Individual bird speed
	int m_birdTime;
	int m_birdTimeRand;

	// Interval of spawning individual bird
	int m_birdNextTime;
	int m_birdNextTimeRand;

	// Number of birds in each flock
	int m_flockSize;
	int m_flockSizeRand;

	// Vertical offset of birds
	float m_towardsY;

	// Spawning interval of each flock
	int m_flockTime;
	int m_flockTimeRand;

	MenuBirdsWidget()
	{
		super();
	}

	Sprite@ GetRandomBirdSprite()
	{
		int num = randi(m_arrBirdSprites.length());
		return m_arrBirdSprites[num];
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		GUIDef@ def = ctx.GetGUIDef();

		m_birdFlockC = ctx.GetInteger("bird-flock-start-time", false, 1000);

		m_birdTime = ctx.GetInteger("bird-time");
		m_birdTimeRand = ctx.GetInteger("bird-time-rand", false);

		m_birdNextTime = ctx.GetInteger("bird-next-time");
		m_birdNextTimeRand = ctx.GetInteger("bird-next-time-rand", false);

		m_flockSize = ctx.GetInteger("flock-size");
		m_flockSizeRand = ctx.GetInteger("flock-size-rand", false);

		m_towardsY = ctx.GetFloat("towards-y", false);

		m_flockTime = ctx.GetInteger("flock-time");
		m_flockTimeRand = ctx.GetInteger("flock-time-rand", false);

		int numBirds = ctx.GetInteger("count");

		for (int i = 1; i <= numBirds; i++)
			m_arrBirdSprites.insertLast(def.GetSprite("bird-" + i));

		Widget::Load(ctx);

		m_height = ctx.GetInteger("height");
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		m_width = int(parentSz.x);

		Widget::DoLayout(origin, parentSz);
	}

	void Update(int dt) override
	{
		if (m_birdFlock > 0 && m_birdC > 0)
		{
			m_birdC -= dt;
			if (m_birdC <= 0)
			{
				int birdTime = m_birdTime + randi(m_birdTimeRand);
				m_arrBirds.insertLast(BackdropBird(GetRandomBirdSprite(), birdTime, randf() * m_height, randf() * m_towardsY));
				m_birdFlock--;
				if (m_birdFlock > 0)
					m_birdC = m_birdNextTime + randi(m_birdNextTimeRand);
				else
					m_birdFlockC = m_flockTime + randi(m_flockTimeRand);
			}
		}
		else if (m_birdFlockC > 0)
		{
			m_birdFlockC -= dt;
			if (m_birdFlockC <= 0)
			{
				m_birdFlock = m_flockSize + randi(m_flockSizeRand);
				m_birdC = m_birdNextTime + randi(m_birdNextTimeRand);
			}
		}

		for (uint i = 0; i < m_arrBirds.length(); i++)
		{
			m_arrBirds[i].Update(dt);
			if (m_arrBirds[i].m_delete)
				m_arrBirds.removeAt(i--);
		}

		Widget::Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		for (uint i = 0; i < m_arrBirds.length(); i++)
			m_arrBirds[i].Draw(sb, m_host.m_idt, pos);
	}
}

ref@ LoadMenuBirdsWidget(WidgetLoadingContext &ctx)
{
	MenuBirdsWidget@ w = MenuBirdsWidget();
	w.Load(ctx);
	return w;
}
