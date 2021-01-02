class SurvivalWaveProgress
{
	WorldScript::SurvivalWave@ m_currWaveElement;
	int m_subWave;
	int m_subWaveDelay;
	bool m_finishedSubWaves;
	bool m_finished;

	SurvivalWaveProgress(WorldScript::SurvivalWave@ wave)
	{
		@m_currWaveElement = wave;
		m_subWave = 0;
		m_subWaveDelay = 0;
		m_finishedSubWaves = false;
		m_finished = false;
	}

	SurvivalWaveProgress(SValue@ save)
	{
		int unitElementId = GetParamInt(UnitPtr(), save, "element");
		@m_currWaveElement = cast<WorldScript::SurvivalWave>(g_scene.GetUnit(unitElementId).GetScriptBehavior());

		m_subWave = GetParamInt(UnitPtr(), save, "sub-wave");
		m_subWaveDelay = GetParamInt(UnitPtr(), save, "sub-wave-delay");
		m_finishedSubWaves = GetParamBool(UnitPtr(), save, "finished-sub-waves");;
		m_finished = GetParamBool(UnitPtr(), save, "finished");
	}

	void Save(SValueBuilder& builder)
	{
		UnitPtr unitElement = WorldScript::GetWorldScript(g_scene, m_currWaveElement).GetUnit();
		builder.PushInteger("element", unitElement.GetId());

		builder.PushInteger("sub-wave", m_subWave);
		builder.PushInteger("sub-wave-delay", m_subWaveDelay);
		builder.PushBoolean("finished-sub-waves", m_finishedSubWaves);
		builder.PushBoolean("finished", m_finished);
	}

	bool ExecuteFeed(array<UnitPtr>@ arrExec)
	{
		if (arrExec is null || arrExec.length() <= 0)
			return false;

		for (uint i = 0; i < arrExec.length(); i++)
			WorldScript::GetWorldScript(g_scene, arrExec[i].GetScriptBehavior()).Execute();

		return true;
	}

	void Update(int dt)
	{
		if (m_finished || !Network::IsServer())
			return;

		bool allEnemiesDead = true;

		if (m_finishedSubWaves || !m_currWaveElement.SubWaveWait)
		{
			auto enemies = g_scene.FetchAllActorsWithOtherTeam(g_team_player);
			for (uint i = 0; i < enemies.length(); i++)
			{
				Actor@ a = cast<Actor>(enemies[i].GetScriptBehavior());
				if (a.m_countsAsKill)
				{
					allEnemiesDead = false;
					break;
				}
			}
		}

		if (m_finishedSubWaves)
		{
			if (allEnemiesDead)
			{
				ExecuteFeed(m_currWaveElement.OnFinished.FetchAll());
				m_finished = true;
			}
		}
		else
		{
			m_subWaveDelay -= dt;

			int timeInSubWave = m_currWaveElement.SubWaveDelay - m_subWaveDelay;
			if (m_subWave == 0 || timeInSubWave < m_currWaveElement.SubWaveMinimumDelay)
				allEnemiesDead = false;

			bool earlyFinish = (allEnemiesDead && !m_currWaveElement.SubWaveWait);

			if (earlyFinish)
				ExecuteFeed(m_currWaveElement.OnSubWaveEarlyFinish.FetchAll());

			if (earlyFinish || m_subWaveDelay <= 0)
			{
				m_subWaveDelay = m_currWaveElement.SubWaveDelay;

				array<UnitPtr>@ toExec = null;
				switch(m_subWave)
				{
				case 0: @toExec = m_currWaveElement.SubWave0.FetchAll(); break;
				case 1: @toExec = m_currWaveElement.SubWave1.FetchAll(); break;
				case 2: @toExec = m_currWaveElement.SubWave2.FetchAll(); break;
				case 3: @toExec = m_currWaveElement.SubWave3.FetchAll(); break;
				case 4: @toExec = m_currWaveElement.SubWave4.FetchAll(); break;
				case 5: @toExec = m_currWaveElement.SubWave5.FetchAll(); break;
				case 6: @toExec = m_currWaveElement.SubWave6.FetchAll(); break;
				case 7: @toExec = m_currWaveElement.SubWave7.FetchAll(); break;
				case 8: @toExec = m_currWaveElement.SubWave8.FetchAll(); break;
				case 9: @toExec = m_currWaveElement.SubWave9.FetchAll(); break;
				case 10: @toExec = m_currWaveElement.SubWave10.FetchAll(); break;
				case 11: @toExec = m_currWaveElement.SubWave11.FetchAll(); break;
				case 12: @toExec = m_currWaveElement.SubWave12.FetchAll(); break;
				case 13: @toExec = m_currWaveElement.SubWave13.FetchAll(); break;
				case 14: @toExec = m_currWaveElement.SubWave14.FetchAll(); break;
				case 15: @toExec = m_currWaveElement.SubWave15.FetchAll(); break;
				}

				if (ExecuteFeed(toExec))
					m_subWave++;
				else
					m_finishedSubWaves = true;
			}
		}
	}
}
