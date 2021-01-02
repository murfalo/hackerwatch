namespace Modifiers
{
	class Evade : Modifier
	{
		float m_chance;
	
		Evade(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", true);
		}	

		bool HasEvasion() override { return true; }
		float EvadeChance() override { return m_chance; }
		bool Evasion(PlayerBase@ player, Actor@ enemy) override { return roll_chance(player, m_chance); }
	}
}