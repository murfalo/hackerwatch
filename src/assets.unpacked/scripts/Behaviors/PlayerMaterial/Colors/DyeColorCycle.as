namespace Materials
{
	class DyeColorCycleState : IDyeState
	{
		DyeColorCycle@ m_dye;

		int m_pos;
		int m_index;

		float m_factorPrev;
		float m_factor;

		DyeColorCycleState(DyeColorCycle@ dye)
		{
			@m_dye = dye;
		}

		void Update(int dt)
		{
			m_pos += dt;

			int n = int(m_dye.m_frames.length());
			float t = (m_pos % m_dye.m_length) / float(m_dye.m_length);

			m_factorPrev = m_factor;
			//m_factor = (1.0f - cos((t * n) % 1.0f * PI)) * 0.5f;
			m_factor = ease((t * n) % 1.0f, m_dye.m_ease);

			int newIndex = int(t * n);
			if (newIndex != m_index)
			{
				m_index = newIndex;
				m_factorPrev = m_factor;
			}
		}

		array<vec4> GetShades(int idt)
		{
			float factor = lerp(m_factorPrev, m_factor, idt / 33.0f);

			auto frameA = m_dye.m_frames[m_index];
			auto frameB = m_dye.m_frames[(m_index + 1) % m_dye.m_frames.length()];

			return {
				frameA[0].Lerp(frameB[0], factor).ToColorRGBA(),
				frameA[1].Lerp(frameB[1], factor).ToColorRGBA(),
				frameA[2].Lerp(frameB[2], factor).ToColorRGBA()
			};
		}
	}

	class DyeColorCycle : Dye
	{
		array<array<ColorHSV>> m_frames;
		int m_length;

		EasingFunction m_ease;

		DyeColorCycle(SValue &sval)
		{
			super(sval);

			auto arrShades = GetParamArray(UnitPtr(), sval, "shades");
			for (uint i = 0; i < arrShades.length(); i += 3)
			{
				array<ColorHSV> newFrame = {
					ParseColorRGBA(arrShades[i + 0].GetString()),
					ParseColorRGBA(arrShades[i + 1].GetString()),
					ParseColorRGBA(arrShades[i + 2].GetString())
				};
				m_frames.insertLast(newFrame);
			}

			m_length = GetParamInt(UnitPtr(), sval, "length", false, 1000);

			m_ease = ParseEasingFunction(GetParamString(UnitPtr(), sval, "ease", false, "sine"));
		}

		IDyeState@ MakeDyeState(PlayerRecord@ record) override
		{
			return DyeColorCycleState(this);
		}
	}
}
