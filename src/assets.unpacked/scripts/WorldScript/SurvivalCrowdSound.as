namespace WorldScript
{
	[WorldScript color="0 196 150" icon="system/icons.png;352;96;32;32"]
	class SurvivalCrowdSound
	{
		vec3 Position;

		SoundInstance@ m_sndI;

		void Start()
		{
			auto snd = Resources::GetSoundEvent("event:/arena/crowd");

			if (snd is null)
				return;

			@m_sndI = snd.PlayTracked(Position);
			m_sndI.SetLooped(true);
			m_sndI.SetPosition(Position);
			m_sndI.SetTimelinePosition(randi(19632));
		}

		void UpdateSound(float crowdValue)
		{
			int crowdController = int(round(crowdValue / 20.0f));
			m_sndI.SetParameter("crowd-controller", crowdController);

			if (GetVarBool("g_debug_crowd"))
				print("Crowd controller value = " + crowdController);
		}
	}
}
