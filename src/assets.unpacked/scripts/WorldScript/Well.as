namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;384;224;32;32"]
	class Well : IUsable
	{
		bool Enabled;
		vec3 Position;

		[Editable]
		array<CollisionArea@>@ Areas;
	
		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;
		
		[Editable]
		SoundEvent@ Sound;
	
		SoundInstance@ m_sndInstance;
		bool m_used = false;
	

		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
			}
			
			if (Sound !is null)
			{
				@m_sndInstance = Sound.PlayTracked(Position);
				m_sndInstance.SetLooped(true);
				m_sndInstance.SetPaused(false);
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

		bool HasInfiniteUses()
		{
			return Fountain::HasEffect("infinite_wells");
		}

		bool CanUse(PlayerBase@ player)
		{
			if (!Enabled)
				return false;

			if (!HasInfiniteUses())
			{
				if (m_used && player.m_record.local)
					return false;
			}
				
			if (cast<PlayerHusk>(player) !is null)
				return true;

			auto record = player.m_record;
			if (record.potionChargesUsed == 0 && record.hp >= 1.0f && record.mana >= 1.0f)
				return false;
		
			return true;
		}
		
		void Use(PlayerBase@ player)
		{
			if (!HasInfiniteUses())
			{
				if (UseScene != "")
				{
					auto units = Unit.FetchAll();
					for (uint i = 0; i < units.length(); i++)
						units[i].SetUnitScene(UseScene, true);
				}

				if (m_sndInstance !is null)
				{
					m_sndInstance.Stop();
					@m_sndInstance = null;
				}
			}
		
			auto record = player.m_record;
			record.RefillPotionCharges();
			record.hp = 1.0f;
			record.mana = 1.0f;

			AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".hud.potionrefill"), player.m_unit.GetPosition());

			if (!m_used)
				Stats::Add("well-used", 1, record);

			m_used = true;
		}
		
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
		
		UsableIcon GetIcon(Player@ player)
		{
			if (!CanUse(player))
				return Cross;

			return Generic;
		}

		int UsePriority(IUsable@ other) { return 0; }
		
		void NetUse(PlayerHusk@ player) { }
	}
}
