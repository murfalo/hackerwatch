class GargoyleSpawner : Actor, IOwnedUnit
{
	Actor@ m_owner;
	float m_intensity;
	bool m_husk;

	int m_delayC;

	UnitProducer@ m_prodBolt;
	UnitProducer@ m_prodArea;

	float m_rangeMul;

	Skills::DropUnitWarlock@ m_dropSkill;

	uint m_weaponInfo;

	GargoyleSpawner(UnitPtr unit, SValue& params)
	{
		super(unit);

		m_unit = unit;

		m_delayC = GetParamInt(unit, params, "delay");

		@m_prodBolt = Resources::GetUnitProducer(GetParamString(unit, params, "unit-bolt"));
		@m_prodArea = Resources::GetUnitProducer(GetParamString(unit, params, "unit-area"));
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0)
	{
		@m_owner = owner;
		m_intensity = intensity;
		m_husk = husk;

		m_weaponInfo = weaponInfo;
	}

	void UnitSpawned(UnitPtr unit)
	{
		auto ownedUnit = cast<IOwnedUnit>(unit.GetScriptBehavior());
		if (ownedUnit !is null)
			ownedUnit.Initialize(m_owner, m_intensity, m_husk, m_weaponInfo);

		auto boltShooter = cast<BoltShooter>(ownedUnit);
		if (boltShooter !is null)
		{
			boltShooter.m_range = int(boltShooter.m_range * m_rangeMul);
			m_dropSkill.m_units.insertLast(unit);
		}
	}

	void Update(int dt)
	{

		if (m_delayC > 0)
		{
			m_delayC -= dt;
			if (m_delayC <= 0)
			{
				if (m_prodBolt !is null)
					UnitSpawned(m_prodBolt.Produce(g_scene, m_unit.GetPosition()));

				if (Network::IsServer() && m_prodArea !is null)
					UnitSpawned(m_prodArea.Produce(g_scene, m_unit.GetPosition()));

				m_unit.Destroy();
			}
		}
	}
}
