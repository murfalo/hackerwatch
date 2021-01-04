class TransitionDef
{
	string m_from;
	string m_to;
}

class StateAnimations
{
	UnitPtr m_unit;

	array<TransitionDef@> m_transitions;

	string m_currScene;
	int m_currSceneTime;

	StateAnimations(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		auto arr = GetParamArray(unit, params, "transitions", false);
		if (arr !is null)
		{
			for (uint i = 0; i < arr.length(); i++)
			{
				auto newDef = TransitionDef();
				newDef.m_from = GetParamString(unit, arr[i], "from");
				newDef.m_to = GetParamString(unit, arr[i], "to");
				m_transitions.insertLast(newDef);
			}
		}

		m_currScene = m_unit.GetCurrentUnitScene().GetName();
		m_currSceneTime = m_unit.GetCurrentUnitScene().Length();
	}

	string NextScene()
	{
		for (uint i = 0; i < m_transitions.length(); i++)
		{
			if (m_transitions[i].m_from == m_currScene)
				return m_transitions[i].m_to;
		}
		return "";
	}

	void Update(int dt)
	{
		auto currentScene = m_unit.GetCurrentUnitScene();
		string currentSceneName = currentScene.GetName();

		if (m_currScene != currentSceneName)
		{
			m_currScene = currentSceneName;
			m_currSceneTime = currentScene.Length();
		}

		m_currSceneTime -= dt;
		if (m_currSceneTime <= 0)
		{
			string next = NextScene();
			if (next == "")
			{
				m_currSceneTime = currentScene.Length();
				return;
			}
			m_currScene = next;
			m_unit.SetUnitScene(m_currScene, true);
			m_currSceneTime = m_unit.GetCurrentUnitScene().Length();
		}
	}
}
