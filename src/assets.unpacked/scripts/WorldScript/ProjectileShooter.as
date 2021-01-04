namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;416;160;32;32"]
	class ProjectileShooter
	{
		vec3 Position;
	
		[Editable]
		UnitProducer@ Projectile;
		
		[Editable default=0]
		int Direction;
		
		[Editable default=0]
		int Spread;
		
		
		UnitPtr ProduceProjectile(int id)
		{
			UnitPtr proj = Projectile.Produce(g_scene, Position, id);
			if (!proj.IsValid())
				return UnitPtr();

			return proj;
		}
		
		SValue@ ServerExecute()
		{
			UnitPtr proj = ProduceProjectile(0);
			if (!proj.IsValid())
				return null;
				
			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				return null;
			
			float ang = Direction;
			ang += randf() * Spread - Spread / 2.f;
			ang = ang / 180.f * PI;
		
			p.Initialize(null, vec2(cos(ang), sin(ang)), 1.0, false, null, 0);
			
			
			SValueBuilder sval;
			sval.PushArray();
			sval.PushInteger(proj.GetId());
			sval.PushFloat(ang);
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			if (val is null)
				return;
		
			auto arr = val.GetArray();

			UnitPtr proj = ProduceProjectile(arr[0].GetInteger());
			if (!proj.IsValid())
				return;
				
			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				return;
			
			auto ang = arr[1].GetFloat();
			p.Initialize(null, vec2(cos(ang), sin(ang)), 1.0, true, null, 0);
		}

		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			float angleLeft = float(Direction - (Spread / 2.0f)) / 180.0f * PI;
			float angleRight = float(Direction + (Spread / 2.0f)) / 180.0f * PI;

			vec2 dirLeft = vec2(cos(angleLeft), sin(angleLeft));
			vec2 dirRight = vec2(cos(angleRight), sin(angleRight));

			vec4 color = vec4(1, 1, 1, 0.8f);
			float distance = 200.0f;

			sb.DrawLine(pos, pos + dirLeft * distance, 1.0f, color);
			sb.DrawLine(pos, pos + dirRight * distance, 1.0f, color);
			sb.DrawLine(pos + dirLeft * distance, pos + dirRight * distance, 1.0f, color);
		}
	}
}
