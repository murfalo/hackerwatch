namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class RandomArenaBuff : IUsable, IWidgetHoster
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;
		
		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;

		
		bool m_used = false;
		
		void OnEnabledChanged(bool enabled)
		{
			if (enabled)
				m_used = false;
		}
		
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
		
		void Use(PlayerBase@ player)
		{
			if (m_used)
				return;

			m_used = true;
			if (UseScene != "")
			{
				auto units = Unit.FetchAll();
				for (uint i = 0; i < units.length(); i++)
					units[i].SetUnitScene(UseScene, true);
			}

			array<RandomPossibleBuff@> possibleBuffs = {
				RandomPossibleBuff(".arena_buff.armor", "prefabs/coliseum/tweak/arena_buffs.sval:arena_armor"),
				RandomPossibleBuff(".arena_buff.damage", "prefabs/coliseum/tweak/arena_buffs.sval:arena_damage"),
				RandomPossibleBuff(".arena_buff.heal", "prefabs/coliseum/tweak/arena_buffs.sval:arena_heal"),
				RandomPossibleBuff(".arena_buff.mana", "prefabs/coliseum/tweak/arena_buffs.sval:arena_mana"),
				RandomPossibleBuff(".arena_buff.movespeed", "prefabs/coliseum/tweak/arena_buffs.sval:arena_move_speed"),
				RandomPossibleBuff(".arena_buff.attackspeed", "prefabs/coliseum/tweak/arena_buffs.sval:arena_attack_speed"),
				RandomPossibleBuff(".arena_buff.luck", "prefabs/coliseum/tweak/arena_buffs.sval:arena_luck"),
				RandomPossibleBuff(".arena_buff.sundering", "prefabs/coliseum/tweak/arena_buffs.sval:arena_sundering")
			};

			for (int i = possibleBuffs.length() - 1; i >= 0; i--)
			{
				for (uint j = 0; j < player.m_record.temporaryBuffs.length(); j += 2)
				{
					if (player.m_record.temporaryBuffs[j] == possibleBuffs[i].m_buff)
					{
						possibleBuffs.removeAt(i);
						break;
					}
				}
			}

			if (possibleBuffs.length() == 0)
			{
				PrintError("There were no buffs left to give!");
				return;
			}
			
			int randomBuffIndex = randi(possibleBuffs.length());
			RandomPossibleBuff@ randomBuff = possibleBuffs[randomBuffIndex];

			if (randomBuff.m_msg != "")
			{
				AddFloatingText(FloatingTextType::Pickup, Resources::GetString(randomBuff.m_msg), player.m_unit.GetPosition());

				auto buffDef = LoadActorBuff(randomBuff.m_buff);
				if (buffDef !is null)
					player.ApplyBuff(ActorBuff(player, buffDef, 1.0f, player.IsHusk()));
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "a")
				PauseGame(false, true);
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
			if (data.GetType() == SValueType::Array)
			{
				auto arr = data.GetArray();
				m_used = arr[0].GetBoolean();
			}
			else if (data.GetType() == SValueType::Boolean)
				m_used = data.GetBoolean();
		}
		
		void NetUse(PlayerHusk@ player) { }
		void DoLayout() override { }
		void Update(int dt) override { }
		void Draw(SpriteBatch& sb, int idt) override { }
		void UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override { }
	}
}