namespace WorldScript
{
	[WorldScript color="63 92 198" icon="system/icons.png;416;64;32;32"]
	class TeleportUnit
	{
		[Editable]
		UnitFeed Source;

		[Editable]
		UnitFeed Target;

		[Editable]
		string ScriptLinkTarget;

		vec3 GetPosition()
		{
			if (ScriptLinkTarget != "")
			{
				auto res = g_scene.FetchAllWorldScriptsWithComment("ScriptLink", ScriptLinkTarget);
				if (res.length() > 0)
				{
					int startIdx = randi(res.length());
					for (uint i = 0; i < res.length(); i++)
					{
						auto script = res[(startIdx + i) % res.length()];
						if (!script.CanExecuteNow())
							continue;

						script.Execute();
						return script.GetUnit().GetPosition();
					}
				}
			}

			return Target.FetchFirst().GetPosition();
		}

		SValue@ ServerExecute()
		{
			vec3 targetPos = GetPosition();
			auto arrSources = Source.FetchAll();

			for (uint i = 0; i < arrSources.length(); i++)
				arrSources[i].SetPosition(targetPos);

			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			ServerExecute();
		}
	}
}
