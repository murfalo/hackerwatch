namespace WorldScript
{
	[WorldScript color="0 255 255" icon="system/icons.png;352;0;32;32"]
	class ExploreMinimap
	{
		vec3 Position;
	
		[Editable default=100]
		int Radius;

		[Editable default=true]
		bool Explore;
	
	
		SValue@ ServerExecute()
		{
			auto campaign = cast<Campaign>(g_gameMode);
			if (campaign !is null)
				campaign.m_minimap.Explore(g_scene, xy(Position), Radius, Explore);
		
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			sb.DrawCircle(pos, Radius, vec4(0, 1, 1, 1), 25);
		}
	}
}