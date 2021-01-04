namespace WorldScript
{
	array<PathNode@> g_pathNodes;

	[WorldScript color="#8FBC8B" icon="system/icons.png;224;64;32;32"]
	class PathNode
	{
		vec3 Position;
		bool Enabled;

		[Editable]
		UnitFeed NextNode;

		void Initialize()
		{
			g_pathNodes.insertLast(this);
		}

		SValue@ ServerExecute()
		{
			return null;
		}

		void ClientExecute(SValue@ val)
		{
		}
	}
}
