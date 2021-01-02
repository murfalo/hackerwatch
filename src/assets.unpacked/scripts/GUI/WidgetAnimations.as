class WidgetAnimation
{
	Widget@ m_widget;

	string m_key;

	int m_maxTime;
	int m_time;
	int m_timeLast;

	EasingFunction m_easing = EasingFunction::Linear;

	WidgetAnimation(string key, int maxTime, int delay = 0)
	{
		m_key = key;
		m_maxTime = max(1, maxTime);
		m_timeLast = -delay;
		m_time = -delay;
	}

	WidgetAnimation@ WithEasing(EasingFunction func)
	{
		m_easing = func;
		return this;
	}

	void Update(int dt)
	{
		m_timeLast = m_time;
		m_time += dt;
		if (m_time > m_maxTime)
			m_time = m_maxTime;
	}

	void PreRender(int idt)
	{
		if (m_time < 0)
			return;

		float mul = 1;
		if (!IsDone())
			mul = idt / 33.0;

		float scalar = lerp(m_timeLast, m_time, mul) / float(m_maxTime);
		scalar = ease(scalar, m_easing);

		Apply(scalar);
	}

	void Finish()
	{
		m_time = m_maxTime;
		Apply(1);
	}

	void Apply(float scalar)
	{
		m_widget.AnimateSet(m_key, scalar);
	}

	bool IsDone()
	{
		return m_time == m_maxTime;
	}
}

class WidgetVec4Animation : WidgetAnimation
{
	vec4 m_start;
	vec4 m_end;

	WidgetVec4Animation(string key, vec4 start, vec4 end, int maxTime, int delay = 0)
	{
		super(key, maxTime, delay);
		m_start = start;
		m_end = end;
	}

	void Apply(float scalar) override
	{
		vec4 lerped = lerp(m_start, m_end, scalar);
		m_widget.AnimateSet(m_key, lerped);
	}
}

class WidgetVec2Animation : WidgetAnimation
{
	vec2 m_start;
	vec2 m_end;

	WidgetVec2Animation(string key, vec2 start, vec2 end, int maxTime, int delay = 0)
	{
		super(key, maxTime, delay);
		m_start = start;
		m_end = end;
	}

	void Apply(float scalar) override
	{
		vec2 lerped = lerp(m_start, m_end, scalar);
		m_widget.AnimateSet(m_key, lerped);
	}
}

class WidgetVec2BezierAnimation : WidgetAnimation
{
	vec2 m_start;
	vec2 m_bezier;
	vec2 m_end;

	WidgetVec2BezierAnimation(string key, vec2 start, vec2 bezier, vec2 end, int maxTime, int delay = 0)
	{
		super(key, maxTime, delay);
		m_start = start;
		m_bezier = bezier;
		m_end = end;
	}

	void Apply(float scalar) override
	{
		vec2 a = lerp(m_start, m_bezier, scalar);
		vec2 b = lerp(m_bezier, m_end, scalar);
		vec2 lerped = lerp(a, b, scalar);
		m_widget.AnimateSet(m_key, lerped);
	}
}

class WidgetBoolAnimation : WidgetAnimation
{
	bool m_set;

	WidgetBoolAnimation(string key, bool setTo, int delay = 0)
	{
		super(key, 1, delay);
		m_set = setTo;
	}

	void Apply(float scalar) override
	{
		m_widget.AnimateSet(m_key, m_set);
	}
}

class WidgetSpriteAnimation : WidgetAnimation
{
	Sprite@ m_set;

	WidgetSpriteAnimation(string key, Sprite@ setTo, int delay = 0)
	{
		super(key, 1, delay);
		@m_set = setTo;
	}

	void Apply(float scalar) override
	{
		m_widget.AnimateSet(m_key, m_set);
	}
}
