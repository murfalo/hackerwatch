namespace Skills
{
	class ShootProjectile : ActiveSkill
	{
		UnitProducer@ m_projectile;
		int m_projectiles;

		float m_spread;
		float m_spreadMin;
		float m_spreadMax;
		int m_spreadTime;
		int m_spreadTimeC;
		int m_spreadCooldown;
		int m_shootDist;

		float m_rangeMul;

		ShootProjectile(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		

			@m_projectile = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
			m_projectiles = GetParamInt(unit, params, "projectiles", false, 1);
			m_shootDist = GetParamInt(unit, params, "dist", false, 0);
			
			SValue@ spread = GetParamDictionary(unit, params, "spread", false);
			if (spread !is null)
			{
				m_spreadMin = GetParamInt(unit, spread, "min") * PI / 180.0;
				m_spreadMax = GetParamInt(unit, spread, "max") * PI / 180.0;
				m_spreadTime = GetParamInt(unit, spread, "time");
				m_spreadCooldown = GetParamInt(unit, params, "cooldown", false, 100);
			}
			else
			{
				m_spreadMin = GetParamInt(unit, params, "spread-min", false) * PI / 180.0;
				m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;
			}

			m_rangeMul = GetParamFloat(unit, params, "range-mul", false, 1.0f);
		}
		
		
		bool NeedNetParams() override { return true; }
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		vec2 GetShootDir(vec2 dir, int i)
		{
			if (m_spread > 0 || m_spreadMin > 0)
			{
				float rnd = (randf() - 0.5) * (m_spread - m_spreadMin);
				if (m_spreadMin > 0)
					rnd += (randi(2) == 0 ? m_spreadMin : -m_spreadMin);

				float ang = atan(dir.y, dir.x) + rnd;
				return vec2(cos(ang), sin(ang));
			}
			
			return dir;
		}
		
		UnitPtr ProduceProjectile(vec2 shootPos, int id = 0)
		{
			return m_projectile.Produce(g_scene, xyz(shootPos), id);
		}
		
		void DoShoot(SValueBuilder@ builder, vec2 pos, vec2 dir)
		{
			Actor@ targetEnemy = null;
			if (builder !is null)
			{
				builder.PushArray();
				builder.PushVector2(pos);
				
				if (targetEnemy is null)
					builder.PushInteger(0);
				else
					builder.PushInteger(targetEnemy.m_unit.GetId());
			}
			
			for (int i = 0; i < m_projectiles; i++)
			{
				vec2 shootDir = GetShootDir(dir, i);
				
				vec2 shootPos = pos + shootDir * m_shootDist;
				if (m_shootDist > 0)
				{
					auto results = g_scene.RaycastClosest(pos, shootPos, ~0, RaycastType::Shot);
					if (results.FetchUnit(g_scene).IsValid())
						shootPos = results.point;
				}
				
				auto proj = ProduceProjectile(shootPos);
				if (!proj.IsValid())
					continue;
				
				auto p = cast<IProjectile>(proj.GetScriptBehavior());
				if (p is null)
					continue;
				
				if (builder !is null)
				{
					builder.PushInteger(proj.GetId());			
					builder.PushVector2(shootDir);
				}
				
				p.Initialize(m_owner, shootDir, 1.0f, false, targetEnemy, m_skillId + 1);

				auto pp = cast<Projectile>(p);
				if (pp !is null)
					pp.m_liveRangeSq *= m_rangeMul;
			}

			if (builder !is null)
				builder.PopArray();
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			PlaySkillEffect(target);
		
			if (m_spreadTime > 0)
			{
				m_spread = lerp(m_spreadMin, m_spreadMax, min(1.0, m_spreadTimeC / float(m_spreadTime)));
				m_spreadTimeC = min(m_spreadTime, m_spreadTimeC + m_spreadCooldown);
			}
			
			auto pos = xy(m_owner.m_unit.GetPosition());
			DoShoot(builder, pos, target);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			if (target.x != 0 && target.y != 0)
				PlaySkillEffect(target);
		
			array<SValue@>@ pm = param.GetArray();
			auto pos = pm[0].GetVector2();

			int targetId = pm[1].GetInteger();
			Actor@ targetEnemy;
			if (targetId != 0)
			{
				UnitPtr targetUnit = g_scene.GetUnit(targetId);
				if (targetUnit.IsValid())
					@targetEnemy = cast<Actor>(targetUnit.GetScriptBehavior());
			}

			for (uint i = 2; i < pm.length(); i += 2)
			{
				vec2 shootDir = pm[i + 1].GetVector2();
				vec2 shootPos = pos + shootDir * m_shootDist;
				if (m_shootDist > 0)
				{
					auto results = g_scene.RaycastClosest(xy(m_owner.m_unit.GetPosition()), shootPos, ~0, RaycastType::Shot);
					if (results.FetchUnit(g_scene).IsValid())
						shootPos = results.point;
				}
			
				auto proj = ProduceProjectile(shootPos, pm[i + 0].GetInteger());
				if (!proj.IsValid())
					continue;
				
				IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
				if (p is null)
					continue;

				p.Initialize(m_owner, shootDir, 1.0f, true, targetEnemy, m_skillId + 1);

				auto pp = cast<Projectile>(p);
				if (pp !is null)
					pp.m_liveRangeSq *= m_rangeMul;
			}
		}

		void DoUpdate(int dt) override
		{
			//if (cooldown <= 0)
			//	m_spreadTimeC = 0;
		}
	}
}