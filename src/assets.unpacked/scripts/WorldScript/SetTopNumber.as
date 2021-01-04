namespace WorldScript
{
	[WorldScript color="30 210 105" icon="system/icons.png;128;288;32;32"]
	class SetTopNumber
	{
		[Editable]
		string ID;

		[Editable]
		int Number;

		SValue@ ServerExecute()
		{
			auto hud = GetHUD();
			if (hud is null)
				return null;

			hud.SetTopNumberIcon(ID, Number);
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			ServerExecute();
		}
	}
}
