namespace Modifiers
{
	class StatsBase : Modifier
	{
		vec2 m_stats;
	
		StatsBase(UnitPtr unit, SValue& params)
		{
			m_stats = vec2(
				GetParamFloat(unit, params, "health", false, 0),
				GetParamFloat(unit, params, "mana", false, 0));
		}	

		bool HasStatsAdd() override { return true; }
		ivec2 StatsAdd(PlayerBase@ player) override 
		{ 
			return ivec2(
				int(player.m_record.MaxHealth() * m_stats.x),
				int(player.m_record.MaxMana() * m_stats.y));
		}
	}
}