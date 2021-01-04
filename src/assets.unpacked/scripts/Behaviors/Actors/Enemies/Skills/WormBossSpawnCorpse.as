class WormBossSpawnCorpse : ICompositeActorSkill
{
	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;
	int m_id;


	UnitProducer@ m_corpse;

	AnimString@ m_underground;
	AnimString@ m_overground;
	
	
	WormBossSpawnCorpse(UnitPtr unit, SValue& params)
	{
		@m_corpse = Resources::GetUnitProducer(GetParamString(unit, params, "corpse", true));

		@m_underground = AnimString(GetParamString(unit, params, "anim-underground", true));
		@m_overground = AnimString(GetParamString(unit, params, "anim-overground", true));

		if (IsNetsyncedExistance(m_corpse.GetNetSyncMode()))
			PrintError("Only use WormBossSpawnCorpse with non-netsynced units");
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
		m_id = id;
	}
	
	void OnDeath()
	{
		UnitHandler::NetSendUnitUseSkill(m_unit, m_id, 0);
		NetUseSkill(0, null);
	}

	void NetUseSkill(int stage, SValue@ param)
	{
		AnimString@ anim = null;

		if (g_flags.Get("bossworm_underground") != FlagState::Off)
			@anim = m_underground;
		else
			@anim = m_overground;

		auto unit = m_corpse.Produce(g_scene, m_unit.GetPosition());
		unit.SetUnitScene(anim.GetSceneName(m_behavior.m_movement.m_dir), true);
	}

	bool IsCasting()
	{
		return false;
	}

	void Update(int dt, bool isCasting) { }

	void Save(SValueBuilder& builder) { }
	void Load(SValue@ sval) { }
	void OnDamaged() { }
	void OnCollide(UnitPtr unit, vec2 normal) { }
	void OnSpawn() { }

	void Destroyed() { }
	void CancelSkill() { }
}
