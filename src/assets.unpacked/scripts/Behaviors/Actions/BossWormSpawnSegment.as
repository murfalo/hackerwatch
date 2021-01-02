class BossWormSpawnSegment : SpawnUnit
{
	UnitProducer@ m_mainSegment;
	array<UnitProducer@> m_digDown;

	int m_lastSwitchingC;
	int m_currentIndex;

	BossWormSpawnSegment(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_mainSegment = UnitType;

		auto arrUnits = GetParamArray(unit, params, "dig-down");
		for (uint i = 0; i < arrUnits.length(); i++)
		{
			m_digDown.insertLast(Resources::GetUnitProducer(arrUnits[i].GetString()));
		}
	}

	UnitPtr DoSpawnUnit(vec2 pos, vec2 dir, Actor@ owner, float intensity) override
	{
		auto enemy = cast<CompositeActorBehavior>(owner);
		auto movement = cast<BossWormMovement>(enemy.m_movement);
		if (movement.m_switchingC > 0)
		{
			if (movement.m_switchingC > m_lastSwitchingC)
				m_currentIndex = 0;
			m_lastSwitchingC = movement.m_switchingC;

			int index = m_currentIndex++;
			//int index = int(m_digDown.length() * (movement.m_switchingC / float(movement.m_switching)));
			if (index >= int(m_digDown.length()))
				index = m_digDown.length() - 1;

			if (movement.m_underground)
				index = int(m_digDown.length() - 1) - index;

			@UnitType = m_digDown[index];
		}
		else
			@UnitType = m_mainSegment;

		return SpawnUnit(pos, owner, intensity);
	}
}
