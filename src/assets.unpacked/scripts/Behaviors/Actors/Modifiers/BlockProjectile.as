namespace Modifiers
{
	class BlockProjectile : Modifier
	{
		float m_arc;
		float m_offset;
		float m_chance;
	
		BlockProjectile(UnitPtr unit, SValue& params)
		{
			m_arc = GetParamInt(unit, params, "arc", true, 90) * PI / 180.0f / 2.0f;
			m_offset = GetParamInt(unit, params, "offset", false, 0) * PI / 180.0f + PI;
			m_chance = GetParamFloat(unit, params, "chance", false, 1);
		}

		bool HasProjectileBlock() override { return true; }
		bool ProjectileBlock(PlayerBase@ player, IProjectile@ proj) override 
		{
			auto dir = proj.GetDirection();
			float a = player.m_dirAngle - (atan(dir.y, dir.x) + m_offset);
			a += (a > PI) ? -TwoPI : (a < -PI) ? TwoPI : 0;

			if ((abs(a) % TwoPI) < m_arc)
				return roll_chance(player, m_chance);
			
			return false;
		}
	}
}