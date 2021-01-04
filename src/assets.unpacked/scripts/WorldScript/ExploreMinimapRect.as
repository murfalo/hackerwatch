namespace WorldScript
{
	[WorldScript color="0 255 255" icon="system/icons.png;352;0;32;32"]
	class ExploreMinimapRect
	{
		vec3 Position;
	
		[Editable default=100]
		int Width;

		[Editable default=100]
		int Height;

		[Editable default=true]
		bool Explore;
	
	
		SValue@ ServerExecute()
		{
			auto campaign = cast<Campaign>(g_gameMode);
			if (campaign !is null)
				campaign.m_minimap.ExploreRect(g_scene, xy(Position), Width, Height, Explore);
		
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			sb.DrawRectangle(vec4(pos.x - Width / 2, pos.y - Height / 2, Width, Height), vec4(0, 1, 1, 1));
		}
	}
}