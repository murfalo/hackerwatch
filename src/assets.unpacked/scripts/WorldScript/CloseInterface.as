namespace WorldScript
{
	[WorldScript color="#DEC4B0" icon="system/icons.png;352;352;32;32"]
	class CloseInterface
	{
		[Editable validation=IsOpenInterface]
		UnitFeed Interface;

		[Editable]
		UnitFeed ForPlayer;

		bool IsOpenInterface(UnitPtr unit)
		{
			return cast<OpenInterface>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			UnitPtr unit = ForPlayer.FetchFirst();
			if (unit.IsValid() && cast<Player>(unit.GetScriptBehavior()) is null)
				return;

			auto unitScriptInterface = Interface.FetchFirst();
			if (!unitScriptInterface.IsValid())
				return;

			auto scriptInterface = cast<OpenInterface>(unitScriptInterface.GetScriptBehavior());
			if (scriptInterface is null)
				return;

			scriptInterface.Stop();
		}
	}
}
