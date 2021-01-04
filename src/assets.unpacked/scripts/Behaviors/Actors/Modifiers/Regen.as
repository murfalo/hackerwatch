namespace Modifiers
{
	class Regen : Modifier
	{
		vec2 m_add;
		vec2 m_mul;
	
		Regen(UnitPtr unit, SValue& params)
		{
			m_add = vec2(
				GetParamFloat(unit, params, "health", false, 0),
				GetParamFloat(unit, params, "mana", false, 0)
			);
			
			m_mul = vec2(
				GetParamFloat(unit, params, "health-mul", false, 1),
				GetParamFloat(unit, params, "mana-mul", false, 1)
			);
		}

		vec2 RegenAdd(PlayerBase@ player) override { return m_add; }
		vec2 RegenMul(PlayerBase@ player) override { return m_mul; }
	}
}