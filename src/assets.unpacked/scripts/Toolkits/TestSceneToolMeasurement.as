%if TOOLKIT
namespace Toolkits
{
	class TestSceneToolMeasurement
	{
		vec4 m_color;

		vec2 m_posA;
		vec2 m_posB;

		TestSceneToolMeasurement(const vec2 &in a, const vec2 &in b)
		{
			ColorHSV hsv;
			hsv.Hue = randf() * 360.0f;
			hsv.Saturation = 50.0f;
			hsv.Value = 50.0f;
			m_color = hsv.ToColorRGBA();

			m_posA = a;
			m_posB = b;
		}

		float GetDistance()
		{
			return dist(m_posA, m_posB);
		}
	}
}
%endif
