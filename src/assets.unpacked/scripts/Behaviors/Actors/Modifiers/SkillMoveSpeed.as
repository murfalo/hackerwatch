namespace Modifiers
{
	class SkillMoveSpeed : Modifier
	{
		float m_mul;
		bool m_clear;
		int m_direction;

		SkillMoveSpeed(UnitPtr unit, SValue& params)
		{
			m_mul = GetParamFloat(unit, params, "mul", false, 1.0f);
			m_clear = GetParamBool(unit, params, "clear", false, false);
			m_direction = GetParamInt(unit, params, "direction", false, -1);
		}

		bool HasSkillMoveSpeedMul() override { return m_mul != 1.0f; }
		float SkillMoveSpeedMul(PlayerBase@ player, float speedMod) override
		{
			if (m_direction == -1)
			{
				if (speedMod < 1.0f)
					return m_mul;
				else
					return 1.0f;
			}
			else if (m_direction == 1)
			{
				if (speedMod > 1.0f)
					return m_mul;
				else
					return 1.0f;
			}
			return m_mul;
		}

		bool HasSkillMoveSpeedClear() override { return m_clear; }
		bool SkillMoveSpeedClear(PlayerBase@ player, float speedMod) override
		{
			if (!m_clear)
				return false;

			return (m_direction == -1 && speedMod < 1.0f) || (m_direction == 1 && speedMod > 1.0f) || m_direction == 0;
		}
	}
}
