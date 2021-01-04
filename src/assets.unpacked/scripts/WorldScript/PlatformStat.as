enum StatActionType
{
	None = 0,

	UnlockAchievement = 1,

	SetStatInt = 2,
	SetStatFloat = 3,

	IncreaseStatInt = 4,
	IncreaseStatFloat = 5,

	DecreaseStatInt = 6,
	DecreaseStatFloat = 7,
}

namespace WorldScript
{
	[WorldScript color="255 227 71" icon="system/icons.png;224;352;32;32"]
	class PlatformStat
	{
		[Editable type=enum default=0]
		StatActionType ActionType;

		[Editable]
		string Name;

		[Editable]
		int ValueInt;
		
		[Editable]
		float ValueFloat;
		
		[Editable]
		UnitFeed PlayerTarget;
		

		SValue@ ServerExecute()
		{
			UnitPtr unitPlayerTarget = PlayerTarget.FetchFirst();
			if (unitPlayerTarget.IsValid())
			{
				if (cast<Player>(unitPlayerTarget.GetScriptBehavior()) is null)
					return null;
			}

			switch (ActionType)
			{
				case StatActionType::UnlockAchievement:
					Platform::Service.UnlockAchievement(Name);
					break;

				case StatActionType::SetStatInt: Platform::Service.SetStatInt(Name, ValueInt); break;
				case StatActionType::SetStatFloat: Platform::Service.SetStatFloat(Name, ValueFloat); break;

				case StatActionType::IncreaseStatInt: Platform::Service.IncreaseStatInt(Name, ValueInt); break;
				case StatActionType::IncreaseStatFloat: Platform::Service.IncreaseStatFloat(Name, ValueFloat); break;

				case StatActionType::DecreaseStatInt: Platform::Service.IncreaseStatInt(Name, -ValueInt); break;
				case StatActionType::DecreaseStatFloat: Platform::Service.IncreaseStatFloat(Name, -ValueFloat); break;
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
