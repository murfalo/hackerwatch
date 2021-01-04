namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class RandomBuff : IUsable
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;

		bool m_used = false;

		BloodAltar::Interface@ m_ui = null;

		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
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

		UnitPtr GetUseUnit()
		{
			return WorldScript::GetWorldScript(g_scene, this).GetUnit();
		}

		bool CanUse(PlayerBase@ player)
		{
			if (!Enabled)
				return false;

			if (m_used && player.m_record.local)
				return false;

			return true;
		}

		BloodAltar::Reward@ Accept()
		{
			m_used = true;
			if (UseScene != "")
			{
				auto units = Unit.FetchAll();
				for (uint i = 0; i < units.length(); i++)
					units[i].SetUnitScene(UseScene, true);
			}

			auto reward = BloodAltar::GetRandomReward();

			auto player = GetLocalPlayer();
			player.m_record.bloodAltarRewards.insertLast(reward.idHash);
			player.RefreshModifiers();

			Platform::Service.UnlockAchievement("blood_altar_used");

			Stats::Add("blood-altar", 1, player.m_record);
			Stats::Max("max-blood-altar", player.m_record.bloodAltarRewards.length(), player.m_record);

			(Network::Message("BloodAltarReward") << reward.idHash).SendToAll();

			return reward;
		}

		void Use(PlayerBase@ player)
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			if (m_ui is null)
				gm.m_userWindows.insertLast(@m_ui = BloodAltar::Interface(gm.m_guiBuilder, this));
			gm.ShowUserWindow(m_ui);
		}

		UsableIcon GetIcon(Player@ player)
		{
			if (!CanUse(player))
				return Cross;

			return Speech;
		}

		int UsePriority(IUsable@ other) { return 0; }

		SValue@ Save()
		{
			SValueBuilder sval;
			sval.PushBoolean(m_used);
			return sval.Build();
		}

		void Load(SValue@ data)
		{
			m_used = data.GetBoolean();
		}

		void NetUse(PlayerHusk@ player) { }
	}
}
