namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;0;128;32;32"]
	class PlaySound
	{
		vec3 Position;
	
		[Editable]
		SoundEvent@ Sound;
		
		[Editable default=false]
		bool Looping;

		[Editable]
		UnitFeed PlayerTarget;
		
		SoundInstance@ sndInstance;
		
		
		SValue@ ServerExecute()
		{
			if (Sound is null)
				return null;

			UnitPtr unitPlayerTarget = PlayerTarget.FetchFirst();
			if (unitPlayerTarget.IsValid())
			{
				if (cast<Player>(unitPlayerTarget.GetScriptBehavior()) is null)
					return null;
			}
		
			if (Looping && sndInstance !is null)
			{
				sndInstance.Stop();
				@sndInstance = null;
			}
		
			@sndInstance = Sound.PlayTracked(Position);
		
			if (Looping)
				sndInstance.SetLooped(true);
				
			sndInstance.SetPaused(false);
			
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}