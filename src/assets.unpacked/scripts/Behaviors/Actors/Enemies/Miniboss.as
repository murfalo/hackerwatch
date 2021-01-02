class Miniboss : CompositeActorBehavior
{
	int m_bossBarWidth;
	OverheadBossBar@ m_bossBar;
	int m_bossBarTimeC;

	Miniboss(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_bossBarWidth = GetParamInt(unit, params, "overhead-bossbar-width", false, -1);
	}

	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		CompositeActorBehavior::NetDamage(dmg, pos, dir);

		if (!IsDead() && dmg.Damage != 0 && m_bossBarWidth != -1)
		{
			m_bossBarTimeC = 3000;
			if (m_bossBar is null)
			{
				auto gm = cast<Campaign>(g_gameMode);
				if (gm !is null)
					@m_bossBar = gm.AddBossBarActor(this, m_bossBarWidth, -m_unitHeight);
			}
		}
	}

	void Update(int dt) override
	{
		if (m_bossBar !is null)
		{
			if (m_bossBarTimeC > 0)
				m_bossBarTimeC -= dt;

			if (IsDead() || m_bossBarTimeC <= 0)
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

		CompositeActorBehavior::Update(dt);
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
