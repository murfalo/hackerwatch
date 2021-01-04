namespace Modifiers
{
	class Tax : Modifier
	{
		int m_midpoint;
		float m_midpointMul;

		Tax(UnitPtr unit, SValue& params)
		{
			m_midpoint = GetParamInt(unit, params, "midpoint", false, 0);
			m_midpointMul = GetParamFloat(unit, params, "midpoint-mul", false, 1.0f);
		}

		int TaxMidpoint() override { return m_midpoint; }
		float TaxMidpointMul() override { return m_midpointMul; }
	}
}
