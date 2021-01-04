namespace WorldScript
{
	[WorldScript color="200 150 100" icon="system/icons.png;416;384;32;32"]
	class GiveCharacterTitle
	{
		[Editable]
		UnitFeed Targets;

		[Editable]
		int TitleIndex;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
%if !HARDCORE
			auto units = Targets.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto player = cast<PlayerBase>(units[i].GetScriptBehavior());
				if (player !is null)
					player.m_record.GiveTitle(TitleIndex);
			}
%endif
		}
	}
}
