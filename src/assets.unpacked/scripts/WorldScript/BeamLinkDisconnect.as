namespace WorldScript
{
	[WorldScript color="#FFA900FF" icon="system/icons.png;0;96;32;32"]
	class BeamLinkDisconnect
	{
		[Editable validation=IsBeamLink]
		UnitFeed Link;

		bool IsBeamLink(UnitPtr unit)
		{
			return cast<BeamLink>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			auto arrUnits = Link.FetchAll();
			for (uint i = 0; i < arrUnits.length(); i++)
			{
				auto link = cast<BeamLink>(arrUnits[i].GetScriptBehavior());
				if (link !is null)
					link.ClearConnections();
			}
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
