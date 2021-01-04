namespace Modifiers
{
	class SpellCost : Modifier
	{
		float m_manaMul;
	
		SpellCost(UnitPtr unit, SValue& params)
		{
			m_manaMul = GetParamFloat(unit, params, "mana-mul", false, 1);
		}
		
		float SpellCostMul(PlayerBase@ player) override { return m_manaMul; }
	}
}