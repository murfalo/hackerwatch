namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;192;352;32;32"]
	class GlobalEvent
	{
		[Editable]
		string EventName;

		SValue@ ServerExecute()
		{
			TriggerGlobalEvent(EventName);
			return null;
		}
	}

	void TriggerGlobalEvent(const string &in name)
	{
		if (!Network::IsServer())
			return;

		auto res = g_scene.FetchAllWorldScripts("GlobalEventTrigger");
		for (uint i = 0; i < res.length(); i++)
		{
			auto script = res[i];
			if (!script.IsEnabled())
				continue;

			auto trigger = cast<GlobalEventTrigger>(script.GetUnit().GetScriptBehavior());
			if (trigger is null)
				continue;

			if (trigger.EventName != name)
				continue;
				
			if (randf() > trigger.ChanceToExecute)
				continue;

			script.Execute();
		}
	}
}
