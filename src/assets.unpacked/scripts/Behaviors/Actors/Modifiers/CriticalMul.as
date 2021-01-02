namespace Modifiers
{
	class CriticalMul : Modifier
	{
		float m_mul;
		float m_spellMul;

		float m_mulAdd;
		float m_spellMulAdd;

		CriticalMul(UnitPtr unit, SValue& params)
		{
			m_mul = GetParamFloat(unit, params, "mul", false, 1.0f);
			m_spellMul = GetParamFloat(unit, params, "spell-mul", false, 1.0f);

			m_mulAdd = GetParamFloat(unit, params, "mul-add", false);
			m_spellMulAdd = GetParamFloat(unit, params, "spell-mul-add", false);
		}

		bool HasCritMul() override { return true; }
		float CritMul(PlayerBase@ player, Actor@ enemy, bool spell) override 
		{
			if (spell)
				return m_spellMul;
			return m_mul;
		}

		bool HasCritMulAdd() override { return true; }
		float CritMulAdd(PlayerBase@ player, Actor@ enemy, bool spell) override
		{
			if (spell)
				return m_spellMulAdd;
			return m_mulAdd;
		}
	}
}
