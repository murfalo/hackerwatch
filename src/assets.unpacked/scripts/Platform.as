namespace Platform
{
	class CursorInfo
	{
		Texture2D@ m_texture;
		int m_hotX;
		int m_hotY;

		CursorInfo(Texture2D@ tex)
		{
			@m_texture = tex;
			m_hotX = 0;
			m_hotY = 0;
		}

		CursorInfo(Texture2D@ tex, int hx, int hy)
		{
			@m_texture = tex;
			m_hotX = hx;
			m_hotY = hy;
		}
	}

	CursorInfo@ CursorNormal;
	CursorInfo@ CursorColorable;
	CursorInfo@ CursorHover;
	CursorInfo@ CursorCaret;
	CursorInfo@ CursorAimNormal;
	CursorInfo@ CursorVScale;

	array<CursorInfo@> CursorStack;

	void Initialize()
	{
		@CursorNormal = CursorInfo(Resources::GetTexture2D("system/cursors/normal.tga"));
		@CursorColorable = CursorInfo(Resources::GetTexture2D("system/cursors/colorable.tga"));
		@CursorHover = CursorInfo(Resources::GetTexture2D("system/cursors/hover.tga"));
		@CursorCaret = CursorInfo(Resources::GetTexture2D("system/cursors/text.tga"), 3, 6);
		@CursorAimNormal = CursorInfo(Resources::GetTexture2D("system/cursors/aim_normal.tga"), 15, 15);
		@CursorVScale = CursorInfo(Resources::GetTexture2D("system/cursors/vscale.tga"), 3, 6);
	}
}
