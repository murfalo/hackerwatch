class ScreenShake
{
	float m_from = 1.0;
	float m_to = 0.0;

	int m_casting;
	int m_castingC;
	int m_time;
	int m_timeC;

	float m_amount;

	vec3 m_position;
	float m_range;

	float ShakeFactor(int idt)
	{
		float tm = float(m_timeC - idt);
		float ret = 1 - (tm / float(m_time));
		return lerp(m_from, m_to, ret);
	}

	void Update(int dt)
	{
		if (m_timeC <= 0)
			return;

		m_castingC -= dt;
		if (m_castingC > 0)
			return;

		m_timeC -= dt;

		float shakeFactor = ShakeFactor(0);
		SetGamepadRumble(shakeFactor * 0.75, m_timeC);
	}

	void Stop()
	{
		m_timeC = 0;
		RumbleGamepadStop();
	}

	vec2 GetCameraOffset(vec3 origin, int idt)
	{
		if (m_castingC > 0)
			return vec2();

		float tm = float(m_timeC - idt);
		float shakeFactor = ShakeFactor(idt);

		if (m_range > 0)
		{
			float distance = dist(origin, m_position);
			if (distance > m_range)
				return vec2();

			shakeFactor *= (m_range - distance) / m_range;
		}

		vec2 ret;
		ret.x = sin(tm * 2.0f * shakeFactor) * m_amount * shakeFactor;
		ret.y = cos(tm * 2.0f * shakeFactor) * m_amount * shakeFactor * 0.5f;
		return ret;
	}
}
