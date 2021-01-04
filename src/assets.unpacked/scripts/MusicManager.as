namespace MusicManager
{
	void Initialize()
	{
	}
	
	void Update(int ms)
	{
	}
	
	void Save(SValueBuilder& builder)
	{
/*
		if (g_currMusic !is null)
			builder.PushString("curr-music", g_currMusic.GetName());
*/
	}
	
	void Load(SValue@ save)
	{
/*
		auto musicData = save.GetDictionaryEntry("curr-music");
		if (musicData !is null && musicData.GetType() == SValueType::String)
		{
			auto music = Resources::GetSoundEvent(musicData.GetString());
			if (music !is null)
				Play(music);
		}
*/
	}

	void Play(SoundEvent@ music)
	{
	}

	void AddTension(float tension)
	{
	}
}