namespace Skills
{
	class ShootProjectileFan : ShootProjectile
	{
		bool m_addFan;

		ShootProjectileFan(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_addFan = GetParamBool(unit, params, "add-fan", false, false);
		}
		
		vec2 GetShootDir(vec2 dir, int i) override
		{
			if ((m_spread > 0 || m_spreadMin > 0) && m_projectiles > 1)
			{
				float step, ang;

				if (m_addFan)
				{
					step = m_spread;
					ang = atan(dir.y, dir.x) - (m_spread * (m_projectiles - 1)) / 2.0f + i * step;
				}
				else
				{
					step = m_spread / (m_projectiles - 1);
					ang = atan(dir.y, dir.x) - m_spread / 2.0 + i * step;
				}

				return vec2(cos(ang), sin(ang));
			}
			
			return dir;
		}
	}
}