namespace Modifiers
{
	class Experience : Modifier
	{
		float m_expMul;
		float m_expMulAdd;

		Experience(UnitPtr unit, SValue& params)
		{
			m_expMul = GetParamFloat(unit, params, "mul", false, 1.0f);
			m_expMulAdd = GetParamFloat(unit, params, "mul-add", false, 0.0f);
		}

		float ExpMul(PlayerBase@ player, Actor@ enemy) override { return m_expMul; }
		float ExpMulAdd(PlayerBase@ player, Actor@ enemy) override { return m_expMulAdd; }
	}
}
