namespace EnvironmentSoundSystem
{
	SoundEvent@ g_reverb;
	SoundInstance@ g_reverbI;


	void Initialize()
	{
		//@g_reverb = Resources::GetSoundEvent("event:/env/reverb");
	}
	
	void SetEnvironment(float reverbFadeTime)
	{
		if (g_reverbI is null)
		{
			@g_reverbI = g_reverb.PlayTracked();
			g_reverbI.SetParameter("ReverbTime", reverbFadeTime);
			g_reverbI.SetPaused(false);	
		}
		else
			g_reverbI.SetParameter("ReverbTime", reverbFadeTime);
	}
	
	void ClearEnvironment()
	{
		if (g_reverbI !is null)
			g_reverbI.Stop();
			
		@g_reverbI = null;
	}
}