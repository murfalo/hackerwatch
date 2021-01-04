namespace WorldScript
{
	[WorldScript color="#00A9FFFF" icon="system/icons.png;416;160;32;32"]
	class BeamLinkShooter : ProjectileShooter
	{
		UnitSource LastSpawned;

		SValue@ ServerExecute() override
		{
			if (Projectile.GetNetSyncMode() == NetSyncMode::None)
				PrintError("WARNING: BeamLinkShooter projectile has netsync=\"none\"!");

			UnitPtr proj = ProduceProjectile(0);
			if (!proj.IsValid())
			{
				LastSpawned.Clear();
				return null;
			}

			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				return null;

			float ang = Direction;
			ang += randf() * Spread - Spread / 2.f;
			ang = ang / 180.f * PI;

			p.Initialize(null, vec2(cos(ang), sin(ang)), 1.0, false, null, 0);

			LastSpawned.Replace(proj);

			SValueBuilder builder;
			builder.PushArray();
			builder.PushInteger(proj.GetId());
			builder.PushFloat(ang);
			builder.PopArray();
			return builder.Build();
		}

		void ClientExecute(SValue@ sval) override
		{
			auto arr = sval.GetArray();

			UnitPtr unit = g_scene.GetUnit(arr[0].GetInteger());
			float ang = arr[1].GetFloat();

			auto p = cast<IProjectile>(unit.GetScriptBehavior());
			p.Initialize(null, vec2(cos(ang), sin(ang)), 1.0, false, null, 0);
		}
	}
}
