namespace WorldScript
{
	enum CheckScriptDistanceCompareFunc
	{
		Closer = 1,
		FurtherAway
	}

	[WorldScript color="176 196 222" icon="system/icons.png;384;128;32;32"]
	class CheckScriptDistance
	{
		vec3 Position;
		
		[Editable default="ScriptLink"]
		string ScriptType;
		
		[Editable default=""]
		string ScriptComment;
	
		[Editable type=enum default=1]
		CheckScriptDistanceCompareFunc Function;
	
		[Editable default=100]
		uint Distance;
		
		[Editable]
		bool SkipDisabled;
		
		[Editable validation=IsExecutable]
		UnitFeed OnTrue;
		
		[Editable validation=IsExecutable]
		UnitFeed OnFalse;

		
		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}
		
		SValue@ ServerExecute()
		{
			uint mind = 10000000;
			uint maxd = 0;
		
			array<WorldScript@> res;

			if (ScriptComment == "")
				res = g_scene.FetchAllWorldScripts(ScriptType);
			else
			{
				if (ScriptType == "")
					res = g_scene.FetchAllWorldScriptsWithComment(ScriptComment);
				else
					res = g_scene.FetchAllWorldScriptsWithComment(ScriptType, ScriptComment);
			}
			
			for (uint i = 0; i < res.length(); i++)
			{
				auto script = res[i];
				if (!script.IsEnabled() && SkipDisabled)
					continue;

				auto d = uint(dist(Position, script.GetUnit().GetPosition()));
				mind = min(mind, d);
				maxd = max(maxd, d);
			}
		
			bool result = false;

			switch (Function)
			{
				case CheckScriptDistanceCompareFunc::Closer: result = maxd < Distance; break;
				case CheckScriptDistanceCompareFunc::FurtherAway: result = mind > Distance; break;
			}

			array<UnitPtr>@ toExec;
			if (result)
				@toExec = OnTrue.FetchAll();
			else
				@toExec = OnFalse.FetchAll();
			
			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();

			return null;
		}
	}
}