interface IProjectile
{
	uint Team { get; }
	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon);
	vec2 GetDirection();
	bool IsBlockable();
	Actor@ GetOwner();
}

abstract class ProjectileBase : IProjectile
{
	string m_fx;
	EffectParams@ m_effectParams;
	float m_intensity;
	UnitPtr m_unit;
	bool m_husk;
	bool m_penetrating;

	UnitPtr m_seekTarget;
	bool m_seeking;
	float m_seekTurnSpeed;
	bool m_blockable;

	float m_speed;
	float m_speedDelta;
	float m_speedDeltaMax;
	
	SoundEvent@ m_soundHit;
	SoundEvent@ m_soundShoot;
	SoundEvent@ m_soundLoop;
	SoundInstance@ m_soundLoopI;
	
	
	uint Team { get { return 0; } }
	Actor@ GetOwner() { return null; }

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon)
	{
		if (m_soundLoop !is null)
			@m_soundLoopI = m_soundLoop.PlayTracked(m_unit.GetPosition());
	}

	ProjectileBase(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
	
		m_fx = GetParamString(unit, params, "fx", false);
		
		m_penetrating = GetParamBool(unit, params, "penetrating", false, false);
		m_seeking = GetParamBool(unit, params, "seeking", false, false);
		m_seekTurnSpeed = GetParamFloat(unit, params, "seek-turnspeed", false, 0.07);

		m_speed = GetParamFloat(unit, params, "speed", false, 0);
		m_speedDelta = GetParamFloat(unit, params, "speed-delta", false, 0);
		m_speedDeltaMax = GetParamFloat(unit, params, "speed-delta-max", false, 0);
		
		m_blockable = GetParamBool(unit, params, "blockable", false, false);
		@m_soundHit = Resources::GetSoundEvent(GetParamString(unit, params, "hit-snd", false));
		@m_soundShoot = Resources::GetSoundEvent(GetParamString(unit, params, "shoot-snd", false));
		@m_soundLoop = Resources::GetSoundEvent(GetParamString(unit, params, "loop-snd", false));

		@m_effectParams = LoadEffectParams(unit, params);
	}

	void Destroy()
	{
		if (Network::IsServer() || !IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode()))
			m_unit.Destroy();
	}
	
	SValue@ Save()
	{
		return null;
	}
	
	void SetSeekTarget(Actor@ target)
	{
		if (m_seeking && target !is null)
			m_seekTarget = target.m_unit;
	}
	
	void SetScriptParams(float angle, float speed)
	{
		if (m_effectParams is null)
			return;
			
		m_effectParams.Set("angle", angle);
		m_effectParams.Set("speed", speed);
	}
	
	void Destroyed()
	{
		if (m_soundLoopI !is null)
		{
			m_soundLoopI.Stop();
			@m_soundLoopI = null;
		}

		if (m_effectParams is null)
			PlayEffect(m_fx, xy(m_unit.GetPosition()));
		else
		{
			m_effectParams.Set("old_tl", m_unit.GetUnitSceneTime());
			m_effectParams.Set("old_u", m_unit.GetId());
			PlayEffect(m_fx, xy(m_unit.GetPosition()), m_effectParams);
		}
	}

	void Update(int dt)
	{
		if (m_soundLoopI !is null)
			m_soundLoopI.SetPosition(m_unit.GetPosition());
	}
	
	bool ShouldCollide(UnitPtr unit, vec2 pos, vec2 dir, Actor@ owner, float selfDmg, float teamDmg)
	{
		ref@ b = unit.GetScriptBehavior();
		
		auto dt = cast<IDamageTaker>(b);
		if (dt !is null && dt.ShootThrough(owner, pos, dir))
			return false;
			
		if (m_penetrating && dt !is null && !dt.Impenetrable())
			return false;
	
		auto a = cast<Actor>(b);
		if (m_blockable && a !is null && a.BlockProjectile(this))
		{
			Destroy();
			return false;
		}

		float f = FilterAction(a, owner, selfDmg, teamDmg, 1, 1, Team);
		return f > 0;
	}
	
	bool IsBlockable() override { return m_blockable; }
	vec2 GetDirection() override { return vec2(); }
	void SetDirection(vec2 dir) {}
	
	void UpdateSeeking(vec2 currDir, int dt)
	{
		if (m_seekTarget.IsValid())
		{
			vec2 upos = xy(m_seekTarget.GetPosition());
			vec2 mypos = xy(m_unit.GetPosition());
			vec2 diff = upos - mypos;
			vec2 dir = normalize(diff);

			currDir = normalize(lerp(currDir, dir, m_seekTurnSpeed * dt / 33.0));

			SetDirection(currDir);
		}
	}

	void UpdateSpeed(vec2 currDirr, int dt)
	{
		if (m_speedDelta != 0)
		{
			m_speed += m_speedDelta * dt / 33.0;

			if (m_speedDeltaMax > 0 && m_speed > m_speedDeltaMax)
				m_speed = m_speedDeltaMax;

			SetDirection(currDirr);
		}
	}
}