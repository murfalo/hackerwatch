namespace Materials
{
	class DyeColorRainbowState : IDyeState
	{
		DyeColorRainbow@ m_dye;

		float m_hue;
		LerpColor m_color;

		DyeColorRainbowState(DyeColorRainbow@ dye)
		{
			@m_dye = dye;

			ColorHSV hsv;
			hsv.Hue = 0.0f;
			hsv.Saturation = dye.m_saturation * 100.0f;
			hsv.Value = dye.m_value * 100.0f;
			m_color = LerpColor(xyzw(hsv.ToColorRGB(), 1.0f));
		}

		void Update(int dt)
		{
			m_hue = (m_hue + m_dye.m_speed * dt) % 360.0f;

			ColorHSV hsv;
			hsv.Hue = m_hue;
			hsv.Saturation = m_dye.m_saturation * 100.0f;
			hsv.Value = m_dye.m_value * 100.0f;
			m_color.Update(xyzw(hsv.ToColorRGB(true), 1.0f));
		}

		vec4 MultiplyColor(vec4 color, float factor)
		{
			color.x *= factor;
			color.y *= factor;
			color.z *= factor;
			return color;
		}

		array<vec4> GetShades(int idt)
		{
			vec4 color = m_color.Get(idt);
			return {
				MultiplyColor(color, 0.2f),
				MultiplyColor(color, 0.6f),
				color
			};
		}
	}

	class DyeColorRainbow : Dye
	{
		float m_saturation;
		float m_value;
		float m_speed;

		DyeColorRainbow(SValue &sval)
		{
			super(sval);

			m_saturation = GetParamFloat(UnitPtr(), sval, "saturation", false, 1.0f);
			m_value = GetParamFloat(UnitPtr(), sval, "value", false, 0.5f);
			m_speed = GetParamFloat(UnitPtr(), sval, "speed", false, 0.1f);
		}

		IDyeState@ MakeDyeState(PlayerRecord@ record) override
		{
			return DyeColorRainbowState(this);
		}
	}
}
