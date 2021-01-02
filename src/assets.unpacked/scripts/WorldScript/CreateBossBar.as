namespace WorldScript
{
	[WorldScript color="#ff0000" icon="system/icons.png;32;192;32;32"]
	class CreateBossBar
	{
		[Editable validation=IsActor]
		UnitFeed Actors;

		[Editable default=false]
		bool OverActor;

		[Editable default=10]
		int BarCount;

		[Editable default=-50]
		int BarOffset;

		[Editable]
		string Spriteset; // RectWidget
		[Editable]
		string SpritesetValue; // BarWidget
		[Editable]
		string SpritesetValueHi; // BarWidget
		[Editable]
		int SpriteVariation; // BarWidget

		[Editable default="#FF0000FF"]
		vec4 TextColor;

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
					if (gm !is null)
						gm.AddBossBarActor(actor, BarCount, BarOffset);
				}
				else
				{
					auto wBossBar = hud.AddBossBar(actor);
					if (wBossBar !is null)
					{
						if (Spriteset != "")
							@wBossBar.m_spriteRect = SpriteRect(Spriteset);
						if (SpritesetValue != "")
							@wBossBar.m_spriteRectValue = SpriteRect(SpritesetValue);
						if (SpritesetValueHi != "")
							@wBossBar.m_spriteRectValueHi = SpriteRect(SpritesetValueHi);
						wBossBar.m_spriteRectVariation = SpriteVariation;
						wBossBar.SetTextColor(TextColor);
					}
				}

				auto compositeActor = cast<CompositeActorBehavior>(actor);
				if (compositeActor !is null)
					compositeActor.m_hasBossBar = true;
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
