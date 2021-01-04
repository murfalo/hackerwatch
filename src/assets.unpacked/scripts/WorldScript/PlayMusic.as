namespace WorldScript
{
	[WorldScript color="186 85 164" icon="system/icons.png;352;96;32;32"]
	class PlayMusic
	{
		[Editable]
		SoundEvent@ Music;

		[Editable]
		int Channel;

		bool m_playing = false;

		SValue@ Save()
		{
			SValueBuilder builder;
			builder.PushBoolean(m_playing);
			return builder.Build();
		}

		void Load(SValue@ save)
		{
			if (save is null)
				return;

			if (save.GetType() == SValueType::Boolean)
				m_playing = save.GetBoolean();

			if (m_playing)
				PlayAsMusic(Channel, Music);
		}

		SValue@ ServerExecute()
		{
			m_playing = true;
			PlayAsMusic(Channel, Music);

			/*
			auto sndInstance = Music.PlayTracked(vec3());
			sndInstance.SetLooped(true);
			sndInstance.SetPaused(false);
			*/

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
