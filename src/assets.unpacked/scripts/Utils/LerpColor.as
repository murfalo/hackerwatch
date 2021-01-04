class LerpColor
{
	vec4 m_colorPrev;
	vec4 m_color;

	LerpColor() {}
	LerpColor(vec4 color)
	{
		m_colorPrev = m_color = color;
	}

	void Update(vec4 newColor)
	{
		m_colorPrev = m_color;
		m_color = newColor;
	}

	vec4 Get(int idt)
	{
		return lerp(m_colorPrev, m_color, idt / 33.0f);
	}
}
