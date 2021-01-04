namespace WorldScript
{
	[WorldScript color="#8FBC8B" icon="system/icons.png;320;160;32;32"]
	class PathPause
	{
		[Editable validation=IsFollower]
		UnitFeed Follower;

		[Editable type=enum default=0]
		CollideState State;

		bool IsFollower(UnitPtr unit)
		{
			return cast<FixedPathFollower>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto arr = Follower.FetchAll();
			for (uint i = 0; i < arr.length(); i++)
			{
				auto follower = cast<FixedPathFollower>(arr[i].GetScriptBehavior());
				if (follower is null)
					continue;

				switch (State)
				{
				case CollideState::Disable: follower.SetPaused(false); break;
				case CollideState::Enable: follower.SetPaused(true); break;
				case CollideState::Toggle: follower.SetPaused(!follower.m_paused); break;
				}
			}
		}
	}
}
