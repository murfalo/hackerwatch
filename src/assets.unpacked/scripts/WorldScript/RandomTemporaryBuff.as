namespace WorldScript
{
	class RandomPossibleBuff
	{
		string m_msg;
		uint m_buff;

		RandomPossibleBuff(string msg, string buff)
		{
			m_msg = msg;
			m_buff = HashString(buff);
		}
	}

	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class RandomTemporaryBuff : IUsable, IWidgetHoster
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;
		
		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;

		
		bool m_used = false;
		
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
				RandomPossibleBuff(".temp_buff.armor", "items/buffs.sval:randbuff_armor"),
				RandomPossibleBuff(".temp_buff.experience", "items/buffs.sval:randbuff_experience"),
				RandomPossibleBuff(".temp_buff.damage", "items/buffs.sval:randbuff_damage"),
				RandomPossibleBuff(".temp_buff.heal", "items/buffs.sval:randbuff_heal"),
				RandomPossibleBuff(".temp_buff.mana", "items/buffs.sval:randbuff_mana"),
				RandomPossibleBuff(".temp_buff.gold", "items/buffs.sval:randbuff_gold"),
				RandomPossibleBuff(".temp_buff.attackspeed", "items/buffs.sval:randbuff_attackspeed"),
				RandomPossibleBuff(".temp_buff.luck", "items/buffs.sval:randbuff_luck"),
				RandomPossibleBuff(".temp_buff.sundering", "items/buffs.sval:randbuff_sundering")
			};

			if (!player.m_record.CanGetExperience())
				possibleBuffs.removeAt(1);

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
			
			Platform::Service.UnlockAchievement("shrine");

			int randomBuffIndex = randi(possibleBuffs.length());
			RandomPossibleBuff@ randomBuff = possibleBuffs[randomBuffIndex];

			if (randomBuff.m_msg != "")
			{
				g_gameMode.ShowDialog("a",
					Resources::GetString(randomBuff.m_msg),
					Resources::GetString(".menu.ok"),
					this);

				PauseGame(true, true);

				auto buffDef = LoadActorBuff(randomBuff.m_buff);
				if (buffDef !is null)
				{
					player.m_record.temporaryBuffs.insertLast(randomBuff.m_buff);
					player.m_record.temporaryBuffs.insertLast(buffDef.m_duration);
					player.RefreshModifiers();
				}

				Stats::Add("shrines-used", 1, player.m_record);
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