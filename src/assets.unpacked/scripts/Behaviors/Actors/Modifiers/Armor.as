namespace Modifiers
{
	class Armor : Modifier
	{
		vec2 m_armor;
		vec2 m_armorMul;
		float m_dmgTakenMul;
	
		Armor(UnitPtr unit, SValue& params)
		{
			auto svArmor = params.GetDictionaryEntry("armor");
			if (svArmor !is null)
			{
				if (svArmor.GetType() == SValueType::Float)
					m_armor.x = svArmor.GetFloat();
				else if (svArmor.GetType() == SValueType::Integer)
					m_armor.x = float(svArmor.GetInteger());
			}

			auto svResistance = params.GetDictionaryEntry("resistance");
			if (svResistance !is null)
			{
				if (svResistance.GetType() == SValueType::Float)
					m_armor.y = svResistance.GetFloat();
				else if (svResistance.GetType() == SValueType::Integer)
					m_armor.y = float(svResistance.GetInteger());
			}

			float armorMul = GetParamFloat(unit, params, "armor-mul", false, 1.0f);
			float resistanceMul = GetParamFloat(unit, params, "resistance-mul", false, 1.0f);
			m_armorMul = vec2(armorMul, resistanceMul);
			
			m_dmgTakenMul = GetParamFloat(unit, params, "dmg-taken-mul", false, 1);
		}	

		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override { return m_armor; }
		vec2 ArmorMul(PlayerBase@ player, Actor@ enemy) override { return m_armorMul; }
		float DamageTakenMul(PlayerBase@ player, DamageInfo &di) override { return m_dmgTakenMul; }
	}
}