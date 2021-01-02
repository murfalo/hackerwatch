namespace WorldScript
{
	[WorldScript color="#8FBC8B" icon="system/icons.png;320;160;32;32"]
	class PathSpeed
	{
		[Editable validation=IsFollower]
		UnitFeed Follower;

		[Editable default=-1]
		float NewSpeed;

		[Editable default=1]
		float NewSpeedMultiplier;

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

				if (NewSpeed >= 0.0f)
					follower.m_speed = NewSpeed;
				else
					follower.m_speed = follower.m_speedOrig * NewSpeedMultiplier;
			}
		}
	}
}
