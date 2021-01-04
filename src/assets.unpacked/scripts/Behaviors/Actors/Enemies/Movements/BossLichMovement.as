array<WorldScript::BossLichNode@> g_lichNodes;

class BossLichMovement : ActorMovement
{
	AnimString@ m_idleAnim;
	AnimString@ m_walkAnim;

	float m_speed;

	WorldScript::BossLichNode@ m_nodeTarget;
	WorldScript::BossLichNode@ m_nodeLastVisited;

	BossLichMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_idleAnim = AnimString(GetParamString(unit, params, "anim-idle"));
		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));

		m_speed = GetParamFloat(unit, params, "speed");
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		ActorMovement::Initialize(unit, behavior);

		m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
	}

	WorldScript::BossLichNode@ FindNewNode()
	{
		if (!Network::IsServer())
		{
			PrintError("Clients can't find new BossLichNode!");
			return null;
		}

		if (m_nodeTarget !is null)
			return m_nodeTarget.PickNextNode();
		return g_lichNodes[randi(g_lichNodes.length())];
	}

	void SetTargetNode(WorldScript::BossLichNode@ node)
	{
		@m_nodeTarget = node;

		if (Network::IsServer())
		{
			auto script = WorldScript::GetWorldScript(g_scene, node);
			(Network::Message("UnitMovementBossLichTarget") << m_unit << script.GetUnit()).SendToAll();
		}
	}

	void DoCasting(int dt)
	{
		if (m_behavior.m_target is null)
			return;

		vec3 posTarget = m_behavior.m_target.m_unit.GetPosition();
		vec3 posMe = m_unit.GetPosition();

		m_unit.GetPhysicsBody().SetStatic(true);
	}

	void DoWalkPaths(int dt)
	{
		m_unit.SetUnitScene(m_walkAnim.GetSceneName(m_dir), false);

		auto body = m_unit.GetPhysicsBody();
		if (body is null)
			return;

		body.SetStatic(false);

		if (Network::IsServer())
		{
			if (m_nodeTarget is null)
				SetTargetNode(FindNewNode());
			else
			{
				float distance = dist(m_unit.GetPosition(), m_nodeTarget.Position);
				if (distance < 5.0f)
				{
					auto ws = WorldScript::GetWorldScript(g_scene, m_nodeTarget);
					if (ws !is null)
						ws.Execute();

					SetTargetNode(FindNewNode());
				}
			}
		}

		if (m_nodeTarget !is null)
		{
			vec2 dir = xy(normalize(m_nodeTarget.Position - m_unit.GetPosition()));
			dir *= m_speed;
			body.SetLinearVelocity(dir);

			m_dir = atan(dir.y, dir.x);
		}
	}

	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
			return;
			
		ActorMovement::Update(dt, isCasting);

		if (isCasting)
			DoCasting(dt);
		else
			DoWalkPaths(dt);
	}
}
