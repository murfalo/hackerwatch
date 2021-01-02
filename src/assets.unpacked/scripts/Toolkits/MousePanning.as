%if TOOLKIT
namespace Toolkits
{
	class MousePanning
	{
		int m_button;

		Camera m_cam;

		vec2 m_mousePos;
		bool m_holding;

		float m_minScale = 1.0f;
		float m_maxScale = 10.0f;

		bool m_frozen = false;

		MousePanning(int button = 2)
		{
			m_button = button;
		}

		void Set() { m_cam.Set(); }

		vec2 GetMidpoint() { return m_cam.GetMidpoint(); }
		float GetScale() { return m_cam.GetScale(); }

		void Center()
		{
			m_cam.MoveTo(vec2(0, -10));
		}

		void SetScale(float scale, vec2 origin)
		{
			if (m_cam.scale == scale)
				return;

			m_cam.scale = scale;
			m_cam.SetTarget(origin, true);
		}

		void SetScale(float scale)
		{
			SetScale(scale, m_mousePos);
		}

		void OnMouseDown(vec2 pos, int button)
		{
			if (button != m_button)
				return;

			m_cam.SetTarget(pos, true);
			m_holding = true;
		}

		void OnMouseUp(vec2 pos, int button)
		{
			m_holding = false;
		}

		void OnMouseMove(vec2 pos)
		{
			m_mousePos = pos;

			if (m_holding && !m_frozen)
				m_cam.SetTarget(pos, false);
		}

		void OnMouseWheel(vec2 delta)
		{
			if (delta.y == 0)
				return;

			float newScale = m_cam.scale;
			if (delta.y < 0)
				newScale /= 1.1f;
			else if (delta.y > 0)
				newScale *= 1.1f;

			if (newScale < m_minScale)
				newScale = m_minScale;
			else if (newScale > m_maxScale)
				newScale = m_maxScale;

			SetScale(newScale);
		}
	}
}
%endif
