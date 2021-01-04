namespace WorldScript
{
	[WorldScript color="255 0 255" icon="system/icons.png;416;160;32;32"]
	class LastEnemyKilledTrigger
	{
		bool Enabled;

		[Editable default="enemy"]
		string Team;

		int m_previous = -1;

		void Update(int dt)
		{
			if (!Enabled)
				return;

			auto actorCollection = GetActorList(HashString(Team));
			if (actorCollection is null)
			{
				m_previous = -1;
				return;
			}

			int numEnemies = 0;
			for (uint i = 0; i < actorCollection.m_arr.length(); i++)
			{
				auto actor = actorCollection.m_arr[i];
				if (actor.m_countsAsKill)// || actor.IsTargetable())
					numEnemies++;
			}

			if (numEnemies == 0 && m_previous > 0)
				WorldScript::GetWorldScript(g_scene, this).Execute();

			m_previous = numEnemies;
		}

		SValue@ Save()
		{
			SValueBuilder builder;
			builder.PushInteger(m_previous);
			return builder.Build();
		}

		void Load(SValue@ save)
		{
			if (save !is null && save.GetType() == SValueType::Integer)
				m_previous = save.GetInteger();
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
