class Bush
{
	UnitPtr m_unit;
	UnitScene@ m_scene;
		
	Bush(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		@m_scene = m_unit.GetCurrentUnitScene();
	}
		
	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		Actor@ a = cast<Actor>(unit.GetScriptBehavior());
		if (a !is null)
			m_unit.SetUnitScene(m_scene, true);
	}
}