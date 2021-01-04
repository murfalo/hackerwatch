namespace WorldScript
{
	[WorldScript color="100 255 100" icon="system/icons.png;96;32;32;32"]
	class LevelStart
	{
		vec3 Position;
		bool Enabled;

		[Editable]
		string StartID;

		void Initialize()
		{
			m_levelStarts.insertLast(this);
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
