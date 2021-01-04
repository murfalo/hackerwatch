namespace Modifiers
{
	class Speed : Modifier
	{
		float m_movement;
		float m_movementMul;
		float m_skillMul;
		float m_attackMul;

		Speed(UnitPtr unit, SValue& params)
		{
			m_movement = GetParamFloat(unit, params, "movement", false, 0);
			m_movementMul = GetParamFloat(unit, params, "movement-mul", false, 1);
			m_skillMul = GetParamFloat(unit, params, "skill-mul", false, 1);
			m_attackMul = GetParamFloat(unit, params, "attack-mul", false, 1);
		}

		bool HasMoveSpeedAdd() override { return true; }
		bool HasMoveSpeedMul() override { return true; }

		float MoveSpeedAdd(PlayerBase@ player, float slowScale) override { return ((m_movement < 0) ? slowScale * m_movement : m_movement); }
		float MoveSpeedMul(PlayerBase@ player, float slowScale) override 
		{
			if (m_movementMul < 1.0f)
				return lerp(1.0f, m_movementMul, slowScale);
			return m_movementMul;
		}

		float SkillTimeMul(PlayerBase@ player) override { return m_skillMul; }
		float AttackTimeMul(PlayerBase@ player) override { return m_attackMul; }
	}
}
