namespace WorldScript
{
	[WorldScript color="200 100 200" icon="system/icons.png;128;32;32;32"]
	class Door : IUsable
	{
		[Editable]
		array<CollisionArea@>@ UseAreas;

		[Editable]
		string KeyFlag;

		[Editable]
		UnitFeed DoorUnits;

		[Editable default="open"]
		string OpenScene;

		[Editable]
		SoundEvent@ SoundDenied;

		[Editable]
		SoundEvent@ SoundGranted;

		[Editable]
		SoundEvent@ SoundOpen;

		[Editable default=250]
		int AnnounceDelay;
		int AnnounceDelayC;

		[Editable default="gui/fonts/font_hw8.fnt"]
		string AnnounceFont;

		[Editable]
		SoundEvent@ AnnounceSound;

		void Initialize()
		{
			if (SoundDenied is null)
				@SoundDenied = Resources::GetSoundEvent("event:/misc/denied");

			if (SoundGranted is null)
				@SoundGranted = Resources::GetSoundEvent("event:/misc/granted");

			if (SoundOpen is null)
				@SoundOpen = Resources::GetSoundEvent("event:/misc/gate");

			if (AnnounceSound is null)
				@AnnounceSound = Resources::GetSoundEvent("event:/misc/world-reminder");

			for (uint i = 0; i < UseAreas.length(); i++)
			{
				UseAreas[i].AddOnEnter(this, "OnEnter");
				UseAreas[i].AddOnExit(this, "OnExit");
			}
		}

		void Announce()
		{
			HUD@ hud = GetHUD();
			if (hud is null)
				return;

			AnnounceParams params;
			params.m_text = Resources::GetString(".meta.info.need." + KeyFlag);
			params.m_font = AnnounceFont;
			params.m_anchor.y = 0.2;
			hud.Announce(params);

			PlaySound2D(AnnounceSound);
		}

		void Update(int dt)
		{
			if (AnnounceDelayC > 0)
			{
				AnnounceDelayC -= dt;
				if (AnnounceDelayC <= 0)
					Announce();
			}
		}

		Player@ GetPlayer(UnitPtr unit)
		{
			if (!unit.IsValid())
				return null;

			ref@ behavior = unit.GetScriptBehavior();

			if (behavior is null)
				return null;

			return cast<Player>(behavior);
		}

		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			Player@ plr = GetPlayer(unit);
			if (plr !is null)
				plr.AddUsable(this);
		}

		void OnExit(UnitPtr unit)
		{
			Player@ plr = GetPlayer(unit);
			if (plr !is null)
				plr.RemoveUsable(this);
		}

		SValue@ ServerExecute()
		{
			return null;
		}

		void ClientExecute(SValue@ val)
		{
		}

		UnitPtr GetUseUnit()
		{
			return WorldScript::GetWorldScript(g_scene, this).GetUnit();
		}

		bool CanUse(PlayerBase@ player)
		{
			return true;
		}

		bool AnyClosedDoors()
		{
			array<UnitPtr>@ units = DoorUnits.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				UnitScene@ currScene = units[i].GetCurrentUnitScene();
				if (currScene.GetName() != OpenScene)
					return true;
			}
			return false;
		}

		bool OpenDoor(UnitPtr user, bool force = false)
		{
			if (!AnyClosedDoors())
				return false;

			if (!force && KeyFlag != "" && !g_flags.IsSet(KeyFlag))
			{
				PlaySound3D(SoundDenied, user.GetPosition());
				if (AnnounceDelay > 0)
				{
					if (AnnounceDelayC <= 0)
						AnnounceDelayC = AnnounceDelay;
				}
				else
					Announce();
				return false;
			}

			PlaySound3D(SoundGranted, user.GetPosition());

			array<UnitPtr>@ units = DoorUnits.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				UnitPtr unitDoor = units[i];

				unitDoor.SetUnitScene(OpenScene, true);
				PlaySound3D(SoundOpen, unitDoor.GetPosition());
			}

			return true;
		}

		void Use(PlayerBase@ player)
		{
			if (!OpenDoor(player.m_unit))
				return;

			if (Network::IsServer())
				WorldScript::GetWorldScript(g_scene, this).Execute();
		}

		void NetUse(PlayerHusk@ player)
		{
			Use(player);
		}

		UsableIcon GetIcon(Player@ player)
		{
			return UsableIcon::Generic;
		}

		int UsePriority(IUsable@ other) { return 0; }
	}
}
