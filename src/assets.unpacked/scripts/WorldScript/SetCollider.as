namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;32;480;32;32"]
	class SetCollider
	{
		[Editable type=enum default=0]
		CollideState State;

		[Editable validation=IsCollider colliders=true]
		UnitFeed Units;

		bool IsCollider(UnitPtr unit)
		{
			return unit.IsCollider();
		}

		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();

			for (uint i = 0; i < units.length(); i++)
			{
				UnitPtr unit = units[i];
				PhysicsBody@ body = unit.GetPhysicsBody();

				if (body is null)
				{
					PrintError("PhysicsBody for unit " + unit.GetDebugName() + " is null");
					continue;
				}

				switch (State)
				{
				case CollideState::Disable: body.SetActive(false, g_scene); break;
				case CollideState::Enable: body.SetActive(true, g_scene); break;
				case CollideState::Toggle: body.SetActive(!body.IsActive(), g_scene); break;
				}
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
