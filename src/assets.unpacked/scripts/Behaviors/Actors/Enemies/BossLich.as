WorldScript::BossLichRoom@ g_lichRoom;

class BossLich : CompositeActorBehavior
{
	array<Actor@> m_actorsInside;

	array<IEffect@>@ m_effects;
	int m_effectsTime;
	int m_effectsTimeC;

	array<UnitPtr> m_insideWalls;

	BossLich(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_effects = LoadEffects(unit, params);
		m_effectsTime = GetParamInt(unit, params, "effects-time", false, 100);
		m_effectsTimeC = m_effectsTime;
	}

	void Update(int dt) override
	{
		if (g_lichRoom is null)
		{
			PrintError("You forgot to place a BossLichRoom worldscript!");
			return;
		}

		if (!g_lichRoom.IsInside(m_unit.GetPosition()) || m_insideWalls.length() > 0)
			@m_target = null;
		else if (m_target is null)
			m_targetSearchCd = 0;

		CompositeActorBehavior::Update(dt);

		for (uint i = 0; i < m_skills.length(); i++)
		{
			if (m_skills[i].IsCasting())
				return;
		}

		m_effectsTimeC -= dt;
		if (m_effectsTimeC <= 0)
		{
			m_effectsTimeC = m_effectsTime;

			for (uint i = 0; i < m_actorsInside.length(); i++)
			{
				auto player = cast<PlayerBase>(m_actorsInside[i]);
				if (player !is null)
					ApplyEffects(m_effects, this, player.m_unit, xy(player.m_unit.GetPosition()), vec2(), 1.0f, cast<PlayerHusk>(player) !is null);
			}
		}
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		m_actorsInside.insertLast(actor);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther) override
	{
		if (unit.GetScriptBehavior() is null && !fxOther.IsSensor())
			m_insideWalls.insertLast(unit);

		CompositeActorBehavior::Collide(unit, pos, normal, fxSelf, fxOther);
	}

	void EndCollision(UnitPtr unit)
	{
		int wallIndex = m_insideWalls.find(unit);
		if (wallIndex != -1)
			m_insideWalls.removeAt(wallIndex);

		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		int index = m_actorsInside.findByRef(actor);
		if (index != -1)
			m_actorsInside.removeAt(index);
	}

	vec2 GetCastDirection() override
	{
		array<UnitPtr>@ results = g_scene.FetchActorsWithOtherTeam(Team, xy(m_unit.GetPosition()), 300);
		if (results.length() == 0)
			return GetDirection();

		UnitPtr closestUnit = results[0];
		float closestDistance = distsq(results[0].GetPosition(), m_unit.GetPosition());

		for (uint i = 1; i < results.length(); i++)
		{
			float distance = distsq(results[i].GetPosition(), m_unit.GetPosition());
			if (distance < closestDistance)
			{
				closestDistance = distance;
				closestUnit = results[i];
			}
		}

		return normalize(xy(closestUnit.GetPosition() - m_unit.GetPosition()));
	}

	bool IsTargetable() override
	{
		auto body = m_unit.GetPhysicsBody();
		if (body !is null && !body.IsStatic())
			return false;

		return CompositeActorBehavior::IsTargetable();
	}

	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override
	{
		return !IsTargetable();
	}
}
