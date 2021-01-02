namespace Modifiers
{
	class HealthGain : Modifier
	{
		float m_scale;
		float m_scaleAll;

		HealthGain(UnitPtr unit, SValue& params)
		{
			m_scale = GetParamFloat(unit, params, "scale", false, 1);
			m_scaleAll = GetParamFloat(unit, params, "scale-all", false, 1);
		}
		
		float HealthGainScale(PlayerBase@ player) override { return m_scale; }
		float AllHealthGainScale(PlayerBase@ player) override { return m_scaleAll; }
	}
}
