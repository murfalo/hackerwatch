class TransferDamageActor : CompositeActorBehavior
{
	TransferDamageActor(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}
	
	SValue@ Save() override
	{
		SValueBuilder builder;
		builder.PushArray();

		builder.PushInteger(m_transferTarget.GetId());

		builder.PopArray();
		return builder.Build();
	}

	void Load(SValue@ data) override
	{
		// We leave this empty because we use PostLoad() to load something different than CompositeActorBehavior
	}

	void PostLoad(SValue@ data) override
	{
		auto arr = data.GetArray();
		m_transferTarget = g_scene.GetUnit(arr[0].GetInteger());
	}
}
