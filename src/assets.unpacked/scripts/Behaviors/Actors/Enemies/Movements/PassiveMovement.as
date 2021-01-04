class PassiveMovement : ActorMovement
{
	AnimString@ m_idleAnim;
	
	PassiveMovement(UnitPtr unit, SValue& params)
	{
		super(unit, params);
		@m_idleAnim = AnimString(GetParamString(unit, params, "anim-idle"));
	}
	
	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior) override
	{
		ActorMovement::Initialize(unit, behavior);
		m_unit.SetUnitScene(m_idleAnim.GetSceneName(m_dir), false);
	}
	
	void Update(int dt, bool isCasting) override
	{
		if (!m_enabled)
			return;
		
		ActorMovement::Update(dt, isCasting);
			
		if (!isCasting && m_behavior.m_target !is null)
		{
			vec3 dir = m_behavior.m_target.m_unit.GetPosition() - m_unit.GetPosition();
			m_dir = atan(dir.y, dir.x);
		
			string scene = m_idleAnim.GetSceneName(m_dir);
			m_unit.SetUnitScene(scene, false);
		}
	}
}
