%if TOOLKIT
namespace Toolkits
{
	//NOTE: Do not add to this class more than is absolutely necessary!
	class BaseTool
	{
		ToolkitScript@ m_script;

		BaseTool(ToolkitScript@ script)
		{
			@m_script = script;
			@g_gameMode = ToolkitGameMode();
		}
	}
}
%endif
