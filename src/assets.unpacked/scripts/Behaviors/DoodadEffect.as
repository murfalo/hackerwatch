class DoodadEffect
{
	UnitPtr m_unit;

	EffectParams@ m_effectParams;

	DoodadEffect(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		@m_effectParams = LoadEffectParams(unit, params);
	}
}
