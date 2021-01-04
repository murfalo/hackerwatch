namespace Skills
{
	class TwinnedArrow : Skill
	{
		float m_chance;
	
		TwinnedArrow(UnitPtr unit, SValue& params)
		{
			super(unit);
			m_chance = GetParamFloat(unit, params, "chance", false, 0.1);
		}
	}
}