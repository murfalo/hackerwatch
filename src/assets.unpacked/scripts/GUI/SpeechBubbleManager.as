class SpeechBubbleManager
{
	array<SpeechBubble@> m_list;

	SpeechBubbleManager()
	{
	}

	void HideAll()
	{
		m_list.removeRange(0, m_list.length());
	}

	void Hide(SpeechBubble@ bubble)
	{
		int index = m_list.findByRef(bubble);
		if (index == -1)
		{
			PrintError("Tried hiding speech bubble that is not in list!");
			return;
		}
		m_list.removeAt(index);
	}

	SpeechBubble@ Show()
	{
		auto ret = SpeechBubble();
		m_list.insertLast(ret);
		return ret;
	}

	void Update(int dt)
	{
		for (uint i = 0; i < m_list.length(); i++)
			m_list[i].Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt)
	{
		for (uint i = 0; i < m_list.length(); i++)
			m_list[i].Draw(sb, idt);
	}
}
