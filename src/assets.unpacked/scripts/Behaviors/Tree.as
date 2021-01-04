class Tree
{
	UnitPtr m_unit;
	
	UnitScene@ m_stillScene;
	UnitScene@ m_animScene;
	
	int m_timeToSceneBack;
	int m_timeToAnim;
	
	int m_timeOffset;
	
	Tree(UnitPtr unit, SValue& params)
	{
		string animSuffix = GetParamString(unit, params, "anim-suffix");
		
		m_unit = unit;
		@m_stillScene = m_unit.GetCurrentUnitScene();
		@m_animScene = m_unit.GetUnitScene(m_stillScene.GetName() + animSuffix);
		
		m_timeToSceneBack = -1;
		m_timeToAnim = 2500 + randi(10000);
		
		m_timeOffset = randi(33) - int(m_unit.GetPosition().x * 1.5);
		
		m_unit.SetUpdateDistanceLimit(300);
	}
	
	void PlayAnim()
	{
		if (m_unit.GetCurrentUnitScene() !is m_animScene)
			m_unit.SetUnitScene(m_animScene, true);
		
		m_timeToSceneBack = m_animScene.Length();
		m_timeToAnim = -1;
	}
	
	void Update(int dt)
	{	
		uint t = (g_scene.GetTime() + m_timeOffset) % 10000;
		if (t + dt > 10000)
			PlayAnim();
	
		if (m_timeToSceneBack > 0)
		{
			m_timeToSceneBack -= dt;
			if (m_timeToSceneBack <= 0)
			{
				m_unit.SetUnitScene(m_stillScene, true);
				m_timeToSceneBack = -1;
				m_timeToAnim = 2500 + randi(1000);
			}
		}

		if (m_timeToAnim > 0)
		{
			m_timeToAnim -= dt;
			if (m_timeToAnim <= 0)
				PlayAnim();
		}	
	}
	
}
