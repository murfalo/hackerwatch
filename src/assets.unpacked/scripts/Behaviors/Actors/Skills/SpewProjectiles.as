namespace Skills
{
	class SpewProjectiles : ActiveSkill
	{
		UnitProducer@ m_projectile;
		int m_projectiles;

		array<IEffect@>@ m_effects;
		int m_effectDist;

		float m_spread;
		int m_shootDist;

		int m_interval;
		int m_intervalC;
		int m_spewInterval;
		int m_spewIntervalC;
		int m_effectInterval;
		int m_effectIntervalC;

		bool m_active;


		SpewProjectiles(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			@m_projectile = Resources::GetUnitProducer(GetParamString(unit, params, "projectile"));
			m_projectiles = GetParamInt(unit, params, "projectiles", false, 1);
			m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;
			m_shootDist = GetParamInt(unit, params, "dist", false, 0);

			m_interval = GetParamInt(unit, params, "interval", false, 100);
			m_spewInterval = GetParamInt(unit, params, "spew-interval", false, 30);
			m_effectInterval = GetParamInt(unit, params, "effect-interval", false, 1000);
			m_effectIntervalC = m_effectInterval / 2;
			m_effectDist = GetParamInt(unit, params, "effect-dist", false, 0);
			@m_effects = LoadEffects(unit, params);
		}

		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
		}

		TargetingMode GetTargetingMode(int &out size) override { return TargetingMode::Channeling; }

		bool Activate(vec2 target) override
		{
			if (!ActiveSkill::Activate(target))
				return false;
			
			m_intervalC = m_interval;
			m_spewIntervalC = m_spewInterval;
			m_effectIntervalC = m_effectInterval;
			return true;
		}

		vec2 GetShootDir(vec2 dir)
		{
			if (m_spread > 0)
			{
				float rnd = (randf() - 0.5) * m_spread;
				float ang = atan(dir.y, dir.x) + rnd;
				return vec2(cos(ang), sin(ang));
			}

			return dir;
		}

		UnitPtr ProduceProjectile(vec2 shootPos, int id = 0)
		{
			return m_projectile.Produce(g_scene, xyz(shootPos), id);
		}

		void Hold(int dt, vec2 target) override
		{
			NetHold(dt, target);

			m_effectIntervalC -= dt;
			while(m_effectIntervalC <= 0)
			{
				m_effectIntervalC += m_effectInterval;

				vec2 upos = xy(m_owner.m_unit.GetPosition()) + target * m_effectDist;
				ApplyEffects(m_effects, m_owner, m_owner.m_unit, upos, target, 1.0, false);
			}
		}

		void NetHold(int dt, vec2 target) override
		{
			m_intervalC -= dt;

			m_cooldownC = m_cooldown;
			//m_castingC = m_castpoint;

			while(m_intervalC <= 0)
			{
				m_active = true;

				m_intervalC += m_interval;
				if (!m_owner.SpendCost(m_costMana, m_costStamina, m_costHealth))
				{
					m_active = false;
					return;
				}
			}

			if (!m_active)
				return;

			m_animCountdown = 50;

			m_spewIntervalC -= dt;
			while(m_spewIntervalC <= 0)
			{
				m_spewIntervalC += m_spewInterval;

				for (int i = 0; i < m_projectiles; i++)
				{
					vec2 shootDir = GetShootDir(target);
					vec2 shootPos = xy(m_owner.m_unit.GetPosition()) + shootDir * m_shootDist;
					if (m_shootDist > 0)
					{
						auto results = g_scene.RaycastClosest(xy(m_owner.m_unit.GetPosition()), shootPos, ~0, RaycastType::Shot);
						if (results.FetchUnit(g_scene).IsValid())
							shootPos = results.point;
					}

					auto proj = ProduceProjectile(shootPos);
					if (!proj.IsValid())
						continue;

					IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
					if (p is null)
						continue;

					p.Initialize(m_owner, shootDir, 1.0f, false, null, m_skillId + 1);
				}
			}

			ActiveSkill::NetHold(dt, target);
		}

		void Release(vec2 target) override
		{
			ActiveSkill::Release(target);
		}
	}
}
