class BossWormSpewChunk
{
	UnitPtr m_unit;
	UnitScene@ m_fx;

	float m_currSpeed;
	float m_currHeight;
	float m_speedDelta;

	Actor@ m_owner;
	array<IEffect@>@ m_effects;



	BossWormSpewChunk(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		@m_fx = Resources::GetEffect(GetParamString(unit, params, "fx", false, ""));
		m_speedDelta = GetParamFloat(unit, params, "speed-delta", false, 0.05);

		m_currHeight = 500;
		m_unit.SetPositionZ(m_currHeight);
		m_currSpeed = 0.05;
	}

	void Initialize(Actor@ owner, array<IEffect@>@ effects)
	{
		@m_owner = owner;
		@m_effects = effects;
	}

	void Update(int dt)
	{
		if (m_unit.IsDestroyed())
			return;

		m_currHeight -= dt * m_currSpeed;
		m_unit.SetPositionZ(max(0.0, m_currHeight), true);
		m_currSpeed = min(0.6, m_currSpeed + m_speedDelta * dt / 33.0);

		if (m_currHeight <= 0)
		{
			m_unit.Destroy();

			vec2 pos = xy(m_unit.GetPosition());

			PlayEffect(m_fx, pos);

			ApplyEffects(m_effects, m_owner, UnitPtr(), pos, vec2(), 1.0f, !Network::IsServer());
			//SValue@ param = ApplyEffects(m_actions, m_owner, null, pos, vec2(), 1.0);

			return;
		}
	}
}
