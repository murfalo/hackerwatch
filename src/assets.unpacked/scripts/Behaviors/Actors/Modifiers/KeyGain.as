namespace Modifiers
{
	class KeyGain : Modifier
	{
		float m_scale;
		float m_chance;

		KeyGain(UnitPtr unit, SValue& params)
		{
			m_scale = GetParamFloat(unit, params, "scale", false, 1);
			m_chance = GetParamFloat(unit, params, "chance", false, 1);
		}

		bool HasKeyGainScale() override { return true; }
		float KeyGainScale(PlayerBase@ player) override
		{
			if (roll_chance(player, m_chance, m_scale < 1.0f))
				return m_scale;
			return 1;
		}
	}
}
