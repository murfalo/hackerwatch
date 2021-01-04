namespace WorldScript
{
	[WorldScript color="50 200 50" icon="system/icons.png;96;32;32;32"]
	class TeamLevelStart : LevelStart
	{
		[Editable default=0]
		int TeamIndex;

		void Initialize() override
		{
			m_levelStarts.insertLast(this);
		}

		SValue@ ServerExecute() override
		{
			return null;
		}
	}
}
