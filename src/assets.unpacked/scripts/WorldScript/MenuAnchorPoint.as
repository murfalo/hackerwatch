namespace WorldScript
{
	[WorldScript color="35 108 162" icon="system/icons.png;352;0;32;32"]
	class MenuAnchorPoint
	{
		vec3 Position;

		[Editable]
		string ScenarioID;

		[Editable]
		int LevelIndex;

		[Editable]
		bool GraphicsOptions;

		void Initialize()
		{
			g_menuAnchors.insertLast(this);
		}
	}
}
