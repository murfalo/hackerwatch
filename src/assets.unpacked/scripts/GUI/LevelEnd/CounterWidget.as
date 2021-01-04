enum CounterFormat
{
	Normal,
	Time,
	TimeFractions
}

class CounterWidget : TextWidget
{
	float m_currentCount;
	float m_currentFinish;

	int m_countInterval;
	int m_countIntervalC;

	float m_step;

	string m_strBefore;
	string m_strAfter;

	CounterFormat m_format;

	CounterWidget(BitmapFont@ font)
	{
		super();
		@m_font = font;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		m_currentCount = ctx.GetFloat("count", false);
		m_currentFinish = ctx.GetFloat("finish", false);

		m_countInterval = ctx.GetInteger("interval", false, 1);
		m_step = ctx.GetFloat("step", false, 1);

		m_strBefore = Resources::GetString(ctx.GetString("before", false));
		m_strAfter = Resources::GetString(ctx.GetString("after", false));

		string format = ctx.GetString("format", false, "normal");
		     if (format == "time") m_format = CounterFormat::Time;
		else if (format == "timefractions") m_format = CounterFormat::TimeFractions;

		if (m_currentCount != m_currentFinish)
			m_countIntervalC = m_countInterval;

		TextWidget::Load(ctx);

		UpdateText();
	}

	void Update(int dt) override
	{
		if (m_countIntervalC > 0)
		{
			m_countIntervalC -= dt;
			if (m_countIntervalC <= 0)
			{
				if (m_currentCount < m_currentFinish)
				{
					m_currentCount += m_step;
					if (m_currentCount >= m_currentFinish)
						m_currentCount = m_currentFinish;
					else
						m_countIntervalC = m_countInterval;
				}
				else if (m_currentCount > m_currentFinish)
				{
					m_currentCount -= m_step;
					if (m_currentCount <= m_currentFinish)
						m_currentCount = m_currentFinish;
					else
						m_countIntervalC = m_countInterval;
				}
				UpdateText();
			}
		}

		TextWidget::Update(dt);
	}

	void UpdateText()
	{
		string str;

		if (m_format == CounterFormat::Normal)
		{
			str = "" + m_currentCount;
		}
		else if (m_format == CounterFormat::Time || m_format == CounterFormat::TimeFractions)
		{
			str = formatTime(m_currentCount, m_format == CounterFormat::TimeFractions);
		}

		SetText(m_strBefore + str + m_strAfter);
	}

	void SetCounter(float start, float end)
	{
		m_currentCount = start;
		m_currentFinish = end;
		m_countIntervalC = m_countInterval;
		UpdateText();
	}

	void SetCount(float count, bool instant = false)
	{
		m_currentFinish = count;
		if (instant)
			m_currentCount = count;
		else
			m_countIntervalC = m_countInterval;
		UpdateText();
	}
}

ref@ LoadCounterWidget(WidgetLoadingContext &ctx)
{
	BitmapFont@ font = Resources::GetBitmapFont(ctx.GetString("font"));
	CounterWidget@ w = CounterWidget(font);
	w.Load(ctx);
	return w;
}
