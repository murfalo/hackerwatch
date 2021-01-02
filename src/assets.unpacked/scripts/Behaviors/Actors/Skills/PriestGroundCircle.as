class PriestGroundCircle : IOwnedUnit
{
	UnitPtr m_unit;
	Actor@ m_owner;

	//array<Actor@> m_insideActors;

	int m_ttl;

	int m_interval;
	int m_intervalC;

	int m_damage;
	int m_radius;

	float m_healScale;

	uint m_weaponInfo;

	PriestGroundCircle(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_ttl = GetParamInt(unit, params, "ttl");
		m_interval = m_intervalC = GetParamInt(unit, params, "interval");
		m_damage = GetParamInt(unit, params, "damage");
		m_radius = GetParamInt(unit, params, "radius");
		m_healScale = GetParamFloat(unit, params, "heal-scale");
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		@m_owner = owner;

		m_weaponInfo = weaponInfo;
	}
/*
	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		m_insideActors.insertLast(actor);
	}

	void EndCollision(UnitPtr unit)
	{
		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		int index = m_insideActors.findByRef(actor);
		if (index != -1)
			m_insideActors.removeAt(index);
	}
*/
	void Trigger()
	{
		array<Actor@> friendlies;

		auto insideActors = g_scene.FetchUnitsWithBehavior("Actor", xy(m_unit.GetPosition()), m_radius, true);
		
		int totalDamage = 0;
		for (uint i = 0; i < insideActors.length(); i++)
		{
			UnitPtr unit = insideActors[i];
			auto actor = cast<Actor>(unit.GetScriptBehavior());
			if (!actor.IsTargetable())
				continue;

			if (actor.Team != m_owner.Team)
			{
				unit.TriggerCallbacks(UnitEventType::Damaged);
				totalDamage += actor.Damage(DamageInfo(m_owner, 0, m_damage, false, true, m_weaponInfo), xy(actor.m_unit.GetPosition()), vec2());
			}
			else
				friendlies.insertLast(actor);
		}

		if (totalDamage > 0 && friendlies.length() > 0)
		{
			float healAmount = totalDamage * m_healScale;
			int healPerPlayer = int(max(1.0f, healAmount / friendlies.length()));
			for (uint i = 0; i < friendlies.length(); i++)
			{
				auto plr = cast<PlayerBase>(friendlies[i]);
				if (!plr.IsHusk())
					plr.Heal(healPerPlayer);
				else
					(Network::Message("HealPlayer") << healPerPlayer).SendToPeer(plr.m_record.peer);
			}
		}
	}

	void Update(int dt)
	{
		if (m_ttl > 0)
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
			{
				m_unit.Destroy();
				return;
			}
		}

		if (m_owner is null)
		{
			PrintError("PriestGroundCircle has no owner, using GetLocalPlayer!");
			@m_owner = GetLocalPlayer();
			return;
		}
		
		if (m_owner.IsHusk())
			return;

		if (m_intervalC > 0)
		{
			m_intervalC -= dt;
			if (m_intervalC <= 0)
			{
				m_intervalC = m_interval;
				Trigger();
			}
		}
	}
}
