namespace WorldScript
{
	[WorldScript color="30 210 105" icon="system/icons.png;288;32;32;32"]
	class ClearTopNumbers
	{
		SValue@ ServerExecute()
		{
			auto hud = GetHUD();
			if (hud is null)
				return null;

			hud.ClearTopNumberIcons();
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			ServerExecute();
		}
	}
}
