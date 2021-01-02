namespace Modifiers
{
	class Lifestealing : Modifier
	{
		float m_lifesteal;
		float m_spellLifesteal;
		bool m_onlyCrit;
	
	
		Lifestealing(UnitPtr unit, SValue& params)
		{
			m_lifesteal = GetParamFloat(unit, params, "lifesteal", false, 0);
			m_spellLifesteal = GetParamFloat(unit, params, "spell-lifesteal", false, 0);
			m_onlyCrit = GetParamBool(unit, params, "only-crit", false);
		}

		bool HasLifesteal() override { return true; }
		float Lifesteal(PlayerBase@ player, Actor@ enemy, bool spell, int crit) override 
		{ 
			if (spell)
				return (!m_onlyCrit || crit > 0) ? m_spellLifesteal : 0; 
			
			return (!m_onlyCrit || crit > 0) ? m_lifesteal : 0; 
		}
	}
}
