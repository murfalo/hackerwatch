class BlinkStrikeSkill : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;

	AnimString@ m_animBlink;
	AnimString@ m_animHidden;
	AnimString@ m_animMelee;

	UnitScene@ m_fxBlinkOut;
	UnitScene@ m_fxBlinkIn;

	SoundEvent@ m_sndBlinkOut;
	SoundEvent@ m_sndBlinkIn;

	bool m_safeSpawning;

	int m_cooldown;
	int m_cooldownC;

	bool m_blinking;

	int m_castBlinkC;
	int m_castMeleeC;

	int m_blinkDelay;
	int m_blinkDelayRandom;
	int m_blinkDelayC;

	int m_castPointMelee;
	int m_castPointMeleeC;

	float m_blinkDistance;
	float m_blinkDistanceRandom;
	float m_arc;
	float m_meleeRangeSq;

	string m_offset;

	CompositeActorSkillRestrictions m_restrictions;

	array<IEffect@>@ m_effectsBlink;
	array<IEffect@>@ m_effects;

	array<IAction@>@ m_actions;

	BlinkStrikeSkill(UnitPtr unit, SValue &params)
	{
		@m_animBlink = AnimString(GetParamString(unit, params, "anim-blink"));
		@m_animHidden = AnimString(GetParamString(unit, params, "anim-hidden"));
		@m_animMelee = AnimString(GetParamString(unit, params, "anim-melee"));

		@m_fxBlinkOut = Resources::GetEffect(GetParamString(unit, params, "fx-blink-out", false));
		@m_fxBlinkIn = Resources::GetEffect(GetParamString(unit, params, "fx-blink-in", false));

		@m_sndBlinkOut = Resources::GetSoundEvent(GetParamString(unit, params, "snd-blink-out", false));
		@m_sndBlinkIn = Resources::GetSoundEvent(GetParamString(unit, params, "snd-blink-in", false));

		m_safeSpawning = GetParamBool(unit, params, "safe-spawn", false, true);

		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));

		m_blinkDelay = GetParamInt(unit, params, "blink-delay", false);
		m_blinkDelayRandom = GetParamInt(unit, params, "blink-delay-random", false);

		m_castPointMelee = GetParamInt(unit, params, "cast-point-melee");

		m_blinkDistance = GetParamFloat(unit, params, "blink-distance", false, 10.0f);
		m_blinkDistanceRandom = GetParamFloat(unit, params, "blink-distance-random", false, 10.0f);
		m_arc = GetParamFloat(unit, params, "arc", false, 90.0f) * PI / 180;
		m_meleeRangeSq = GetParamFloat(unit, params, "melee-range", false, 15.0f);
		m_meleeRangeSq *= m_meleeRangeSq;

		m_offset = GetParamString(unit, params, "offset", false);

		@m_effectsBlink = LoadEffects(unit, params, "blink-");
		@m_effects = LoadEffects(unit, params);

		@m_actions = LoadActions(unit, params);

		m_restrictions.Load(unit, params);
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
		m_id = id;

		m_restrictions.Initialize(unit, behavior);
	}

	void NetUseSkill(int stage, SValue@ param)
	{
		if (stage == 0)
		{
			m_blinking = true;
			m_unit.SetUnitScene(m_animBlink.GetSceneName(m_behavior.m_movement.m_dir), true);

			m_castBlinkC = m_unit.GetCurrentUnitScene().Length();
			if (m_castBlinkC <= 0)
				m_castBlinkC = 1;

			PlayEffect(m_fxBlinkOut, m_unit.GetPosition());
			PlaySound3D(m_sndBlinkOut, m_unit.GetPosition());

			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			vec2 dir = xy(m_unit.GetPosition() - m_behavior.m_target.m_unit.GetPosition());
			ApplyEffects(m_effectsBlink, m_behavior, m_behavior.m_target.m_unit, pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer());

			m_restrictions.UseCharge();
		}
		else if (stage == 1)
		{
			auto arrParam = param.GetArray();
			vec2 newPos = arrParam[0].GetVector2();
			vec2 aimDir = arrParam[1].GetVector2();

			m_unit.SetPosition(xyz(newPos));
			m_behavior.m_movement.m_dir = atan(aimDir.y, aimDir.x);

			PlayEffect(m_fxBlinkIn, newPos);
			PlaySound3D(m_sndBlinkIn, xyz(newPos));

			m_behavior.m_targetable = true;

			m_blinking = false;
			m_unit.SetUnitScene(m_animMelee.GetSceneName(m_behavior.m_movement.m_dir), true);

			m_castMeleeC = m_unit.GetCurrentUnitScene().Length();
			m_castPointMeleeC = m_castPointMelee;
		}
		else if (stage == 2)
		{
			vec2 pos = FetchOffsetPos(m_unit, m_offset);
			NetDoActions(m_actions, param, m_behavior, pos, vec2());
		}
		else if (stage == 3)
		{
			m_behavior.m_targetable = false;

			m_unit.SetUnitScene(m_animHidden.GetSceneName(m_behavior.m_movement.m_dir), true);
			m_blinkDelayC = param.GetInteger();
		}
	}

	bool RaycastQuickWithoutTarget(vec2 from, vec2 to)
	{
		UnitPtr target = m_behavior.m_target.m_unit;
		auto results = g_scene.Raycast(from, to, ~0, RaycastType::Any);
		for (uint i = 0; i < results.length(); i++)
		{
			auto unit = results[i].FetchUnit(g_scene);
			if (unit != target && unit != m_unit)
				return true;
		}
		return false;
	}

	vec2 GetBlinkPosition()
	{
		vec2 oldPos = xy(m_unit.GetPosition());
		vec2 pos = xy(m_behavior.m_target.m_unit.GetPosition());
		float d = (m_blinkDistance + randf() * m_blinkDistanceRandom);
		vec2 dir = normalize(oldPos - pos);

		if (!m_safeSpawning)
			return pos + dir * d;

		vec2 rot = dir;
		for (int i = 0; i < 4; i++)
		{
			if (!RaycastQuickWithoutTarget(pos, pos + rot * d))
				return pos + rot * d;
			rot = addrot(rot, PI / 2);
		}

		return pos + dir * d;
	}

	void PerformBlink()
	{
		if (m_behavior.m_target is null)
			return;

		if (!Network::IsServer())
			return;

		vec2 oldPos = xy(m_unit.GetPosition());
		vec2 newPos = GetBlinkPosition();
		vec2 aimDir = normalize(newPos - oldPos);

		SValueBuilder builder;
		builder.PushArray();
		builder.PushVector2(newPos);
		builder.PushVector2(aimDir);
		builder.PopArray();
		auto param = builder.Build();

		NetUseSkill(1, param);
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 1, param);
	}

	void Update(int dt, bool isCasting)
	{
		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}

		if (!isCasting && !IsCasting() && m_restrictions.IsAvailable() && Network::IsServer())
		{
			NetUseSkill(0, null);
			UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0);
		}

		if (m_castBlinkC > 0 || m_castMeleeC > 0)
			m_unit.GetPhysicsBody().SetLinearVelocity(0, 0);

		if (m_castBlinkC > 0)
		{
			m_castBlinkC -= dt;
			if (m_castBlinkC <= 0)
			{
				if (m_blinkDelay == 0)
					PerformBlink();
				else
				{
					if (Network::IsServer())
					{
						SValueBuilder builder;
						builder.PushInteger(m_blinkDelay + randi(m_blinkDelayRandom));
						SValue@ svParams = builder.Build();

						NetUseSkill(3, svParams);
						UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 3, svParams);
					}
				}
			}
		}
		else if (m_blinkDelayC > 0)
		{
			m_blinkDelayC -= dt;
			if (m_blinkDelayC <= 0)
				PerformBlink();
		}
		else if (m_castPointMeleeC > 0)
		{
			m_castPointMeleeC -= dt;
			if (m_castPointMeleeC <= 0)
			{
				float length = distsq(m_behavior.m_target.m_unit.GetPosition(), m_unit.GetPosition());
				vec2 dir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition()));

				if (length < m_meleeRangeSq)
				{
					float angle = m_behavior.m_movement.m_dir - atan(dir.y, dir.x);
					angle += (angle > PI) ? -TwoPI : (angle < -PI) ? TwoPI : 0;

					if (abs(angle) <= m_arc / 2)
					{
						vec2 pos = FetchOffsetPos(m_unit, m_offset);
						ApplyEffects(m_effects, m_behavior, m_behavior.m_target.m_unit, pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer());
					}
				}

				if (Network::IsServer())
				{
					vec2 pos = FetchOffsetPos(m_unit, m_offset);
					SValue@ param = DoActions(m_actions, m_behavior, m_behavior.m_target, pos, dir, 1.0f);
					UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 2, param);
				}
			}
		}

		if (m_castMeleeC > 0)
		{
			m_castMeleeC -= dt;
			if (m_castMeleeC <= 0)
				m_cooldownC = m_cooldown;
		}
	}

	bool IsCasting()
	{
		return m_blinking || m_castMeleeC > 0;
	}

	void OnDamaged() {}
	void OnDeath() {}
	void Destroyed() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}

	void CancelSkill()
	{
		m_blinking = false;
		m_castBlinkC = 0;
		m_castMeleeC = 0;
		m_castPointMeleeC = 0;
	}

	void Save(SValueBuilder& builder)
	{
		builder.PushInteger("cast-blink", m_castBlinkC);
		builder.PushInteger("cast-melee", m_castMeleeC);
	}

	void Load(SValue@ sval)
	{
		m_castBlinkC = GetParamInt(UnitPtr(), sval, "cast-blink");
		m_castMeleeC = GetParamInt(UnitPtr(), sval, "cast-melee");

		m_blinking = (m_castBlinkC > 0);
	}
}
