namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;416;160;32;32"]
	class ClearProjectiles
	{
		vec3 Position;
	
		[Editable default=64]
		int Radius;
		
		[Editable default=true]
		bool OnlyTrapProjectiles;
		[Editable default=false]
		bool OnlyBlockable;
		
		
		SValue@ ServerExecute()
		{
			auto projs = g_scene.FetchUnitsWithBehavior("IProjectile", xy(Position), Radius, true);
			for (uint i = 0; i < projs.length(); i++)
			{
				auto proj = cast<IProjectile>(projs[i].GetScriptBehavior());
				if (proj is null)
					continue;
				
				if (OnlyBlockable && !proj.IsBlockable())
					continue;
				
				if (OnlyTrapProjectiles && proj.GetOwner() !is null)
					continue;
				
				projs[i].Destroy();
			}
		
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			sb.DrawCircle(pos, Radius, vec4(1, 1, 0, 1), 25);
		}
	}
}