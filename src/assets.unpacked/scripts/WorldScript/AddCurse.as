namespace WorldScript
{
	[WorldScript color="220 180 55" icon="system/icons.png;453;2;32;32"]
	class AddCurse
	{
		[Editable default=1]
		int Amount;

		[Editable default=true]
		bool IncludeDead;
		
		[Editable validation=IsValid]
		UnitFeed Units;
		
		bool IsValid(UnitPtr unit)
		{
			return cast<PlayerBase>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			if (Units.HasConnections())
			{
				array<UnitPtr>@ units = Units.FetchAll();
				for (uint i = 0; i < units.length(); i++)
				{
					auto plr = cast<PlayerBase>(units[i].GetScriptBehavior());

					if (plr is null)
						continue;
					
					if (!IncludeDead && plr.IsDead())
						continue;

					plr.m_record.GiveCurse(Amount);
				}
			}
			else
			{
				for (uint i = 0; i < g_players.length(); i++)
				{
					if (g_players[i].peer == 255)
						continue;
					
					if (!IncludeDead && g_players[i].IsDead())
						continue;

					g_players[i].GiveCurse(Amount);
				}
			}
			
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
