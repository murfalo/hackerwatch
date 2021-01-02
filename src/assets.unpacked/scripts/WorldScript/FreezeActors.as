enum FreezeState
{
	Unfrozen,
	Frozen,
	Toggle
}

namespace WorldScript
{
	[WorldScript color="120 10 140" icon="system/icons.png;192;256;32;32"]
	class FreezeActors
	{
		[Editable validation=IsActor]
		UnitFeed Units;

		[Editable type=enum]
		FreezeState State;

		bool IsValid(UnitPtr unit)
		{
			return cast<CompositeActorBehavior>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto actor = cast<CompositeActorBehavior>(units[i].GetScriptBehavior());
				if (actor is null)
					continue;

				switch (State)
				{
					case FreezeState::Unfrozen: actor.m_frozen = false; break;
					case FreezeState::Frozen: actor.m_frozen = true; break;
					case FreezeState::Toggle: actor.m_frozen = !actor.m_frozen; break;
				}
			}
		}
	}
}
