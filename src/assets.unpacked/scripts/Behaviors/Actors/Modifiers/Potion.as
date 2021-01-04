namespace Modifiers
{
	class Potion : Modifier
	{
		int m_charges;
		float m_healing;
		float m_mana;
	
		Potion(UnitPtr unit, SValue& params)
		{
			m_charges = GetParamInt(unit, params, "charges", false, 0);
			m_healing = GetParamFloat(unit, params, "healing", false, 1);
			m_mana = GetParamFloat(unit, params, "mana", false, 1);
		}
		
		int PotionCharges() override { return m_charges; }
		float PotionHealMul(PlayerBase@ player) override { return m_healing; }
		float PotionManaMul(PlayerBase@ player) override { return m_mana; }
	}
}