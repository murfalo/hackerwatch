namespace Modifiers
{
	class GoldGain : Modifier
	{
		float m_scale;
		float m_scaleAdd;

		GoldGain(UnitPtr unit, SValue& params)
		{
			m_scale = GetParamFloat(unit, params, "scale", false, 1);
			m_scaleAdd = GetParamFloat(unit, params, "scale-add", false, 0.0f);
		}

		float GoldGainScale(PlayerBase@ player) override { return m_scale; }
		float GoldGainScaleAdd(PlayerBase@ player) override { return m_scaleAdd; }
	}
}
