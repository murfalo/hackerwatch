class BossLichRandomSkill : CompositeActorPeriodicTriggeredSkill
{
	int m_maxRange;

	int m_meleeRange;
	float m_meleeChance;

	int m_meleeCooldown;
	int m_meleeCooldownC;

	BossLichRandomSkill(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_maxRange = GetParamInt(unit, params, "max-range", false, -1);

		m_meleeRange = GetParamInt(unit, params, "melee-range");
		m_meleeChance = GetParamFloat(unit, params, "melee-chance", false, 0.5f);
		m_meleeCooldown = GetParamInt(unit, params, "melee-cooldown", false, 2000);
	}

	void Update(int dt, bool isCasting) override
	{
		auto behavior = cast<BossLich>(m_behavior);
		if (behavior is null)
		{
			PrintError("Owner behavior of BossLichRandomSkill is not a BossLich!");
			return;
		}

		if (m_maxRange != -1 && !isCasting)
		{
			array<UnitPtr>@ results = g_scene.FetchActorsWithOtherTeam(behavior.Team, xy(m_unit.GetPosition()), m_maxRange);
			if (results.length() == 0)
				return;
		}

		CompositeActorPeriodicTriggeredSkill::Update(dt, isCasting);

		if (isCasting)
			return;

		if (m_meleeCooldownC > 0)
		{
			m_meleeCooldownC -= dt;
			if (m_meleeCooldownC > 0)
				return;
		}

		array<UnitPtr>@ meleeRange = g_scene.FetchActorsWithOtherTeam(behavior.Team, xy(m_unit.GetPosition()), m_meleeRange);
		if (meleeRange.length() == 0)
			return;

		m_meleeCooldownC = m_meleeCooldown;

		if (Network::IsServer() && randf() <= m_meleeChance && IsAvailable())
		{
			m_periodC = m_period + randi(m_periodRandom);
			Trigger(m_unit);
		}
	}

	void Trigger(UnitPtr target) override
	{
		m_meleeCooldownC = m_meleeCooldown;

		CompositeActorPeriodicTriggeredSkill::Trigger(target);
	}
}
