class FixedPathFollower
{
	UnitPtr m_unit;

	AnimString@ m_animIdle;
	AnimString@ m_animWalk;

	WorldScript::PathNode@ m_targetPrev;
	WorldScript::PathNode@ m_target;
	bool m_finished;
	float m_dir;

	bool m_canVisitPreviousNode;

	float m_speedOrig;
	float m_speed;

	int m_nodeDistance;

	int m_nodeDelay;
	int m_nodeDelayC;

	bool m_paused;

	FixedPathFollower(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		@m_animIdle = AnimString(GetParamString(unit, params, "anim-idle", false));
		@m_animWalk = AnimString(GetParamString(unit, params, "anim-walk", false));

		m_canVisitPreviousNode = GetParamBool(unit, params, "can-visit-previous-node", false, true);

		m_speedOrig = m_speed = GetParamFloat(unit, params, "speed", false, 3.0f);

		m_nodeDistance = GetParamInt(unit, params, "node-distance", false, 20);
		m_nodeDistance *= m_nodeDistance;
		m_nodeDelay = GetParamInt(unit, params, "node-delay", false);
	}

	WorldScript::PathNode@ FindFirstNode()
	{
		WorldScript::PathNode@ closestNode = null;
		float closestDistance = 0.0f;
		for (uint i = 0; i < WorldScript::g_pathNodes.length(); i++)
		{
			auto node = WorldScript::g_pathNodes[i];
			if (!node.Enabled)
				continue;
			float distance = distsq(node.Position, m_unit.GetPosition());
			if (closestNode is null || distance < closestDistance)
			{
				@closestNode = node;
				closestDistance = distance;
			}
		}
		return closestNode;
	}

	WorldScript::PathNode@ FindNextNode()
	{
		if (m_target is null)
			return null;

		auto arr = m_target.NextNode.FetchAll();
		if (!m_canVisitPreviousNode)
		{
			for (int i = arr.length() - 1; i >= 0; i--)
			{
				auto node = cast<WorldScript::PathNode>(arr[i].GetScriptBehavior());

				if (node is m_targetPrev || !node.Enabled)
					arr.removeAt(i);
			}
		}

		if (arr.length() >= 1)
		{
			UnitPtr unitTarget = arr[randi(arr.length())];
			return cast<WorldScript::PathNode>(unitTarget.GetScriptBehavior());
		}

		return null;
	}

	void SetFinished()
	{
		m_finished = true;

		auto body = m_unit.GetPhysicsBody();
		body.SetLinearVelocity(vec2());
		body.SetStatic(true);

		m_unit.SetUnitScene(m_animIdle.GetSceneName(m_dir), true);
	}

	void SetPaused(bool pause)
	{
		if (m_paused == pause)
			return;

		m_paused = pause;
		if (m_paused)
		{
			m_unit.SetUnitScene(m_animIdle.GetSceneName(m_dir), true);

			auto body = m_unit.GetPhysicsBody();
			body.SetLinearVelocity(vec2());
			body.SetStatic(true);
		}
	}

	void Update(int dt)
	{
		if (m_finished || m_paused)
			return;

		if (m_target is null)
		{
			@m_target = FindFirstNode();
			if (m_target is null)
			{
				SetFinished();
				return;
			}
		}
		else if (distsq(m_unit.GetPosition(), m_target.Position) < m_nodeDistance)
		{
			if (Network::IsServer())
			{
				auto ws = WorldScript::GetWorldScript(g_scene, m_target);
				if (ws !is null)
					ws.Execute();
			}

			auto prevTarget = m_target;
			@m_target = FindNextNode();
			@m_targetPrev = prevTarget;
			m_nodeDelayC = m_nodeDelay;

			if (m_target is null)
			{
				SetFinished();
				return;
			}
		}

		auto body = m_unit.GetPhysicsBody();

		if (m_nodeDelayC > 0)
		{
			m_nodeDelayC -= dt;
			body.SetLinearVelocity(vec2());
			body.SetStatic(true);
			return;
		}

		vec2 dir = normalize(xy(m_target.Position) - xy(m_unit.GetPosition()));

		body.SetStatic(false);
		body.SetLinearVelocity(dir * m_speed);

		m_dir = atan(dir.y, dir.x);
		m_unit.SetUnitScene(m_animWalk.GetSceneName(m_dir), false);
	}
}
