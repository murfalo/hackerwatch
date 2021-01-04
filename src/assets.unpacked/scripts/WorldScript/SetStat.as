enum SetStatActionType
{
	None = 0,

	Add = 1,
	Max = 2,
}

namespace WorldScript
{
	[WorldScript color="255 227 71" icon="system/icons.png;224;352;32;32"]
	class SetStat
	{
		[Editable type=enum default=0]
		SetStatActionType ActionType;

		[Editable]
		string Name;

		[Editable]
		int ValueInt;
		
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
				case SetStatActionType::Add: Stats::Add(Name, ValueInt, GetLocalPlayerRecord()); break;
				case SetStatActionType::Max: Stats::Max(Name, ValueInt, GetLocalPlayerRecord()); break;
			}
			
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}