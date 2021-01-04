class RangerProjectile : RayProjectile
{
	uint m_weaponInfo;
	float m_twinChance;
	bool m_hasUpdated;
	
	RangerProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		m_hasUpdated = false;
	}
	
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		RayProjectile::Initialize(owner, dir, intensity, husk, target, weapon);
		m_weaponInfo = weapon;
		
		auto twinnedArrow = cast<Skills::TwinnedArrow>(cast<PlayerBase>(owner).m_skills[6]);
		if (twinnedArrow !is null)
			m_twinChance = twinnedArrow.m_chance;
		else
			m_twinChance = 0;
	}
	
	bool Multiply(vec2 pos)
	{
		if (!m_hasUpdated)
			return false;
	
		int ttl = m_ttl + 10;
		int range = int(ttl * m_speed / 33.0f * 1.05f);
	
		array<UnitPtr>@ enemies = g_scene.FetchActorsWithOtherTeam(m_owner.Team, pos, range);
		for (int i = 0; i < int(enemies.length()); i++)
		{
			if (dot(pos - xy(enemies[i].GetPosition()), m_dir) > 0)
			{
				enemies.removeAt(i--);
				continue;
			}
			
			auto actor = cast<Actor>(enemies[i].GetScriptBehavior());
			if (actor is null || !actor.IsTargetable())
			{
				enemies.removeAt(i--);
				continue;
			}
		}

		if (enemies.length() <= 0)
			return false;

		auto proj = m_unit.GetUnitProducer().Produce(g_scene, xyz(pos));
		if (!proj.IsValid())
			return false;

		auto p = cast<RangerProjectile>(proj.GetScriptBehavior());
		if (p is null)
			return false;

		auto target = enemies[randi(enemies.length())];			
		auto tpos = intercept(pos, xy(target.GetPosition()), target.GetMoveDir(), m_speed);
		vec2 shootDir = normalize(tpos - pos);

		p.Initialize(m_owner, shootDir, m_intensity, m_husk, cast<Actor>(target.GetScriptBehavior()), m_weaponInfo);
		p.m_ttl = ttl;
		p.m_penetration = m_penetration;
		return true;
	}

	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true) override
	{
		if (!unit.IsValid())
			return true;
		
		ref@ b = unit.GetScriptBehavior();
		/*
		IProjectile@ p = cast<IProjectile>(b);
		if (p !is null)
			return true;
		*/

		
		auto dt = cast<IDamageTaker>(b);
		if (dt !is null)
		{
			if (dt.ShootThrough(m_owner, pos, m_dir))
				return false;
		
//			m_lastCollision = unit;
		
			if (!dt.Impenetrable())
				bounce = false;
		
			if (dt is m_owner && selfDmg > 0)
			{
				if (m_lastCollision != unit)
				{
					m_lastCollision = unit;
					ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity * selfDmg, m_husk);
					m_intensity *= 0.75;
					
					if (--m_penetration <= 0)
					{
						PlaySound3D(m_soundHit, xyz(pos));
						m_unit.Destroy();
					}
				}
				
				return true;
			}
			else if (!(FilterAction(cast<Actor>(b), m_owner, m_selfDmg, m_teamDmg, 1, 1) > 0))
				return true;
			else if (--m_penetration <= 0)
			{
				PlaySound3D(m_soundHit, xyz(pos));
				m_unit.Destroy();
			}
		}

		if (m_lastCollision != unit)
		{
			m_lastCollision = unit;
			ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk);
			m_intensity *= 0.66f;
			
			if (dt !is null && randf() < m_twinChance && m_intensity > 0.01f)
				Multiply(pos);
		}
		
		if (bounce)
		{
			if (m_bounces <= 0)
				m_unit.Destroy();
			else
			{
				m_lastCollision = unit;
				
				m_bounces--;
				m_speed *= m_bounceSpeedMul;
				SetDirection(normal * -2 * dot(m_dir, normal) + m_dir);
				m_pos = pos;
				
				PlaySound3D(m_soundBounce, xyz(pos));
			}
		}

		return false;
	}
	
	void Update(int dt) override
	{
		RayProjectile::Update(dt);
		//m_intensity = max(0.05, m_intensity - (m_speed * dt / 33.0f) / 250.0f);
		m_hasUpdated = true;
	}
}
