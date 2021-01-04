namespace WorldScript
{
	[WorldScript color="255 127 0" icon="system/icons.png;416;160;32;32"]
	class ProjectileSpewer
	{
		vec3 Position;
		bool Enabled;
	
		[Editable]
		UnitProducer@ Projectile;
		
		[Editable default=0]
		int Direction;
		
		[Editable default=0]
		float Spread;

		[Editable default=50]
		int Frequency;

		int m_time;
		UnitPtr m_thisUnit;

		void Initialize()
		{
			m_time = Frequency;
			if (Projectile is null || IsNetsyncedExistance(Projectile.GetNetSyncMode()))
				@Projectile = null;
				
			m_thisUnit = WorldScript::GetWorldScript(g_scene, this).GetUnit();
		}
		
		void Update(int dt)
		{
			if (!Enabled)
				return;

			if (m_thisUnit.GetRoughPingDistance() > 600)
				return;
		
			m_time -= dt;
			while (m_time < 0)
			{
				m_time += Frequency;
				DoSpewProjectile();
			}
		}
		
		void DoSpewProjectile()
		{
			UnitPtr proj = Projectile.Produce(g_scene, Position);
			if (!proj.IsValid())
				return;

			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
			{
				proj.Destroy();
				return;
			}
			
			float ang = Direction;
			ang += randf() * Spread - Spread / 2.f;
			ang = ang / 180.f * PI;
		
			p.Initialize(null, vec2(cos(ang), sin(ang)), 1.0, !Network::IsServer(), null, 0);
		}
	}
}