class CannonBall : ProjectileBase
{
	uint m_team;
	uint Team { get override { return m_team; } }
	Actor@ GetOwner() override { return m_owner; }

	UnitPtr m_lastCollision;

	int m_ttl;
	int m_minDamage;
	int m_maxDamage;
	float m_minSpeed;
	float m_maxSpeed;
	float m_charge;

	float m_bounceSpeedMul;
	SoundEvent@ m_bounceSnd;

	Actor@ m_owner;

	AnimString@ m_anim;
	array<IEffect@>@ m_effects;

	vec2 m_dir;
	vec2 m_pos;

	float m_selfDmg;
	float m_teamDmg;

	bool m_bounced;
	uint m_weaponInfo;
	
	CannonBall(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_ttl = GetParamInt(unit, params, "ttl", false, 5000);
		m_minSpeed = GetParamFloat(unit, params, "min-speed");
		m_maxSpeed = GetParamFloat(unit, params, "max-speed");

		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);

		m_minDamage = GetParamInt(unit, params, "min-dmg");
		m_maxDamage = GetParamInt(unit, params, "max-dmg");
		@m_anim = AnimString(GetParamString(unit, params, "anim"));
		@m_effects = LoadEffects(unit, params);

		m_bounceSpeedMul = GetParamFloat(unit, params, "bounce-speed-mul", false, 1.0);
		@m_bounceSnd = Resources::GetSoundEvent(GetParamString(unit, params, "bounce-snd", false));
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		Initialize(owner, dir, intensity, husk, target, weapon, 1.0);
		ProjectileBase::Initialize(owner, dir, intensity, husk, target, weapon);
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon, float charge)
	{
		m_husk = husk;
		m_intensity = intensity;
		m_charge = charge;
		m_speed = lerp(m_minSpeed, m_maxSpeed, charge);
		SetDirection(dir * m_speed);
		PropagateWeaponInformation(m_effects, weapon);
		m_weaponInfo = weapon;

		@m_owner = owner;
		if (m_owner !is null)
		{
			m_team = owner.Team;
			m_lastCollision = owner.m_unit;
		}

		m_pos = xy(m_unit.GetPosition());

		vec2 nDir = vec2(-dir.x, -dir.y);
		array<UnitPtr>@ results = g_scene.QueryRect(m_pos, 1, 1, ~0, RaycastType::Aim);
		for (uint i = 0; i < results.length(); i++)
		{
			if (m_owner !is null && m_owner.m_unit == results[i])
				continue;
		
			if (HitUnit(results[i], m_pos, nDir, 0, true))
				break;
		}
	}

	vec2 GetDirection() override { return m_dir; }
	void SetDirection(vec2 dir) override
	{
		m_dir = dir;
		float ang = atan(dir.y, dir.x);
		m_unit.SetUnitScene(m_anim.GetSceneName(ang), false);
		SetScriptParams(ang, m_speed);
	}

	void Destroyed() override
	{
		ApplyEffects(m_effects, m_owner, UnitPtr(), xy(m_unit.GetPosition()), m_dir, 1.0, m_husk, m_selfDmg, m_teamDmg);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		if (m_bounced)
			return;

		HitUnit(unit, pos, normal, m_selfDmg, true);
	}

	bool HitUnit(UnitPtr unit, vec2 pos, vec2 normal, float selfDmg, bool verifyBounce)
	{
		bool bounce = true;

		if (!unit.IsValid() || unit == m_unit || m_lastCollision == unit)
			return false;
			
		ref@ b = unit.GetScriptBehavior();

		IProjectile@ p = cast<IProjectile>(b);
		if (p !is null)
			return false;

		if (FilterAction(cast<Actor>(b), m_owner, m_selfDmg, m_teamDmg, 1.0, 1.0) <= 0)
			return false;
		
		int dmg = damage_round(lerp(m_minDamage, m_maxDamage, m_charge) * FilterAction(cast<Actor>(b), m_owner, m_selfDmg, m_teamDmg, 1.0) * m_intensity);
		if (dmg > 0)
			unit.TriggerCallbacks(UnitEventType::Damaged);

		IDamageTaker@ dt = cast<IDamageTaker>(unit.GetScriptBehavior());
		if (dt !is null)
		{
			if (dt.Impenetrable())
			{
				m_unit.Destroy();
				return true;
			}
			else 
			{
				if (dmg > 0)					
					dt.Damage(DamageInfo(uint8(DamageType::BLUNT), m_owner, dmg, false, true, m_weaponInfo), pos, m_dir);

				bounce = false;
			}
		}
		
		m_lastCollision = unit;

		if (bounce)
		{
			if (verifyBounce)
			{
				array<RaycastResult>@ results = g_scene.Raycast(pos - m_dir * 4.0f, pos + m_dir * 8.0f, ~0, RaycastType::Shot);
				for (uint i = 0; i < results.length(); i++)
				{
					RaycastResult res = results[i];
					if (res.FetchUnit(g_scene) == unit)
					{
						normal = res.normal;
						pos = res.point;
						break;
					}
				}
			}

			m_speed *= m_bounceSpeedMul;
			SetDirection(normal * -2 * dot(m_dir, normal) + m_dir);
			PlaySound3D(m_bounceSnd, m_unit.GetPosition());
			m_bounced = true;
		}

		return true;
	}

	void Update(int dt) override
	{
		m_bounced = false;

		UpdateSeeking(m_dir, dt);

		m_ttl -= dt;
		if (m_ttl <= 0)
			m_unit.Destroy();

		vec2 from = m_pos;
		m_pos += m_dir * m_speed * dt / 33.0;

		array<RaycastResult>@ results = g_scene.Raycast(from, m_pos, ~0, RaycastType::Shot);
		for (uint i = 0; i < results.length(); i++)
		{
			RaycastResult res = results[i];
			if (HitUnit(res.FetchUnit(g_scene), res.point, res.normal, m_selfDmg, false))
			{
				m_unit.SetPosition(res.point.x, res.point.y, 0, true);
				return;
			}
		}

		m_unit.SetPosition(m_pos.x, m_pos.y, 0, true);
		UpdateSpeed(m_dir, dt);

		ProjectileBase::Update(dt);
	}
}