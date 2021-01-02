namespace Modifiers
{
	class RetiredArmor : StackedModifier
	{
		vec2 m_armor;

		RetiredArmor()
		{
		}

		RetiredArmor(UnitPtr unit, SValue& params)
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
		}

		Modifier@ Instance() override
		{
			auto ret = RetiredArmor();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasArmorAdd() override { return true; }
		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override { return m_armor * m_stackCount; }
	}
}
