namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;192;352;32;32"]
	class GlobalEventRangedRect
	{
		vec3 Position;
	
		[Editable]
		string EventName;
		
		[Editable default=75]
		int Width;

		[Editable default=75]
		int Height;
		
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
			vec2 size = vec2(Width, Height);
			vec2 topLeft = xy(Position) - size / 2.0f;
		
			if (!TriggerGlobalEvent(EventName, vec4(topLeft.x, topLeft.y, size.x, size.y)))
			{
				auto toExec = OnExecutedNothing.FetchAll();
				for (uint i = 0; i < toExec.length(); i++)
					WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
			}
			
			return null;
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			vec2 size = vec2(Width, Height);
			vec2 topLeft = xy(Position) - size / 2.0f;
			sb.DrawRectangle(vec4(topLeft.x, topLeft.y, size.x, size.y), vec4(0, 1, 1, 1));
		}
	}

	bool TriggerGlobalEvent(const string &in name, vec4 rect)
	{
		if (!Network::IsServer())
			return false;

		bool ret = false;

		auto res = g_scene.FetchWorldScripts("GlobalEventTrigger", rect);
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
