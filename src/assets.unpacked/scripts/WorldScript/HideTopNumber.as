namespace WorldScript
{
	[WorldScript color="30 210 105" icon="system/icons.png;288;32;32;32"]
	class HideTopNumber
	{
		[Editable]
		string ID;

		SValue@ ServerExecute()
		{
			auto hud = GetHUD();
			if (hud is null)
				return null;

			hud.HideTopNumberIcon(ID);
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			ServerExecute();
		}
	}
}
