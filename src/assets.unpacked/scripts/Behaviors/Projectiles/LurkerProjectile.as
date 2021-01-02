class LurkerProjectile : RayProjectile
{
	int m_hardnessIgnore;
	int m_hardnessDestroy;
	
	int m_animCooldown;
	int m_animCooldownC;
	bool m_playMissFx;

	LurkerProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_hardnessIgnore = GetParamInt(unit, params, "ignore-at-hardness", false, -1);
		m_hardnessDestroy = GetParamInt(unit, params, "destroy-at-hardness", false, -1);

		m_animCooldownC = m_animCooldown = GetParamInt(unit, params, "spawn-freq", true);
		m_playMissFx = GetParamBool(unit, params, "miss-fx", false);
	}
	
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x);
		SetScriptParams(ang, m_speed);
	}
	
	void Update(int dt) override
	{
		bool ignore = false;
		if (m_hardnessIgnore != -1 || m_hardnessDestroy != -1)
		{
			array<Tileset@>@ tilesets = g_scene.FetchTilesets(xy(m_unit.GetPosition()));
			for (uint i = 0; i < tilesets.length(); i++)
			{
				SValue@ tsd = tilesets[i].GetData();
				if (tsd is null)
					continue;

				SValue@ svHardness = tsd.GetDictionaryEntry("hardness");
				if (svHardness is null || svHardness.GetType() != SValueType::Integer)
					continue;

				int hardness = svHardness.GetInteger();
				
				if (hardness > m_hardnessDestroy && m_hardnessDestroy != -1)
				{
					m_unit.Destroy();
					return;
				}
				
				if (hardness > m_hardnessIgnore && m_hardnessIgnore != -1)
				{
					ignore = true;
					if (m_hardnessDestroy != -1)
						break;
				}
			}
		}
	

		
		if (ignore)
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
				m_unit.Destroy();
		
			m_pos += m_dir * m_speed * dt / 33.0;
			m_unit.SetPosition(m_pos.x, m_pos.y, 0, true);
			
			return;
		}
		
		
		m_animCooldownC -= dt;
		while (m_animCooldownC < 0)
		{
			m_animCooldownC += m_animCooldown;
		
			float ang = atan(m_dir.y, m_dir.x);
			auto pos = xy(m_unit.GetPosition());
			
			auto sceneName = m_anim.GetSceneName(ang);
			auto scene = m_unit.GetUnitScene(sceneName);
			PlayEffect(scene, pos);
			
%if GFX_VFX_HIGH
			if (m_playMissFx)
			{
				array<Tileset@>@ tilesets = g_scene.FetchTilesets(pos);
				for (int j = tilesets.length() - 1; j >= 0; j--)
				{
					SValue@ data = tilesets[j].GetData();
					if (data !is null)
					{
						SValue@ effect = data.GetDictionaryEntry("hit-effect");
						if (effect !is null && effect.GetType() == SValueType::String)
						{
							PlayEffect(effect.GetString(), pos);
							break;
						}
					}
				}
			}
%endif
		}
		
		RayProjectile::Update(dt);
	}
}
