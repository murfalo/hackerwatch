class PlayerOwnedSummon : PlayerOwnedActor, IPreRenderable
{
	float m_powerScale;

	float m_blockProjectileChance;
	
	bool m_shootThrough;
	bool m_usePlayerColors;

	array<Materials::IDyeState@> m_dyeStates;

	PlayerOwnedSummon(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_powerScale = 1.0f;

		m_blockProjectileChance = GetParamFloat(unit, params, "block-projectile-chance", false);
		m_usePlayerColors = GetParamBool(unit, params, "use-player-colors", false, false);
		m_shootThrough = GetParamBool(unit, params, "shoot-through", false, false);
	}

	void SetShades(int c, const array<vec4> &in shades)
	{
		m_unit.SetMultiColor(c, shades[0], shades[1], shades[2]);
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0) override
	{
		PlayerOwnedActor::Initialize(owner, intensity, husk, weaponInfo);		
		
		if (m_ownerPlayer !is null)
		{
			m_powerScale = (50.0f + m_ownerRecord.GetModifiers().DamagePower(m_ownerPlayer, null).y) / 50.0f;
			
			if (m_bossBar !is null)
				@m_bossBar.m_playerOwner = m_ownerRecord;
			
			if (m_usePlayerColors)
			{
				m_dyeStates = Materials::MakeDyeStates(m_ownerRecord);

				for (uint i = 0; i < m_dyeStates.length(); i++)
					SetShades(i, m_dyeStates[i].GetShades(0));

				m_preRenderables.insertLast(this);
			}
		}
	}

	bool BlockProjectile(IProjectile@ proj) override
	{
		return (randf() <= m_blockProjectileChance);
	}
	
	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override
	{
		return m_shootThrough;
	}

	int GetMaxHp() override
	{
		return max(1, int(m_maxHp * (1.0f + g_mpEnemyHealthScale * m_mpScaleFact) * m_powerScale));
	}

	vec2 GetArmor() override
	{
		return m_buffs.ArmorMul() * m_armor;
	}

	void Update(int dt) override
	{
		PlayerOwnedActor::Update(dt);

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_dyeStates[i].Update(dt);
	}

	bool PreRender(int idt)
	{
		if (m_unit.IsDestroyed())
			return true;

		for (uint i = 0; i < m_dyeStates.length(); i++)
			SetShades(i, m_dyeStates[i].GetShades(0));
		return false;
	}
}
