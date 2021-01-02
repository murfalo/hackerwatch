namespace WorldScript
{
	[WorldScript color="#ff0000" icon="system/icons.png;448;96;32;32"]
	class BossBarCheckpoint
	{
		[Editable validation=IsActor]
		UnitFeed Actors;

		[Editable]
		bool OverActor;

		[Editable]
		float Factor;

		bool IsActor(UnitPtr unit)
		{
			return cast<Actor>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			HUD@ hud = GetHUD();
			auto gm = cast<BaseGameMode>(g_gameMode);

			auto units = Actors.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				Actor@ actor = cast<Actor>(units[i].GetScriptBehavior());
				if (OverActor)
				{
					OverheadBossBar@ bar = null;

					if (gm !is null)
						@bar = gm.GetBossBarActor(actor);

					if (bar is null)
					{
						PrintError("There is no overhead boss bar found for the actor at unit " + units[i].GetId());
						continue;
					}
					bar.m_checkpoint = Factor;
				}
				else
				{
					BossBarWidget@ bar = hud.GetBossBar(actor);
					if (bar is null)
					{
						PrintError("There is no boss bar widget found for the actor at unit " + units[i].GetId());
						continue;
					}
					bar.m_checkpoint = Factor;
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
