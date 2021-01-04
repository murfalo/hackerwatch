namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;96;32;32;32"]
	class BossLichRoom
	{
		vec3 Position;

		[Editable]
		int Width;

		[Editable]
		int Height;

		void Initialize()
		{
			@g_lichRoom = this;
		}

		bool IsInside(vec3 pos)
		{
			vec2 size = vec2(Width, Height);
			vec2 topLeft = xy(Position) - size / 2.0f;
			vec2 bottomRight = topLeft + size;
			return (pos.x > topLeft.x && pos.y > topLeft.y && pos.x < bottomRight.x && pos.y < bottomRight.y);
		}

		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			vec2 size = vec2(Width, Height);
			vec2 topLeft = xy(Position) - size / 2.0f;
			sb.DrawRectangle(vec4(topLeft.x, topLeft.y, size.x, size.y), vec4(1, 0, 0, 1));
		}
	}
}
