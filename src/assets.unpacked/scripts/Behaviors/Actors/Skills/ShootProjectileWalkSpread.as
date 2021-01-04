namespace Skills
{
	class ShootProjectileWalkSpread : ShootProjectile
	{
		float m_idleSpread;
		float m_idleSpreadMin;
		float m_idleSpreadMax;
		int m_idleSpreadTime;
		int m_idleSpreadCooldown;

		float m_walkSpread;
		float m_walkSpreadMin;
		float m_walkSpreadMax;
		int m_walkSpreadTime;
		int m_walkSpreadCooldown;
		
		ShootProjectileWalkSpread(UnitPtr unit, SValue& params)
		{
			super(unit, params);
					
			SValue@ spread = GetParamDictionary(unit, params, "idle-spread", false);
			if (spread !is null)
			{
				m_idleSpreadMin = GetParamInt(unit, spread, "min") * PI / 180.0;
				m_idleSpreadMax = GetParamInt(unit, spread, "max") * PI / 180.0;
				m_idleSpreadTime = GetParamInt(unit, spread, "time");
				m_idleSpreadCooldown = GetParamInt(unit, params, "cooldown", false, 100);
			}
			else
			{
				m_idleSpreadMin = GetParamInt(unit, params, "idle-spread-min", false) * PI / 180.0;
				m_idleSpread = GetParamInt(unit, params, "idle-spread", false) * PI / 180.0;
			}
			
			m_walkSpread = m_spread;
			m_walkSpreadMin = m_spreadMin;
			m_walkSpreadMax = m_spreadMax;
			m_walkSpreadTime = m_spreadTime;
			m_walkSpreadCooldown = m_spreadCooldown;
			
		}
		
		void Update(int dt, bool walking) override
		{
			if (walking)
			{
				m_spread = m_walkSpread;
				m_spreadMin = m_walkSpreadMin;
				m_spreadMax = m_walkSpreadMax;
				m_spreadTime = m_walkSpreadTime;
				m_spreadCooldown = m_walkSpreadCooldown;
			}
			else
			{
				m_spread = m_idleSpread;
				m_spreadMin = m_idleSpreadMin;
				m_spreadMax = m_idleSpreadMax;
				m_spreadTime = m_idleSpreadTime;
				m_spreadCooldown = m_idleSpreadCooldown;
			}
		
			ShootProjectile::Update(dt, walking);
		}
	}
}