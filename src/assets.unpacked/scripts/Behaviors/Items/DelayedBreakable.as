class DelayedBreakable : ADamageTaker
{
	UnitPtr m_unit;

	SoundEvent@ m_breakSound;

	int m_delay;
	int m_delayC;
	string m_delayScene;
	CustomUnitScene@ m_delaySceneC;

	array<IEffect@>@ m_effects;
	GoreSpawner@ m_gore;
	UnitProducer@ m_corpse;

	float m_dmgColor = 0.0;
	bool m_showDmgColor;

	DelayedBreakable(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		@m_breakSound = Resources::GetSoundEvent(GetParamString(unit, params, "break-sound", false));

		@m_gore = LoadGore(GetParamString(unit, params, "gore", false));

		m_delay = GetParamInt(unit, params, "delay");
		int delayRandomMax = GetParamInt(unit, params, "delay-random", false);
		if (delayRandomMax > 0)
			m_delay += randi(delayRandomMax);
		m_delayScene = GetParamString(unit, params, "delay-scene", false);
		@m_delaySceneC = CustomUnitScene();

		@m_corpse = Resources::GetUnitProducer(GetParamString(unit, params, "corpse", false));
		@m_effects = LoadEffects(unit, params);

		m_unit.SetUpdateDistanceLimit(300);
	}

	void DamageEffects()
	{
		if (!m_unit.IsValid() || m_unit.IsDestroyed() || m_unit.GetPhysicsBody() is null)
			return;

		PlaySound3D(m_breakSound, m_unit.GetPosition());

		if (m_gore !is null)
			m_gore.OnDeath(1, xy(m_unit.GetPosition()));

		bool netsynced = IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode());
		if (!netsynced || Network::IsServer())
			m_unit.Destroy();

		ApplyEffects(m_effects, null, m_unit, xy(m_unit.GetPosition()), vec2(), 1.0, !Network::IsServer());

		bool netsyncedCorpse = m_corpse !is null && IsNetsyncedExistance(m_corpse.GetNetSyncMode());
		if (Network::IsServer())
		{
			if (m_corpse !is null)
				m_corpse.Produce(g_scene, m_unit.GetPosition());
		}
		else if (!netsyncedCorpse && m_corpse !is null)
			m_corpse.Produce(g_scene, m_unit.GetPosition());

		@m_corpse = null;
	}

	void SetDelayed()
	{
		if (m_showDmgColor)
			m_dmgColor = 1.0;

		if (m_delayC > 0)
			return;

		m_delayC = m_delay;

		m_delaySceneC.AddScene(m_unit.GetCurrentUnitScene(), 0, vec2(), 0, 0);
		m_delaySceneC.AddScene(m_unit.GetUnitScene(m_delayScene), 0, vec2(), 0, 0);
		m_unit.SetUnitScene(m_delaySceneC, true);
	}

	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		m_unit.SetUpdateDistanceLimit(0);

		SetDelayed();

		UnitHandler::NetSendUnitDamaged(m_unit, int(dmg.Damage), pos, dir, dmg.Attacker);

		return dmg.Damage;
	}

	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		if (m_showDmgColor)
			m_dmgColor = 1.0;

		SetDelayed();
	}

	bool IsDead() override
	{
		return !m_unit.IsValid();
	}

	void Update(int dt)
	{
		if (!m_unit.IsValid())
			return;

		if (m_delayC > 0 && Network::IsServer())
		{
			m_delayC -= dt;
			if (m_delayC <= 0)
			{
				(Network::Message("UnitDelayedBreakable") << m_unit).SendToAll();
				DamageEffects();
			}
		}

		if (m_unit.IsDestroyed())
			return;

		if (m_dmgColor > 0)
			m_dmgColor -= dt / 100.0;
	}

	vec4 GetOverlayColor()
	{
		return vec4(1, 1, 1, 0.5 * m_dmgColor);
	}

	bool Ricochets() override { return false; }
}
