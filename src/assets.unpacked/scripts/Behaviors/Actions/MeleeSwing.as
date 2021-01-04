class MeleeSwing : IAction
{
	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_missEffects;

	float m_teamDmg;
	int m_dist;
	int m_rays;
	float m_angleDelta;
	float m_angleOffset;
	int m_interval;
	int m_delay;
	float m_intensity;
	float m_effectAngleOffset;
	bool m_husk;

	int m_raysC;
	int m_intervalC;
	float m_angle;
	array<UnitPtr> m_arrHit;

	Actor@ m_owner;

	string m_hitFx;

	SoundEvent@ m_damageSound;

	MeleeSwing(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
		@m_missEffects = LoadEffects(unit, params, "miss-");

		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		m_dist = GetParamInt(unit, params, "dist", false, 10);

		m_rays = GetParamInt(unit, params, "rays", false, 3);
		m_angleDelta = GetParamFloat(unit, params, "angledelta", false, 20) * PI / 180;
		m_angleOffset = GetParamFloat(unit, params, "angleoffset", false, 0) * PI / 180;
		m_interval = GetParamInt(unit, params, "interval", false, 50);
		m_delay = GetParamInt(unit, params, "delay", false, 0);
		m_effectAngleOffset = GetParamFloat(unit, params, "effect-angle-offset", false, 70) * PI / 180;

		m_hitFx = GetParamString(unit, params, "hit-fx", false);

		@m_damageSound = Resources::GetSoundEvent(GetParamString(unit, params, "damage-sound", false));
	}
	
	void SetWeaponInformation(uint weapon)
	{
		PropagateWeaponInformation(m_effects, weapon);
		PropagateWeaponInformation(m_missEffects, weapon);
	}

	bool NeedNetParams() { return true; }

	void StartSwing(Actor@ owner, vec2 dir, float intensity, bool husk)
	{
		if (m_raysC <= 0)
		{
			m_raysC = m_rays;
			m_intervalC = m_delay;
			m_angle = atan(dir.y, dir.x) + m_angleOffset;
			m_intensity = intensity;
			m_arrHit.removeRange(0, m_arrHit.length());

			@m_owner = owner;
			m_husk = husk;
		}
	}

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		builder.PushFloat(intensity);
		StartSwing(owner, dir, intensity, false);
		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		StartSwing(owner, dir, param.GetFloat(), true);
		return true;
	}

	void Update(int dt, int cooldown)
	{
		if (m_raysC <= 0)
			return;

		if (m_intervalC > 0)
		{
			m_intervalC -= dt;
			if (m_intervalC > 0)
				return;
		}

		m_intervalC = m_interval;

		bool hitSomething = false;

		vec2 ownerPos = xy(m_owner.m_unit.GetPosition()) + vec2(0, -Tweak::PlayerCameraHeight);
		vec2 rayPos = ownerPos + vec2(cos(m_angle), sin(m_angle)) * m_dist;
		array<RaycastResult>@ rayResults = g_scene.Raycast(ownerPos, rayPos, ~0, RaycastType::Shot);
		for (uint i = 0; i < rayResults.length(); i++)
		{
			UnitPtr unit = rayResults[i].FetchUnit(g_scene);
			if (!unit.IsValid())
				continue;

			if (unit == m_owner.m_unit)
				continue;

			bool alreadyHit = false;
			for (uint j = 0; j < m_arrHit.length(); j++)
			{
				if (m_arrHit[j] == unit)
				{
					alreadyHit = true;
					break;
				}
			}
			if (alreadyHit)
				continue;

			m_arrHit.insertLast(unit);

			float angle = m_angle + m_effectAngleOffset;
			vec2 dir = vec2(cos(angle), sin(angle));
			ApplyEffects(m_effects, m_owner, unit, xy(unit.GetPosition()), dir, m_intensity, m_husk, 0, m_teamDmg);

			dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
			PlayEffect(m_hitFx, rayResults[i].point, ePs);

			hitSomething = true;
		}

		if (hitSomething)
			PlaySound3D(m_damageSound, m_owner.m_unit.GetPosition());

		if (--m_raysC <= 0)
		{
			m_arrHit.removeRange(0, m_arrHit.length());
			return;
		}

		m_angle += m_angleDelta;
	}
}
