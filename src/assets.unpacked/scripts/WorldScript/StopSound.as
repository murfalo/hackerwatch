namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;64;128;32;32"]
	class StopSound
	{
		[Editable validation=IsValid]
		UnitFeed Sounds;
		
		bool IsValid(UnitPtr unit)
		{
			return cast<PlaySound>(unit.GetScriptBehavior()) !is null;
		}
		
		SValue@ ServerExecute()
		{
			auto units = Sounds.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				PlaySound@ ps = cast<PlaySound>(units[i].GetScriptBehavior());
				if (ps !is null && ps.sndInstance !is null)
				{
					ps.sndInstance.Stop();
					@ps.sndInstance = null;
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