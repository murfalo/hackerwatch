namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;96;0;32;32"]
	class TimerTrigger
	{
		bool Enabled;
	
		[Editable default=1000 min=1 max=1000000]
		int Frequency;
		
		int m_time;
		
		
		
		void Initialize()
		{
			m_time = Frequency;
		}
		
		SValue@ Save()
		{
			SValueBuilder sval;
			sval.PushInteger(m_time);
			return sval.Build();
		}
		
		void Load(SValue@ data)
		{
			m_time = data.GetInteger();
		}
		
		void Update(int dt)
		{
			if (!Enabled)
				return;
		
			m_time -= dt;
			
			if (Network::IsServer())
			{
				auto script = WorldScript::GetWorldScript(g_scene, this);
				while (m_time < 0)
				{
					m_time += Frequency;
					script.Execute();
				}
			}
			else
			{
				while (m_time < 0)
					m_time += Frequency;
			}
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}