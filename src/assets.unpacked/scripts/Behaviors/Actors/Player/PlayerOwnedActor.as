class PlayerOwnedActor : CompositeActorBehavior, IOwnedUnit, IPlayerActorDamager
{
	PlayerBase@ m_ownerPlayer;
	PlayerRecord@ m_ownerRecord;

	int m_ttl;

	OverheadBossBar@ m_bossBar;

	float m_intensity;

	bool m_colorize;

	PlayerOwnedActor(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_ttl = GetParamInt(unit, params, "ttl", false, -1);

		auto bossBarWidth = GetParamInt(unit, params, "overhead-bossbar-width", false, -1);
		if (bossBarWidth > 0)
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm !is null)
				@m_bossBar = gm.AddBossBarActor(this, bossBarWidth, -m_unitHeight);
		}

		m_unit.SetUpdateDistanceLimit(0);
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		m_unit.SetShouldCollideWithTeam(false);

		m_intensity = intensity;

		auto ownerPlr = cast<PlayerBase>(owner);
		if (ownerPlr !is null)
		{
			@m_ownerPlayer = ownerPlr;
			@m_ownerRecord = ownerPlr.m_record;
		}

		for (uint i = 0; i < m_skills.length(); i++)
		{
			auto skill = cast<CompositeActorSkill>(m_skills[i]);
			if (skill is null)
				continue;

			PropagateWeaponInformation(skill.m_actions, weaponInfo);
			PropagateWeaponInformation(skill.m_startActions, weaponInfo);
		}
	}

	DamageInfo DamageActor(Actor@ actor, DamageInfo di)
	{
		if (m_ownerRecord is null)
			return di;

		auto plr = cast<PlayerBase>(m_ownerRecord.actor);
		if (plr is null)
			return di;

		return plr.DamageActor(actor, di);
	}

	void DamagedActor(Actor@ actor, DamageInfo di)
	{
		if (m_ownerRecord is null)
			return;

		auto plr = cast<PlayerBase>(m_ownerRecord.actor);
		if (plr is null)
			return;

		di.LifestealMul = 0;
		plr.DamagedActor(actor, di);
	}

	void KilledActor(Actor@ killed, DamageInfo di) override
	{
		if (m_ownerRecord is null)
			return;

		auto plr = cast<PlayerBase>(m_ownerRecord.actor);
		if (plr is null)
			return;

		plr.KilledActor(killed, di);
	}

	void Update(int dt) override
	{
		CompositeActorBehavior::Update(dt);

		if (m_ttl > 0 && !IsDead())
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
				OnDeath(DamageInfo(0, null, 1, false, true, 0), vec2(1, 0));
		}
	}
	
	void Destroyed() override
	{
		CompositeActorBehavior::Destroyed();

		if (m_bossBar !is null)
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm !is null)
			{
				int index = gm.m_arrBosses.findByRef(m_bossBar);
				if (index != -1)
					gm.m_arrBosses.removeAt(index);
			}
			@m_bossBar = null;
		}
	}
}
