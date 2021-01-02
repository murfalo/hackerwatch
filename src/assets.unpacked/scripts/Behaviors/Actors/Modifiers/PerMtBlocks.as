namespace Modifiers
{
	class PerMtBlocks : Modifier
	{
		float m_armorPerMtBlocks;
		float m_resistancePerMtBlocks;

		int m_attackPowerPerMtBlocks;
		int m_skillPowerPerMtBlocks;

		PerMtBlocks(UnitPtr unit, SValue& params)
		{
			m_armorPerMtBlocks = GetParamFloat(unit, params, "armor-per-mt-blocks", false);
			m_resistancePerMtBlocks = GetParamFloat(unit, params, "resistance-per-mt-blocks", false);

			m_attackPowerPerMtBlocks = GetParamInt(unit, params, "attack-power-per-mt-blocks", false);
			m_skillPowerPerMtBlocks = GetParamInt(unit, params, "skill-power-per-mt-blocks", false);
		}

		bool HasArmorAdd() override { return true; }
		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override
		{
			int numBlocks = player.m_record.mtBlocks;
			return vec2(
				m_armorPerMtBlocks * numBlocks,
				m_resistancePerMtBlocks * numBlocks
			);
		}

		bool HasDamagePower() override { return true; }
		ivec2 DamagePower(PlayerBase@ player, Actor@ enemy) override
		{
			int numBlocks = player.m_record.mtBlocks;
			return ivec2(
				m_attackPowerPerMtBlocks * numBlocks,
				m_skillPowerPerMtBlocks * numBlocks
			);
		}
	}
}
