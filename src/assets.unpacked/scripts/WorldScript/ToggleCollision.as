enum CollideState
{
	Disable = 1,
	Enable,
	Toggle
}

namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;352;192;32;32"]
	class ToggleCollision
	{
		[Editable type=enum default=0]
		CollideState State;

		[Editable]
		UnitFeed Units;

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
