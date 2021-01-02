namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;192;352;32;32"]
	class GlobalEventRanged
	{
		vec3 Position;
	
		[Editable]
		string EventName;
		
		[Editable default=75]
		int Radius;
		
		[Editable validation=IsExecutable]
		UnitFeed OnExecutedNothing;
		
		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			if (!TriggerGlobalEvent(EventName, xy(Position), Radius))
			{
				auto toExec = OnExecutedNothing.FetchAll();
				for (uint i = 0; i < toExec.length(); i++)
					WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			}
			
			return null;
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			sb.DrawCircle(pos, Radius, vec4(0, 1, 1, 1), 25);
		}
	}

	bool TriggerGlobalEvent(const string &in name, vec2 pos, int radius)
	{
		if (!Network::IsServer())
			return false;

		bool ret = false;

		auto res = g_scene.FetchWorldScripts("GlobalEventTrigger", pos, radius);
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
			ret = true;
		}
		
		return ret;
	}
}
