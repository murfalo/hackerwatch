namespace Modifiers
{
	class ArmorPierce : Modifier
	{
		vec2 m_attack;
		vec2 m_spell;

		ArmorPierce(UnitPtr unit, SValue& params)
		{
			vec2 base = vec2(
				GetParamFloat(unit, params, "armor", false, 1),
				GetParamFloat(unit, params, "resistance", false, 1));
				
			m_attack = base * vec2(
				GetParamFloat(unit, params, "attack-armor", false, 1),
				GetParamFloat(unit, params, "attack-resistance", false, 1));

			m_spell = base * vec2(
				GetParamFloat(unit, params, "spell-armor", false, 1),
				GetParamFloat(unit, params, "spell-resistance", false, 1));				
				
		}	

		bool HasArmorIgnore() override { return true; }
		vec2 ArmorIgnore(PlayerBase@ player, Actor@ enemy, bool spell) override 
		{ 
			if (spell)
				return m_spell;

			return m_attack; 
		}
	}
}