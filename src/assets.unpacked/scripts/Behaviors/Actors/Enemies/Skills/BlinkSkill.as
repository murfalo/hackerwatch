class BlinkSkill : ICompositeActorSkill
{
	AnimString@ m_anim;

	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;

	int m_cooldown;
	int m_cooldownC;

	float m_distance;
	float m_distanceOff;
	float m_spread;

	int m_castpoint;
	int m_castpointC;

	SoundEvent@ m_sound;
	UnitScene@ m_effect;
	uint m_effectHash;

	CompositeActorSkillRestrictions m_restrictions;

	array<IEffect@>@ m_effectsBlink;
	
	

	BlinkSkill(UnitPtr unit, SValue& params)
	{
		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = GetParamInt(unit, params, "cooldown-start", false, randi(m_cooldown));

		m_restrictions.Load(unit, params);

		m_distance = GetParamFloat(unit, params, "distance");
		m_distanceOff = GetParamFloat(unit, params, "off-distance", false, 16.0);
		m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;

		m_castpoint = GetParamInt(unit, params, "castpoint", false, 0);

		@m_anim = AnimString(GetParamString(unit, params, "anim", false, ""));
		
		@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
		
		auto effectString = GetParamString(unit, params, "fx", false);
		@m_effect = Resources::GetEffect(effectString);
		m_effectHash = HashString(effectString);

		@m_effectsBlink = LoadEffects(unit, params, "blink-");
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
		m_id = id;
		
		m_restrictions.Initialize(unit, behavior);
	}

	void Save(SValueBuilder& builder)
	{
		m_restrictions.Save(builder);
	}

	void Load(SValue@ sval)
	{
		m_restrictions.Load(sval);
	}
	
	void CancelSkill() 
	{
		m_castpointC = 0;
	}

	void Update(int dt, bool isCasting)
	{
		if (!Network::IsServer())
			return;

		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}

		if (m_behavior.m_target is null)
			return;

		if (!isCasting)
		{
			if (m_restrictions.IsAvailable() && m_restrictions.CanSee(m_behavior.m_target.m_unit))
			{
				if (m_castpoint > 0)
					m_castpointC = m_castpoint;
				else
					CastBlink();
			}
		}
		else
		{
			auto body = m_unit.GetPhysicsBody();
			if (body !is null)
				body.SetLinearVelocity(0, 0);

			UnitPtr target = m_behavior.m_target.m_unit;
			vec3 pos = m_unit.GetPosition();
			vec2 dir = normalize(xy(target.GetPosition()) - xy(pos));
			m_behavior.SetUnitScene(m_anim.GetSceneName(atan(dir.y, dir.x)), false);

			if (m_castpointC > 0)
			{
				m_castpointC -= dt;
				if (m_castpointC <= 0)
					CastBlink();
			}
		}
	}

	void CastBlink()
	{
		m_cooldownC = m_cooldown;
		vec3 pos = m_unit.GetPosition();

		UnitPtr target = m_behavior.m_target.m_unit;

		// Do initial blink effects
		NetUseSkill(0, null);
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0);

		// Teleport
		vec2 dir = normalize(xy(target.GetPosition()) - xy(pos));
		if (m_spread > 0)
		{
			float ang = atan(dir.y, dir.x) + (randf() - 0.5) * m_spread;
			dir = vec2(cos(ang), sin(ang));
		}
		
		vec2 newPos = xy(pos) + dir * m_distance;

		// Check if there's something in between
		auto results = g_scene.Raycast(xy(pos), newPos, ~0, RaycastType::Any);
		for (uint i = 0; i < results.length(); i++)
		{
			auto teleRes = results[i];
			UnitPtr unit = teleRes.FetchUnit(g_scene);
			if (!unit.IsValid() || unit == m_unit || cast<Player>(unit.GetScriptBehavior()) !is null)
				continue;

			auto act = cast<Actor>(unit.GetScriptBehavior());
			if (act !is null && !act.Impenetrable() && act.Team == m_behavior.Team)
				continue;

			float dist = length(teleRes.point - xy(pos)) - m_distanceOff;
			if (m_distance < 0)
				dist *= -1;

			newPos = xy(pos) + dir * dist;

			if (m_distanceOff > 0)
			{
				// Make sure the distance offset is available too
				auto resultsOff = g_scene.Raycast(teleRes.point, newPos, ~0, RaycastType::Any);
				for (uint j = 0; j < resultsOff.length(); j++)
				{
					auto offRes = resultsOff[j];
					UnitPtr offUnit = offRes.FetchUnit(g_scene);
					if (!offUnit.IsValid() || unit == m_unit || cast<Player>(unit.GetScriptBehavior()) !is null)
						continue;

					newPos = offRes.point;
					break;
				}
			}
			break;
		}
		
		if (m_effect !is null)
		{
			PlayEffect(m_effect, xy(pos));
			PlayEffect(m_effect, newPos);
			(Network::Message("PlayEffect") << m_effectHash << xy(pos)).SendToAll();
		}

		m_unit.SetPosition(xyz(newPos));
		PlaySound3D(m_sound, m_unit);

		(Network::Message("UnitUseSSkill") << m_unit << m_id << 1 << newPos).SendToAll();
		
		m_restrictions.UseCharge();
	}

	bool IsCasting()
	{
		return m_castpointC > 0;
	}

	void OnDamaged() { }
	void OnDeath() { }
	void Destroyed() { }
	void OnCollide(UnitPtr unit, vec2 normal) { }
	void NetUseSkill(int stage, SValue@ param) 
	{
		if (stage == 0)
		{
			vec2 pos = xy(m_unit.GetPosition());
			vec2 dir = pos - xy(m_behavior.m_target.m_unit.GetPosition());
			ApplyEffects(m_effectsBlink, m_behavior, m_behavior.m_target.m_unit, pos, dir, m_behavior.m_buffs.DamageMul(), !Network::IsServer());
		}
		else if (stage == 1)
		{
			PlayEffect(m_effect, xy(m_unit.GetPosition()));
			PlaySound3D(m_sound, m_unit);

			m_restrictions.UseCharge();
		}
	}
}
