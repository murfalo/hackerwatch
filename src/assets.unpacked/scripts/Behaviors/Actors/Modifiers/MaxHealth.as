namespace Modifiers
{
	class MaxHealth : Modifier
	{
		float m_mul;

		MaxHealth(UnitPtr unit, SValue& params)
		{
			m_mul = GetParamFloat(unit, params, "mul");
		}

		float MaxHealthMul(PlayerBase@ player) override { return m_mul; }
	}
}
