namespace Modifiers
{
	class CriticalHit : Modifier
	{
		float m_chance;
		float m_spellChance;
	
		CriticalHit(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", false, 0);
			m_spellChance = GetParamFloat(unit, params, "spell-chance", false, 0);
		}
		
		float CritChance(bool spell) override { return spell ? m_spellChance : m_chance; }
		
		bool HasCrit() override { return true; }
		int Crit(PlayerBase@ player, Actor@ enemy, bool spell) override 
		{
			if (spell)
				return roll_chance(player, m_spellChance) ? 1 : 0;
				
			return roll_chance(player, m_chance) ? 1 : 0;
		}
	}
}