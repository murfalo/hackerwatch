namespace Skills
{
	class Stormlash : Skill
	{
		float m_chance;
		float m_intensity;

		Stormlash(UnitPtr unit, SValue& params)
		{
			super(unit);
			m_chance = GetParamFloat(unit, params, "chance", true, 1.0f);
			m_intensity = GetParamFloat(unit, params, "intensity", true, 0.5f);
		}
	}
}