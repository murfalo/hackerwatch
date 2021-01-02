namespace Modifiers
{
	class OreGain : Modifier
	{
		float m_scale;
		float m_chance;

		OreGain(UnitPtr unit, SValue& params)
		{
			m_scale = GetParamFloat(unit, params, "scale", false, 1);
			m_chance = GetParamFloat(unit, params, "chance", false, 1);
		}

		bool HasOreGainScale() override { return true; }
		float OreGainScale(PlayerBase@ player) override
		{
			if (roll_chance(player, m_chance, m_scale < 1.0f))
				return m_scale;
			return 1;
		}
	}
}
