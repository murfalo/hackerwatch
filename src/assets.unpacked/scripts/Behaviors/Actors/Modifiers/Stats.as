namespace Modifiers
{
	class Stats : Modifier
	{
		ivec2 m_stats;
	
		Stats(UnitPtr unit, SValue& params)
		{
			m_stats = ivec2(
				GetParamInt(unit, params, "health", false, 0),
				GetParamInt(unit, params, "mana", false, 0));
		}	

		ivec2 StatsAdd(PlayerBase@ player) override { return m_stats; }
	}
}