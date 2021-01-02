namespace WorldScript
{
	[WorldScript color="200 150 100" icon="system/icons.png;416;384;32;32"]
	class UnlinkSouls
	{
		UnitFeed Reviver;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			for (uint i = 0; i < g_players.length(); i++)
			{
				if (g_players[i].peer == 255)
					continue;

				g_players[i].soulLinks.removeRange(0, g_players[i].soulLinks.length());
				g_players[i].soulLinkedBy = -1;

				auto corpse = g_players[i].corpse;
				if (corpse !is null)
				{
					auto arr = Reviver.FetchAll();
					if (arr.length() == 0)
						corpse.NetRevive(null);
					else
						corpse.NetRevive(null, true, arr[0].GetPosition());
				}

				auto actor = g_players[i].actor;
				if (actor !is null)
				{
					AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".misc.soulsunlinked"), actor.m_unit.GetPosition());
					PlayEffect("effects/players/soullink_break.effect", actor.m_unit);
				}
			}

			SValueBuilder builder;
			builder.PushString(Resources::GetString(".menu.lobby.chat.soulsunlinked"));
			SendSystemMessage("AddChat", builder.Build());
		}
	}
}
