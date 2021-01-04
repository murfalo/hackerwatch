namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;160;288;32;32"]
	class SetEnvironment
	{
		[Editable]
		string Environment;

		SValue@ ServerExecute()
		{
			auto env = Resources::GetEnvironment(Environment);
			if (env is null)
			{
				PrintError("Environment not found: \"" + Environment + "\"");
				return null;
			}

			g_scene.SetEnvironment(env);

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
