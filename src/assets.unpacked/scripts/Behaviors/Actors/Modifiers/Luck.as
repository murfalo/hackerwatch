namespace Modifiers
{
	class Luck : Modifier
	{
		float m_luck;
	
		Luck(UnitPtr unit, SValue& params)
		{
			m_luck = GetParamFloat(unit, params, "add", false, 0);
		}	

		float LuckAdd(PlayerBase@ player) override { return m_luck; }
	}
}