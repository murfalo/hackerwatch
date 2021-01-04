class SafetyAreaBehavior : FixedPathFollower
{
	int m_cooldown;
	int m_cooldownC;

	int m_range;

	array<IEffect@>@ m_effectsOutside;

	SafetyAreaBehavior(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_cooldown = GetParamInt(unit, params, "cooldown");
		m_cooldownC = m_cooldown;

		m_range = GetParamInt(unit, params, "range");

		@m_effectsOutside = LoadEffects(unit, params, "outside-");
	}

	void SetPaused(bool pause) override
	{
		if (m_paused && !pause)
			m_cooldownC = m_cooldown;

		FixedPathFollower::SetPaused(pause);
	}

	void Update(int dt) override
	{
		FixedPathFollower::Update(dt);

		if (m_paused)
			return;

		if (m_cooldownC > 0)
		{
			m_cooldownC -= dt;
			return;
		}

		auto unitsInside = g_scene.QueryCircle(xy(m_unit.GetPosition()), m_range, ~0, RaycastType::Shot);

		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == 255)
				continue;

			auto player = cast<PlayerBase>(g_players[i].actor);
			if (player is null)
				continue;

			if (unitsInside.find(player.m_unit) != -1)
				continue;

			ApplyEffects(m_effectsOutside, null, player.m_unit, vec2(), vec2(), 1.0f, !Network::IsServer());
		}

		m_cooldownC = m_cooldown;
	}
}
