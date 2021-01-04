namespace Modifiers
{
	class BuffScaling : Modifier
	{
		float m_buffScale;
		float m_debuffScale;
		float m_slowScale;
		
		BuffScaling(UnitPtr unit, SValue& params)
		{
			m_buffScale = GetParamFloat(unit, params, "buff-scale", false, 1.0);
			m_debuffScale = GetParamFloat(unit, params, "debuff-scale", false, 1.0);
			m_slowScale = GetParamFloat(unit, params, "slow-scale", false, 1.0);
		}
		
		float SlowScale(PlayerBase@ player) override { return m_slowScale; }
		float BuffScale(PlayerBase@ player) override { return m_buffScale; }
		float DebuffScale(PlayerBase@ player) override { return m_debuffScale; }
	}
}