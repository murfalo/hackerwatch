class AnimString
{
	string m_anim;
	int m_numDirs;
	bool m_flipped;
	bool m_capped;
	float m_capStart;
	float m_capSpan;

	AnimString(string str)
	{
		auto strs = str.split(" ");
	
		if (strs.length() >= 2)
		{
			m_anim = strs[0] + "-";
			m_numDirs = int(parseInt(strs[1]));
		}
		else
		{
			m_anim = str;
			m_numDirs = -1;
		}
		
		m_capStart = 0;
		m_capSpan = 2 * PI;
		m_capped = false;

		if (strs.length() >= 3)
			m_capStart = parseInt(strs[2]) * PI / 180.0f;

		if (strs.length() >= 4)
		{
			//m_capStart = parseInt(strs[2]) * PI / 180.0f;
			m_capSpan = parseInt(strs[3]) * PI / 180.0f - m_capStart;
			m_capped = true;
		}
	}
	
	string GetSceneName(float dir)
	{
		if (m_numDirs <= 0)
			return m_anim;
	
		dir -= m_capStart;
	
		if (!m_capped)
			return m_anim + int((dir / (2 * PI) * m_numDirs - 0.5) + 1 + m_numDirs) % m_numDirs;

		if (dir < 0)
			dir = 0 - dir;
		if (dir > m_capSpan)
			dir = m_capSpan + (m_capSpan - dir);
		
		return m_anim + int((dir / (m_capSpan) * m_numDirs) + m_numDirs) % m_numDirs;
	}
}