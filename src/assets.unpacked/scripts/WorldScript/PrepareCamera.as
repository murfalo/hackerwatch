namespace WorldScript
{
	[WorldScript color="35 108 162" icon="system/icons.png;64;96;32;32"]
	class PrepareCamera
	{
		vec3 Position;

		void Initialize()
		{
			g_prepareCameras.insertLast(this);
		}
	}
}
