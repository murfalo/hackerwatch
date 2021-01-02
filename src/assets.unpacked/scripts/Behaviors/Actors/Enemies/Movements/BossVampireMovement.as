WorldScript::VampireCenterNode@ g_vampireCenterNode;

class BossVampireMovement : ActorMovement
{
	BossVampire@ m_vampire;

	AnimString@ m_idleAnim;
	AnimString@ m_walkAnim;

	float m_speed;
	float m_speedRoam;

	WorldScript::BossLichNode@ m_nodeTarget;
	WorldScript::BossLichNode@ m_nodeLastVisited;

	int m_nodeWaitTime;
	int m_nodeWaitTimeRandom;
	int m_nodeWaitTimeC;

	int m_centerCount;
	int m_centerCountC;

	bool m_isTransformed;
	UnitScene@ m_effectTransform;

	BossVampireMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		@m_idleAnim = AnimString(GetParamString(unit, params, "anim-idle"));
		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));

		m_speed = GetParamFloat(unit, params, "speed");
		m_speedRoam = GetParamFloat(unit, params, "speed-roam", false, m_speed);

		m_nodeWaitTime = GetParamInt(unit, params, "node-wait-time", false, 2000);
		m_nodeWaitTimeRandom = GetParamInt(unit, params, "node-wait-time-random", false, 2000);
		//m_nodeWaitTimeC = m_nodeWaitTime + randi(m_nodeWaitTimeRandom);

		m_centerCount = GetParamInt(unit, params, "center-count", false, 4);

		@m_effectTransform = Resources::GetEffect(GetParamString(unit, params, "transform-fx", false));
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		ActorMovement::Initialize(unit, behavior);

		@m_vampire = cast<BossVampire>(behavior);

		m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);

		if (Network::IsServer() && g_lichNodes.length() > 0)
			SetTargetNode(FindNewNode(), 0);
	}

	SValue@ Save() override
	{
		SValueBuilder builder;
		builder.PushDictionary();

		auto wsTarget = WorldScript::GetWorldScript(g_scene, m_nodeTarget);
		if (wsTarget !is null)
			builder.PushInteger("node-target", wsTarget.GetUnit().GetId());

		auto wsLastVisited = WorldScript::GetWorldScript(g_scene, m_nodeLastVisited);
		if (wsLastVisited !is null)
			builder.PushInteger("node-last-visited", wsLastVisited.GetUnit().GetId());

		builder.PushInteger("node-wait-time", m_nodeWaitTimeC);
		builder.PushInteger("center-count", m_centerCountC);

		builder.PushBoolean("is-transformed", m_isTransformed);

		builder.PopDictionary();
		return builder.Build();
	}

	void Load(SValue@ sval) override
	{
		m_nodeWaitTimeC = GetParamInt(UnitPtr(), sval, "node-wait-time", false, m_nodeWaitTimeC);
		m_centerCountC = GetParamInt(UnitPtr(), sval, "center-count", false, m_centerCountC);

		m_isTransformed = GetParamBool(UnitPtr(), sval, "is-transformed", false, m_isTransformed);
	}

	void PostLoad(SValue@ sval) override
	{
		UnitPtr unitTarget = g_scene.GetUnit(GetParamInt(UnitPtr(), sval, "node-target", false));
		@m_nodeTarget = cast<WorldScript::BossLichNode>(unitTarget.GetScriptBehavior());

		UnitPtr unitLastVisited = g_scene.GetUnit(GetParamInt(UnitPtr(), sval, "node-target", false));
		@m_nodeLastVisited = cast<WorldScript::BossLichNode>(unitLastVisited.GetScriptBehavior());
	}

	WorldScript::BossLichNode@ FindNewNode()
	{
		if (!Network::IsServer())
		{
			PrintError("Clients can't find new BossLichNode!");
			return null;
		}

		if (m_vampire.m_roamingC <= 0 && ++m_centerCountC >= m_centerCount)
		{
			m_centerCountC = 0;
			return g_vampireCenterNode;
		}

		if (m_nodeTarget !is null)
		{
			WorldScript::BossLichNode@ newTarget;
			int picks = 0;
			do {
				@newTarget = m_nodeTarget.PickNextNode();
			} while (newTarget is m_nodeLastVisited || ++picks > 3);
			return newTarget;
		}

		return g_lichNodes[randi(g_lichNodes.length())];
	}

	void SetTargetNode(WorldScript::BossLichNode@ node, int waitTime = -1)
	{
		@m_nodeLastVisited = m_nodeTarget;
		@m_nodeTarget = node;

		if (node is g_vampireCenterNode)
			g_flags.Delete("thrall_res");

		if (waitTime == -1)
			m_nodeWaitTimeC = m_nodeWaitTime + randi(m_nodeWaitTimeRandom);
		else
			m_nodeWaitTimeC = waitTime;

		if (Network::IsServer())
		{
			auto script = WorldScript::GetWorldScript(g_scene, node);
			(Network::Message("UnitMovementBossVampireTarget") << m_unit << script.GetUnit() << m_nodeWaitTimeC).SendToAll();
		}
	}

	void NetOnNodeArrived()
	{
		float dir = m_dir;
		if (m_behavior.m_target !is null)
		{
			vec2 vdir = normalize(xy(m_behavior.m_target.m_unit.GetPosition() - m_behavior.m_unit.GetPosition()));
			dir = atan(vdir.y, vdir.x);
		}
		m_unit.SetUnitScene(m_idleAnim.GetSceneName(dir), false);
		m_unit.GetPhysicsBody().SetLinearVelocity(vec2());

		m_vampire.NetOnNodeArrived();
	}

	void OnNodeArrived()
	{
		(Network::Message("VampireNodeArrived") << m_unit).SendToAll();

		NetOnNodeArrived();

		m_vampire.OnNodeArrived();

		if (m_vampire.m_roamingC <= 0)
		{
			if (m_nodeTarget is g_vampireCenterNode)
				g_flags.Set("vampire_middle", FlagState::Level);
			else
				g_flags.Delete("vampire_middle");
		}

		auto ws = WorldScript::GetWorldScript(g_scene, m_nodeTarget);
		if (ws !is null)
			ws.Execute();

		SetTargetNode(FindNewNode());
	}

	void DoCasting(int dt)
	{
		if (m_behavior.m_target is null)
			return;

		// vec3 posTarget = m_behavior.m_target.m_unit.GetPosition();
		// vec3 posMe = m_unit.GetPosition();

		if (m_isTransformed)
		{
			PlayEffect(m_effectTransform, m_unit.GetPosition());
			m_isTransformed = false;
		}

		m_unit.GetPhysicsBody().SetStatic(true);
		m_behavior.m_frozen = false;
	}

	void DoWalkPaths(int dt)
	{
		auto body = m_unit.GetPhysicsBody();

		if (length(body.GetLinearVelocity()) > 0.5f)
			m_unit.SetUnitScene(m_walkAnim.GetSceneName(m_dir), false);
		else
			m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);

		if (!m_isTransformed)
		{
			PlayEffect(m_effectTransform, m_unit.GetPosition());
			m_isTransformed = true;
		}

		body.SetStatic(false);
		m_behavior.m_frozen = true;

		if (Network::IsServer())
		{
			if (m_nodeTarget is null)
				SetTargetNode(FindNewNode());
			else
			{
				float distance = dist(m_unit.GetPosition(), m_nodeTarget.Position);

				float moveDot = dot(normalize(m_nodeTarget.Position - m_unit.GetPosition()), vec3(cos(m_dir), sin(m_dir), 0));
				if (distance < 5.0f || (distance < 32.0f && moveDot < 0.0f))
					OnNodeArrived();
			}
		}

		if (m_nodeTarget !is null)
		{
			vec2 dir = xy(normalize(m_nodeTarget.Position - m_unit.GetPosition()));

			if (m_vampire.m_roamingC > 0)
				dir *= m_speedRoam;
			else
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

		if (m_nodeWaitTimeC > 0)
			m_nodeWaitTimeC -= dt;

		if ((isCasting || m_nodeWaitTimeC > 0) && m_vampire.m_roamingC <= 0)
			DoCasting(dt);
		else
			DoWalkPaths(dt);
	}
}
