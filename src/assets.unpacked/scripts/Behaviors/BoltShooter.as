class BoltShooter : IOwnedUnit
{
	UnitPtr m_unit;
	Actor@ m_owner;
	int m_ownerPeer = -1;
	UnitScene@ m_fx;

	UnitScene@ m_loopFx;
	vec2 m_loopFxRadius;
	int m_loopFxInterval;
	int m_loopFxC;

	int m_ttl;
	int m_bolts;
	int m_height;
	int m_range;
	int m_spread;
	int m_shootC;
	int m_linkC;
	bool m_attached;
	bool m_husk;
	bool m_useStormlash;
	Skills::Stormlash@ m_stormlash;

	float m_intensity;
	float m_consecutiveMul;
	UnitPtr m_lastUnit;

	array<IEffect@>@ m_effects;
	array<IEffect@>@ m_linkEffects;


	BoltShooter(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_ttl = GetParamInt(unit, params, "ttl", true, 2000);

		m_bolts = GetParamInt(unit, params, "bolts", true, 5);
		m_height = GetParamInt(unit, params, "height", false, 0);
		m_spread = GetParamInt(unit, params, "spread", false, 0);
		m_range = GetParamInt(unit, params, "range", true, 100);
		m_attached = GetParamBool(unit, params, "attached", false, false);
		m_useStormlash = GetParamBool(unit, params, "use-stormlash", false, true);
		m_consecutiveMul = GetParamFloat(unit, params, "consecutive-mul", false, 1.0f);

		@m_fx = Resources::GetEffect(GetParamString(unit, params, "fx", false));
		@m_effects = LoadEffects(unit, params);
		@m_linkEffects = LoadEffects(unit, params, "link-");

		@m_loopFx = Resources::GetEffect(GetParamString(unit, params, "loop-fx", false));
		m_loopFxRadius = GetParamVec2(unit, params, "loop-fx-radius", false, vec2(100, 100));
		m_loopFxInterval = GetParamInt(unit, params, "loop-fx-interval", false, 100000);

		m_loopFxC = m_loopFxInterval;
		m_shootC = 0;
		m_linkC = 0;

		m_intensity = 1.0f;
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		@m_owner = owner;
		m_husk = husk;

		PropagateWeaponInformation(m_effects, weaponInfo);
		PropagateWeaponInformation(m_linkEffects, weaponInfo);

		if (m_useStormlash)
		{
			auto player = cast<PlayerBase>(owner);
			if (player !is null)
				@m_stormlash = cast<Skills::Stormlash>(player.m_skills[6]);
		}
	}

	SValue@ Save()
	{
		SValueBuilder builder;
		builder.PushDictionary();
		builder.PushInteger("owner", m_owner.m_unit.GetId());
		builder.PushBoolean("husk", m_husk);
		builder.PushInteger("last-unit", m_lastUnit.GetId());

		auto player = cast<PlayerBase>(m_owner);
		if (player !is null)
			builder.PushInteger("player", player.m_record.peer);

		builder.PopDictionary();
		return builder.Build();
	}

	void PostLoad(SValue@ data)
	{
		auto svOwner = data.GetDictionaryEntry("owner");
		if (svOwner !is null && svOwner.GetType() == SValueType::Integer)
		{
			UnitPtr unitOwner = g_scene.GetUnit(svOwner.GetInteger());
			if (unitOwner.IsValid())
				@m_owner = cast<Actor>(unitOwner.GetScriptBehavior());
		}

		auto svHusk = data.GetDictionaryEntry("husk");
		if (svHusk !is null && svHusk.GetType() == SValueType::Boolean)
			m_husk = svHusk.GetBoolean();

		auto svLastUnit = data.GetDictionaryEntry("last-unit");
		if (svLastUnit !is null && svLastUnit.GetType() == SValueType::Integer)
			m_lastUnit = g_scene.GetUnit(svLastUnit.GetInteger());

		auto svPlayer = data.GetDictionaryEntry("player");
		if (svPlayer !is null && svPlayer.GetType() == SValueType::Integer)
			m_ownerPeer = svPlayer.GetInteger();
	}

	void Update(int dt)
	{
		if (m_ownerPeer != -1)
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				auto player = g_players[i];
				if (player.peer != uint(m_ownerPeer))
					continue;

				@m_owner = player.actor;
				break;
			}
			m_ownerPeer = -1;
		}

		if (m_attached)
			m_unit.SetPosition(m_owner.m_unit.GetPosition());

		m_loopFxC -= dt;
		while(m_loopFxC <= 0)
		{
			m_loopFxC += m_loopFxInterval;

			vec3 pos = m_unit.GetPosition() + xyz(randdir() * randf() * m_loopFxRadius, 0);
			PlayEffect(m_loopFx, pos);
		}




		m_shootC -= dt;
		m_ttl -= dt;
		m_linkC -= dt;

		if (m_linkC <= 0 && m_linkEffects.length() > 0)
		{
			m_linkC += 150 + randi(100);

			vec2 pos = xy(m_unit.GetPosition());
			auto units = g_scene.FetchUnitsWithBehavior("BoltShooter", pos, m_range);
			for (uint i = 0; i < units.length(); i++)
			{
				if (units[i] == m_unit || units[i].GetId() < m_unit.GetId())
					continue;

				auto boltShooter = cast<BoltShooter>(units[i].GetScriptBehavior());
				if (boltShooter is null || boltShooter.m_linkEffects.length() <= 0)
					continue;

				if (boltShooter.m_owner !is m_owner)
					continue;

				auto epos = xy(units[i].GetPosition());
				auto dir = normalize(epos - pos);

				DrawLightningBolt(m_fx, pos + vec2(randi(m_spread) - m_spread / 2, randi(m_spread) - m_spread / 2 - m_height), epos + vec2(randi(8) - 4, randi(8) - 4));

				UnitPtr lastUnit = UnitPtr();
				auto results = g_scene.Raycast(pos, epos, ~0, RaycastType::Shot);
				for (uint j = 0; j < results.length(); j++)
				{
					RaycastResult res = results[j];
					UnitPtr res_unit = res.FetchUnit(g_scene);

					if (!res_unit.IsValid())
						continue;

					if (res_unit == lastUnit)
						continue;

					lastUnit = res_unit;

					auto damageTaker = cast<IDamageTaker>(res_unit.GetScriptBehavior());
					if (damageTaker !is null && damageTaker.ShootThrough(m_owner, res.point, dir))
						continue;

					ApplyEffects(m_linkEffects, m_owner, res_unit, res.point, dir, m_intensity, m_husk, 0, 0);
				}
			}
		}

		if (!m_husk)
		{
			SValueBuilder builder;
			builder.PushArray();

			int numAdded = 0;

			while (m_shootC <= 0 && m_bolts > 0)
			{
				m_shootC += m_ttl / m_bolts;
				m_bolts--;

				vec2 pos = xy(m_unit.GetPosition());
				auto enemies = g_scene.FetchActorsWithOtherTeam(m_owner.Team, pos, m_range);
				for (int i = 0; i < int(enemies.length()); i++)
				{
					UnitPtr e = enemies[i];
					auto actor = cast<Actor>(e.GetScriptBehavior());
					if (actor is null || !actor.IsTargetable())
					{
						enemies.removeAt(i);
						i--;
						continue;
					}

					auto rayResults = g_scene.Raycast(pos, xy(e.GetPosition()), ~0, RaycastType::Shot);
					for (uint j = 0; j < rayResults.length(); j++)
					{
						auto rayU = rayResults[j].FetchUnit(g_scene);
						if (rayU.GetScriptBehavior() is null)
						{
							enemies.removeAt(i);
							i--;
							break;
						}
					}
				}

				if (enemies.length() == 0)
					continue;

				int enemyi = randi(enemies.length());
				auto unit = enemies[enemyi];
				vec2 epos = xy(unit.GetPosition());
				auto dir = normalize(epos - pos);


				if (unit == m_lastUnit)
					m_intensity *= m_consecutiveMul;
				else
					m_intensity = 1.0f;

				m_lastUnit = unit;

				builder.PushArray();
				builder.PushVector2(pos);
				builder.PushVector2(epos);
				builder.PopArray();
				numAdded++;

				ApplyEffects(m_effects, m_owner, unit, epos, dir, m_intensity, m_husk);
				DrawLightningBolt(m_fx, pos + GetRandomSpread(), epos + GetRandomTarget());

				if (m_stormlash !is null)
				{
					float intensity = m_intensity;
					while (randf() <= m_stormlash.m_chance)
					{
						intensity *= m_stormlash.m_intensity;
						if (intensity <= 0.05f)
							break;

						enemies.removeAt(enemyi);
						if (enemies.length() <= 0)
							break;

						enemyi = randi(enemies.length());
						auto unit2 = enemies[enemyi];
						vec2 epos2 = xy(unit2.GetPosition());
						auto dir2 = normalize(epos2 - epos);

						builder.PushArray();
						builder.PushVector2(epos);
						builder.PushVector2(epos2);
						builder.PopArray();

						ApplyEffects(m_effects, m_owner, unit2, epos2, dir2, intensity, m_husk);
						DrawLightningBolt(m_fx, epos, epos2);

						epos = epos2;
					}
				}
			}

			builder.PopArray();

			if (numAdded > 0)
				(Network::Message("BoltShooter") << builder.Build()).SendToAll();
		}

		if (m_ttl <= 0 && m_bolts <= 0)
		{
			m_unit.Destroy();
			return;
		}
	}

	vec2 GetRandomSpread()
	{
		return vec2(randi(m_spread) - m_spread / 2, randi(m_spread) - m_spread / 2 - m_height);
	}

	vec2 GetRandomTarget()
	{
		return vec2(randi(8) - 4, randi(8) - 4);
	}
}

void DrawLightningBolt(UnitScene@ fx, vec2 from, vec2 to)
{
	if (fx is null)
		return;

	float length = dist(from, to);
	int segments = max(1, int(ceil(length / 30)));
	vec2 dir = (to - from) / length;
	float segLen = length / segments;
	vec2 side = vec2(-dir.y, dir.x);

	for (int i = 0; i < segments; i++)
	{
		vec2 a = from + dir * i * segLen;
		vec2 b = a + dir * segLen;

		if (i < segments -1)
			b = b + side * (randf() * 12 - 6);

		DrawLightningBoltSegment(fx, a, b);
	}
}

void DrawLightningBoltSegment(UnitScene@ fx, vec2 from, vec2 to)
{
	vec2 diff = to - from;
	dictionary ePs = {
		{ 'dx', diff.x },
		{ 'dy', diff.y },
		{ 'angle', atan(diff.y, diff.x) },
		{ 'length', length(diff) }
	};

	PlayEffect(fx, from, ePs);
}

