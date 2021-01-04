enum TimerTriggerState
{
	Clock = 1,
	Frequency,
	Both
}

namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;96;0;32;32"]
	class SetTimerTrigger
	{
		[Editable]
		int Value;
		
		[Editable type=enum default=1]
		TimerTriggerState Parameter;
	
		[Editable validation=IsTimerTrigger]
		UnitFeed TimerTriggers;

		bool IsTimerTrigger(UnitPtr unit)
		{
			return cast<TimerTrigger>(unit.GetScriptBehavior()) !is null;
		}
		
		SValue@ ServerExecute()
		{
			auto vars = TimerTriggers.FetchAll();
			for (uint i = 0; i < vars.length(); i++)
			{
				TimerTrigger@ var = cast<TimerTrigger>(vars[i].GetScriptBehavior());
				
				if (Parameter == TimerTriggerState::Clock)
					var.m_time = Value;
				else if (Parameter == TimerTriggerState::Frequency)
					var.Frequency = Value;
				else
				{
					var.m_time = Value;
					var.Frequency = Value;
				}
			}
			
			return null;
		}
		
		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}