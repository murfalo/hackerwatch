namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;288;352;32;32"]
	class SetUnitScene
	{
		[Editable validation=IsNotActor]
		UnitFeed Units;

		[Editable]
		string State;

		[Editable default=true]
		bool ResetTime;

		[Editable default=true]
		bool UseSceneSet;

		bool IsNotActor(UnitPtr unit)
		{
			return cast<Actor>(unit.GetScriptBehavior()) is null;
		}

		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
			if (UseSceneSet)
			{
				SValueBuilder sval;
				sval.PushArray();

				for (uint i = 0; i < units.length(); i++)
				{
					auto set = units[i].GetUnitProducer().GetSceneSet(State);
					if (set.length() == 0)
					{
						//PrintError("There are no scenes found in set '" + State + "'. Is this not a scene set?");
						set.insertLast(State);
					}
					int id = randi(set.length());
					units[i].SetUnitScene(set[id], ResetTime);
					sval.PushInteger(id);
				}

				return sval.Build();
			}
			else
			{
				for (uint i = 0; i < units.length(); i++)
					units[i].SetUnitScene(State, ResetTime);

				return null;
			}
		}

		void ClientExecute(SValue@ val)
		{
			auto units = Units.FetchAll();
			if (UseSceneSet)
			{
				auto data = val.GetArray();
				for (uint i = 0; i < units.length(); i++)
				{
					auto set = units[i].GetUnitProducer().GetSceneSet(State);
					if (set.length() == 0)
					{
						//PrintError("There are no scenes found in set '" + State + "'. Is this not a scene set?");
						set.insertLast(State);
					}
					units[i].SetUnitScene(set[data[i].GetInteger()], ResetTime);
				}
			}
			else
			{
				for (uint i = 0; i < units.length(); i++)
					units[i].SetUnitScene(State, ResetTime);
			}
		}
	}
}
