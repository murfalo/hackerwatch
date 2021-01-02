namespace Modifiers
{
	class PerOre : Modifier
	{
		float m_armorPerOre;
		float m_resistancePerOre;

		int m_attackPowerPerOre;
		int m_skillPowerPerOre;

		PerOre(UnitPtr unit, SValue& params)
		{
			m_armorPerOre = GetParamFloat(unit, params, "armor-per-ore", false);
			m_resistancePerOre = GetParamFloat(unit, params, "resistance-per-ore", false);

			m_attackPowerPerOre = GetParamInt(unit, params, "attack-power-per-ore", false);
			m_skillPowerPerOre = GetParamInt(unit, params, "skill-power-per-ore", false);
		}

		bool HasArmorAdd() override { return true; }
		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override
		{
			int numOre = player.m_record.runOre;
			return vec2(
				m_armorPerOre * numOre,
				m_resistancePerOre * numOre
			);
		}

		bool HasDamagePower() override { return true; }
		ivec2 DamagePower(PlayerBase@ player, Actor@ enemy) override
		{
			int numOre = player.m_record.runOre;
			return ivec2(
				m_attackPowerPerOre * numOre,
				m_skillPowerPerOre * numOre
			);
		}
	}
}
