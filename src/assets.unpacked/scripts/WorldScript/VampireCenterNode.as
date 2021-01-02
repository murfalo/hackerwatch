namespace WorldScript
{
	[WorldScript color="100 100 255" icon="system/icons.png;96;32;32;32"]
	class VampireCenterNode : BossLichNode
	{
		void Initialize() override
		{
			@g_vampireCenterNode = this;
		}

		WorldScript::BossLichNode@ PickNextNode() override
		{
			array<BossLichNode@> nodes;
			for (uint i = 0; i < g_lichNodes.length(); i++)
			{
				auto node = g_lichNodes[i];
				if (cast<VampireCenterNode>(node) is null)
					nodes.insertLast(node);
			}
			return nodes[randi(nodes.length())];
		}
	}
}
