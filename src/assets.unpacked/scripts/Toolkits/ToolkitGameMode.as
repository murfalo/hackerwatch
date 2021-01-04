%if TOOLKIT
namespace Toolkits
{
	class ToolkitGameMode : AGameMode
	{
		ToolkitGameMode()
		{
			super();

			@g_effectUnit = Resources::GetUnitProducer("system/effect.unit");

			@m_currInput = GameInput();
			@m_currInputMenu = MenuInput();

			vec2 windowSize = Window::GetWindowSize();
			m_wndWidth = int(windowSize.x);
			m_wndHeight = int(windowSize.y);
			m_wndScale = 1.0f;
		}
	}
}
%endif
