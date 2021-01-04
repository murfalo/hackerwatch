namespace WorldScript
{
	[WorldScript color="#FF4500" icon="system/icons.png;256;352;32;32"]
	class HideAllSpeechBubbles
	{
		[Editable]
		UnitFeed ForPlayer;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			UnitPtr unit = ForPlayer.FetchFirst();
			if (unit.IsValid() && cast<Player>(unit.GetScriptBehavior()) is null)
				return;

			GetHUD().m_speechBubbles.HideAll();
		}
	}
}
