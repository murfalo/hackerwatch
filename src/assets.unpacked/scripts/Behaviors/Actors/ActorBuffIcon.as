class ActorBuffIcon
{
	Actor@ m_actor;
	UnitProducer@ m_prod;
	AttachedActorUnit@ m_attached;
	int m_refCount;

	ActorBuffIcon(UnitProducer@ prod, Actor@ actor)
	{
		@m_prod = prod;
		@m_actor = actor;

		UnitProducer@ attProd = Resources::GetUnitProducer("system/attached_actor.unit");
		UnitPtr attUnit = attProd.Produce(g_scene, actor.m_unit.GetPosition());
		@m_attached = cast<AttachedActorUnit>(attUnit.GetScriptBehavior());

		actor.m_attachedUnits.insertLast(attUnit);

		m_refCount = 1;
	}

	void AddRef()
	{
		m_refCount++;
	}

	void Release()
	{
		m_refCount--;
		if (m_refCount <= 0)
			m_attached.Destroy();
	}

	void Refresh(int duration)
	{
		m_attached.m_duration = duration;
	}
}
