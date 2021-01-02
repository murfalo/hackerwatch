class RayProjectile : ProjectileBase
{
	uint m_team;
	uint Team { get override { return m_team; } }
	Actor@ GetOwner() override { return m_owner; }

	UnitPtr m_lastCollision;
	
	int m_ttl;
	
	int m_bounces;
	float m_bounceSpeedMul;
	int m_penetration;
	float m_penetrationIntensityMul;
	bool m_penetrateAll;
	bool m_bounceOnCollide;
	
	Actor@ m_owner;
	
	AnimString@ m_anim;
	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_missEffects;
	
	vec2 m_dir;
	vec2 m_pos;
	float m_selfDmg;
	float m_teamDmg;
	
	SoundEvent@ m_soundBounce;
	

	RayProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		
		m_ttl = GetParamInt(unit, params, "ttl", false, 5000);
		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_bounces = GetParamInt(unit, params, "bounces", false, 0);
		m_bounceSpeedMul = GetParamFloat(unit, params, "bounce-speed-mul", false, 0.5);
		m_penetration = GetParamInt(unit, params, "penetration", false, 0);
		m_penetrationIntensityMul = GetParamFloat(unit, params, "penetration-intensity-mul", false, 1.0);
		m_penetrateAll = GetParamBool(unit, params, "penetrate-all", false, false);
		m_bounceOnCollide = GetParamBool(unit, params, "bounce-on-collide", false, true);
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		@m_effects = LoadEffects(unit, params);
		@m_missEffects = LoadEffects(unit, params, "miss-");
		@m_soundBounce = Resources::GetSoundEvent(GetParamString(unit, params, "bounce-snd", false));
		
		auto to = GetParamString(unit, params, "team-override", false, "ERRR");
		m_team = (to == "ERRR") ? 1 : HashString(to);
	}
	
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		SetDirection(dir);
		m_husk = husk;
		m_intensity = intensity;
		PropagateWeaponInformation(m_effects, weapon);
		
		@m_owner = owner;
		if (m_owner !is null)
		{
			if (m_team == 1)
				m_team = owner.Team;
			m_lastCollision = owner.m_unit;
		}

		m_pos = xy(m_unit.GetPosition());
		PlaySound3D(m_soundShoot, m_unit.GetPosition());
		
		vec2 nDir = vec2(-dir.x, -dir.y);
		array<UnitPtr>@ results = g_scene.QueryRect(m_pos, 1, 1, ~0, RaycastType::Aim);
		for (uint i = 0; i < results.length(); i++)
		{
			if (cast<PlayerBase>(results[i].GetScriptBehavior()) !is null)
				continue;
			if (!HitUnit(results[i], m_pos, nDir, 0, true))
				break;
		}

		SetSeekTarget(target);

		ProjectileBase::Initialize(owner, dir, intensity, husk, target, weapon);
	}
	
	vec2 GetDirection() override { return m_dir; }
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x);
		m_unit.SetUnitScene(m_anim.GetSceneName(ang), false);
		SetScriptParams(ang, m_speed);
	}
	
	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		//if (!ShouldCollide(unit))
		//	return;
	
		HitUnit(unit, pos, normal, m_selfDmg, m_bounceOnCollide);
	}
	
	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool bounce, bool collide = true)
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
				return true;
		
			if (!dt.Impenetrable())
				bounce = false;
				
			auto a = cast<Actor>(b);
			if (m_blockable && a !is null && a.BlockProjectile(this))
			{
				Destroy();
				return false;
			}
		
			if (dt is m_owner && selfDmg > 0)
			{
				if (m_lastCollision != unit)
				{
					m_lastCollision = unit;
					ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity * selfDmg, m_husk);
					
					if (collide)
					{
						if (--m_penetration <= 0)
						{
							PlaySound3D(m_soundHit, xyz(pos));
							Destroy();
						}
						else
							m_intensity *= m_penetrationIntensityMul;
					}
				}
				
				return false;
			}
			else if (!(FilterAction(a, m_owner, m_selfDmg, m_teamDmg, 1, 1, Team) > 0))
				return true;
			else if (collide && --m_penetration <= 0)
			{
				PlaySound3D(m_soundHit, xyz(pos));
				Destroy();
			}
		}

		if (m_lastCollision != unit)
		{
			m_lastCollision = unit;
			ApplyEffects(m_effects, m_owner, unit, pos, m_dir, m_intensity, m_husk);
			m_intensity *= m_penetrationIntensityMul;
		}
		
		if (bounce)
		{
			if (m_bounces <= 0)
			{
				if (!m_penetrateAll)
					Destroy();
			}
			else
			{
				m_lastCollision = unit;
				
				m_bounces--;
				m_speed *= m_bounceSpeedMul;
				SetDirection(normal * -2 * dot(m_dir, normal) + m_dir);
				m_pos = pos;
				
				OnBounce(pos);
			}
		}

		return false;
	}
	
	void OnBounce(vec2 pos)
	{
		PlaySound3D(m_soundBounce, xyz(pos));
	}
	
	void Update(int dt) override
	{
		m_ttl -= dt;
		if (m_ttl <= 0)
		{
			ApplyEffects(m_missEffects, m_owner, UnitPtr(), m_pos, m_dir, m_intensity, m_husk);
			Destroy();
			return;
		}

		UpdateSeeking(m_dir, dt);
		
		vec2 from = m_pos;
		m_pos += m_dir * m_speed * dt / 33.0;
	
		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, true))
				return;
				
			if (m_unit.IsDestroyed())
				return;
		}
	
		m_unit.SetPosition(m_pos.x, m_pos.y, 0, true);

		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
}
