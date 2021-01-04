namespace WorldScript
{
	[WorldScript color="50 238 232" icon="system/icons.png;352;32;32;32"]
	class PlayAttachedEffect
	{
		[Editable]
		UnitScene@ Effect;

		[Editable]
		int Layer;

		[Editable]
		UnitFeed Objects;

		[Editable]
		int OffsetY;

		SValue@ ServerExecute()
		{
			auto units = Objects.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				//TODO: Layer
				//TODO: OffsetY
				PlayEffect(Effect, units[i]);
			}
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
