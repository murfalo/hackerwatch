class DangerAreaBehavior : IOwnedUnit
{
	UnitPtr m_unit;

	int m_time;
	int m_ttl;
	int m_freq;
	DamageFilter m_filter;
	float m_selfDmg;
	float m_teamDmg;
	
	array<IEffect@>@ m_effects;
	array<UnitPtr> m_units;
	
	Actor@ m_owner;
	int m_ownerPeer = -1;
	float m_intensity;
	bool m_husk;
	int m_radius;
	
	bool m_netsynced;
	EffectParams@ m_effectParams;
	

	DangerAreaBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		
		auto currScene = m_unit.GetCurrentUnitScene();
		
		m_freq = GetParamInt(unit, params, "freq", false, 500);
		m_filter = DamageFilter(GetParamInt(unit, params, "actor-filter", false, 71));
		m_ttl = GetParamInt(unit, params, "ttl", false, currScene !is null ? currScene.Length() : 1000);
		m_radius = GetParamInt(unit, params, "radius", false, -1);
		@m_effects = LoadEffects(unit, params);
		
		m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
		m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
		
		m_intensity = 1.0;
		m_husk = !Network::IsServer();

		m_netsynced = IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode());
		@m_effectParams = LoadEffectParams(unit, params);
	}
	
	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		@m_owner = owner;
		m_intensity = intensity;
		m_husk = husk;

		PropagateWeaponInformation(m_effects, weaponInfo);
	}
	
	SValue@ Save()
	{
		SValueBuilder sval;
		sval.PushDictionary();
		
		sval.PushInteger("ttl", m_ttl);
		
		if (m_intensity != 1.0)
			sval.PushFloat("intensity", m_intensity);
			
		if (m_owner !is null && m_owner.m_unit.IsValid())
			sval.PushInteger("owner", m_owner.m_unit.GetId());

		auto player = cast<PlayerBase>(m_owner);
		if (player !is null)
			sval.PushInteger("player", player.m_record.peer);
			
		return sval.Build();
	}
	
	void Load(SValue@ data)
	{
		auto ttl = data.GetDictionaryEntry("ttl");
		if (ttl !is null && ttl.GetType() == SValueType::Integer)
			m_ttl = ttl.GetInteger();
	
		auto intensity = data.GetDictionaryEntry("intensity");
		if (intensity !is null && intensity.GetType() == SValueType::Float)
			m_intensity = intensity.GetFloat();
	}
	
	void PostLoad(SValue@ data)
	{
		auto owner = data.GetDictionaryEntry("owner");
		if (owner !is null && owner.GetType() == SValueType::Integer)
		{
			auto ownerUnit = g_scene.GetUnit(owner.GetInteger());
			if (ownerUnit.IsValid())
				@m_owner = cast<Actor>(ownerUnit.GetScriptBehavior());
		}

		auto svPlayer = data.GetDictionaryEntry("player");
		if (svPlayer !is null && svPlayer.GetType() == SValueType::Integer)
			m_ownerPeer = svPlayer.GetInteger();
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		if (!WorldScript::ApplyDamageFilter(unit, m_filter))
			return;

		m_units.insertLast(unit);
		ApplyDamage(unit, pos);
	}
	
	void EndCollision(UnitPtr unit)
	{
		if (!WorldScript::ApplyDamageFilter(unit, m_filter))
			return;
		
		for (uint i = 0; i < m_units.length();)
		{
			if (m_units[i] == unit)
			{
				m_units.removeAt(i);
				return;
			}
			else
				i++;
		}
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

		if (m_ttl > 0 && Network::IsServer() || !m_netsynced)
		{
			m_ttl -= dt;

			if (m_effectParams !is null)
				m_effectParams.Set("ttl", float(m_ttl));
			
			if (m_ttl <= 0)
				m_unit.Destroy();
		}
		
		if (m_freq > 0)
		{
			m_time -= dt;
			while (m_time < 0)
			{
				m_time += m_freq;
				TickDamage();
			}
		}
	}
	
	void TickDamage()
	{
		if (m_radius <= 0)
		{
			for (uint i = 0; i < m_units.length(); i++)
				ApplyDamage(m_units[i], xy(m_units[i].GetPosition()));
		}
		else
		{
			auto results = g_scene.QueryCircle(xy(m_unit.GetPosition()), m_radius, ~0, RaycastType::Shot, true);
			for (uint i = 0; i < results.length(); i++)
			{
				if (WorldScript::ApplyDamageFilter(results[i], m_filter))
					ApplyDamage(results[i], xy(results[i].GetPosition()));
			}
		}
	}

	void ApplyDamage(UnitPtr unit, vec2 pos)
	{
		vec2 dir = normalize(xy(m_unit.GetPosition()) - pos);
		ApplyEffects(m_effects, m_owner, unit, pos, dir, m_intensity, m_husk, m_selfDmg, m_teamDmg);
	}
}