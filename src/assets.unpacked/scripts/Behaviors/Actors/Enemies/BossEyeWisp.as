class BossEyeWisp : IPreRenderable
{
	UnitPtr m_unit;

	int m_appearTimeC;
	int m_disappearTimeC;

	float m_minDistance;
	float m_maxDistance;

	float m_speedRotateMul;
	float m_speedDistanceMul;

	float m_speedRotateMulTarget;
	float m_speedRotateMulTargetBefore;
	int m_speedRotateMulTargetTime;
	int m_speedRotateMulTargetTimeC;

	UnitScene@ m_sceneIntro;
	UnitScene@ m_sceneIdle;
	UnitScene@ m_sceneOutro;

	array<IEffect@>@ m_effects;

	vec2 m_offset;

	EffectParams@ m_effectParams;

	BossEye@ m_owner;

	float m_currAngle;
	float m_currDistance;

	float m_prevAngle;
	float m_prevDistance;

	Actor@ m_target;

	BossEyeWisp(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_minDistance = GetParamFloat(unit, params, "min-distance");
		m_maxDistance = GetParamFloat(unit, params, "max-distance");

		m_speedRotateMul = GetParamFloat(unit, params, "speed-rotate", false, 1.0f);
		m_speedDistanceMul = GetParamFloat(unit, params, "speed-distance", false, 1.0f);

		@m_sceneIntro = m_unit.GetUnitScene(GetParamString(unit, params, "scene-intro"));
		@m_sceneIdle = m_unit.GetUnitScene(GetParamString(unit, params, "scene-idle"));
		@m_sceneOutro = m_unit.GetUnitScene(GetParamString(unit, params, "scene-outro"));

		@m_effects = LoadEffects(unit, params);

		m_offset = GetParamVec2(unit, params, "offset", false);

		@m_effectParams = LoadEffectParams(unit, params);

		m_preRenderables.insertLast(this);
	}

	void SetRotateSpeedTarget(float target, int overTime)
	{
		if (m_speedRotateMulTargetTime > 0)
			m_speedRotateMul = m_speedRotateMulTarget;

		m_speedRotateMulTarget = target;
		m_speedRotateMulTargetBefore = m_speedRotateMul;
		m_speedRotateMulTargetTime = overTime;
		m_speedRotateMulTargetTimeC = 0;
	}

	vec2 GetCurrentOffset(int idt)
	{
		float dt = idt / 33.0f;
		float angle = lerp(m_prevAngle, m_currAngle, dt);
		float dist = lerp(m_prevDistance, m_currDistance, dt);
		vec2 dir = vec2(cos(angle), sin(angle));
		return dir * dist + m_offset;
	}

	void Set(float angle, BossEye@ owner)
	{
		@m_owner = owner;

		m_prevAngle = m_currAngle = angle;
		m_prevDistance = m_currDistance = 50.0f;

		vec3 pos = m_unit.GetPosition() + xyz(GetCurrentOffset(0));
		m_unit.SetPosition(pos);

		m_unit.SetUnitScene(m_sceneIntro, true);
		m_appearTimeC = m_sceneIntro.Length();
	}

	void Disappear()
	{
		m_unit.SetUnitScene(m_sceneOutro, true);
		m_disappearTimeC = m_sceneOutro.Length();
	}

	void Update(int dt)
	{
		if (m_appearTimeC > 0)
		{
			m_appearTimeC -= dt;
			if (m_appearTimeC <= 0)
				m_unit.SetUnitScene(m_sceneIdle, true);
		}

		if (m_speedRotateMulTargetTime > 0)
		{
			m_speedRotateMulTargetTimeC += dt;
			if (m_speedRotateMulTargetTimeC >= m_speedRotateMulTargetTime)
			{
				m_speedRotateMul = m_speedRotateMulTarget;
				m_speedRotateMulTargetTime = 0;
			}
			else
			{
				float scalar = m_speedRotateMulTargetTimeC / float(m_speedRotateMulTargetTime);
				m_speedRotateMul = lerp(m_speedRotateMulTargetBefore, m_speedRotateMulTarget, scalar);
			}
		}

		m_prevAngle = m_currAngle;
		m_currAngle += (dt / 50.0f) * 0.1f * m_speedRotateMul;

		if (m_target !is null)
		{
			m_prevDistance = m_currDistance;

			float targetDistance = dist(m_target.m_unit.GetPosition(), m_owner.m_unit.GetPosition());
			m_currDistance = lerp(m_currDistance, targetDistance, 0.05f * m_speedDistanceMul);

			if (m_currDistance < m_minDistance)
				m_currDistance = m_minDistance;
			else if (m_currDistance > m_maxDistance)
				m_currDistance = m_maxDistance;
		}

		if (m_disappearTimeC > 0)
		{
			m_disappearTimeC -= dt;
			if (m_disappearTimeC <= 0)
			{
				m_unit.Destroy();
				return;
			}
		}
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null || actor.Team == m_owner.Team)
			return;

		ApplyEffects(m_effects, m_owner, unit, pos, normal, 1.0f, false);
	}

	bool PreRender(int idt)
	{
		if (m_owner is null)
		{
			PrintError("Wisp owner is null!");
			return false;
		}

		if (IsPaused())
			idt = 0;

		vec3 pos = m_owner.m_unit.GetInterpolatedPosition(idt);
		pos += xyz(GetCurrentOffset(idt));
		m_unit.SetPosition(pos);

		return m_unit.IsDestroyed();
	}

	SValue@ Save()
	{
		SValueBuilder builder;
		builder.PushDictionary();
		builder.PushInteger("owner", m_owner.m_unit.GetId());
		builder.PushFloat("angle", m_currAngle);
		builder.PushFloat("distance", m_currDistance);
		builder.PopDictionary();
		return builder.Build();
	}

	void PostLoad(SValue@ data)
	{
		UnitPtr unitOwner = g_scene.GetUnit(GetParamInt(UnitPtr(), data, "owner", false));
		if (unitOwner.IsValid())
		{
			@m_owner = cast<BossEye>(unitOwner.GetScriptBehavior());
			if (m_owner !is null)
				m_owner.m_wisps.insertLast(this);
		}

		m_prevAngle = m_currAngle = GetParamFloat(UnitPtr(), data, "angle", false);
		m_prevDistance = m_currDistance = GetParamFloat(UnitPtr(), data, "distance", false);
	}
}
