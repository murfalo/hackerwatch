namespace WorldScript
{
	[WorldScript color="#ff00ffff" icon="system/icons.png;64;32;32;32"]
	class AddNotification
	{
		[Editable]
		string Text;

		[Editable default="#FF0000FF"]
		vec4 ColorFrom;

		[Editable default="#FFFFFFFF"]
		vec4 ColorTo;

		[Editable]
		string SubtextIcon;

		[Editable]
		string Subtext;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm is null)
				return;

			auto notif = gm.m_notifications.Add(Resources::GetString(Text), ColorFrom, ColorTo);

			if (SubtextIcon != "" || Subtext != "")
				notif.AddSubtext(SubtextIcon, Subtext);
		}
	}
}
