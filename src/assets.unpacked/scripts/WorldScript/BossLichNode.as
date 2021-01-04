namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;96;32;32;32"]
	class BossLichNode
	{
		vec3 Position;

		[Editable validation=IsLichNode]
		UnitFeed NextNodes;

		bool IsLichNode(UnitPtr unit)
		{
			return cast<BossLichNode>(unit.GetScriptBehavior()) !is null;
		}

		void Initialize()
		{
			g_lichNodes.insertLast(this);
		}

		WorldScript::BossLichNode@ PickNextNode()
		{
			array<UnitPtr>@ nodes = NextNodes.FetchAll();
			if (nodes.length() == 0)
			{
				PrintError("WARNING: There are no NextNodes for this BossLichNode!");
				return null;
			}
			return cast<BossLichNode>(nodes[randi(nodes.length())].GetScriptBehavior());
		}

		SValue@ ServerExecute()
		{
			return null;
		}

		/*
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			int num = NextNodes.FetchAll().length();

			auto font = Resources::GetBitmapFont("system/system_small.fnt");
			auto text = font.BuildText("Next: " + num);
			if (num == 0)
				text.SetColor(vec4(1, 0, 0, 1));
			else
				text.SetColor(vec4(0, 1, 0, 1));
			sb.DrawString(pos + vec2(-text.GetWidth() / 2, -8), text);
		}
		*/
	}
}
