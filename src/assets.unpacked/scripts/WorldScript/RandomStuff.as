namespace WorldScript
{
	enum RandomStuffEffect
	{
		None,
		GiveItem,
		GiveOre,
		GiveGold,
		GiveExperience,
		GiveKeys,
		DepositGold,
		ClearCurses
	}


	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class RandomStuff : IUsable, IWidgetHoster
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;
		
		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;

		
		RandomStuffEffect m_activeEffect = RandomStuffEffect::None;
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
		
		void OnFunc(Widget@ sender, string name) override
		{
			int act = 0;
		
			auto gm = cast<Campaign>(g_gameMode);
			if (gm !is null)
			{
				ivec3 level = CalcLevel(gm.m_levelCount);
				act = level.x;
			}
			
			if (g_flags.IsSet("dlc_pop"))
				act += 2;
		
			if (name == "q yes" || name == "q")
			{
				PauseGame(false, true);

				m_used = true;
				if (UseScene != "")
				{
					auto units = Unit.FetchAll();
					for (uint i = 0; i < units.length(); i++)
						units[i].SetUnitScene(UseScene, true);
				}
				
				Platform::Service.UnlockAchievement("imp");
				
				auto player = GetLocalPlayer();
			
				switch(m_activeEffect)
				{
				case RandomStuffEffect::GiveItem:
				{
					auto itemQual = ActorItemQuality::None;
				
					switch(act)
					{
					case 0: itemQual = RandomLootManager::RollQuality({ 0, 60, 30, 10, 0, 0 }); break;
					case 1: itemQual = RandomLootManager::RollQuality({ 0, 50, 30, 15, 4, 0 }); break;
					case 2: itemQual = RandomLootManager::RollQuality({ 0, 40, 35, 20, 4, 1 }); break;
					case 3: itemQual = RandomLootManager::RollQuality({ 0, 15, 42, 35, 6, 2 }); break;
					case 4: itemQual = RandomLootManager::RollQuality({ 0, 0, 40, 46, 10, 4 }); break;
					case 5: itemQual = RandomLootManager::RollQuality({ 0, 0, 30, 50, 14, 6 }); break;
					}
					
					if (itemQual == ActorItemQuality::None)
						itemQual = ActorItemQuality::Common;
				
					GiveItemImpl(g_items.TakeRandomItem(itemQual), player, true);
					break;
				}	
				case RandomStuffEffect::GiveOre:
				{
					GiveOreImpl(int(pow(1.55f, act) * 3 + 0.5f) + int(g_ngp * 2.0f + 0.5f), player);
					break;
				}

				case RandomStuffEffect::GiveGold:
				{
					GiveGoldImpl(int(pow(2, act)) * 1250 + int(g_ngp * 5000.0f), player);
					break;
				}

				case RandomStuffEffect::GiveExperience:
				{
					int xp = (player.m_record.LevelExperience(player.m_record.level) - player.m_record.LevelExperience(player.m_record.level - 1)) / 3;
					auto modifiers = player.m_record.GetModifiers();
					float xpMul = modifiers.ExpMul(player, null);
					xpMul += modifiers.ExpMulAdd(player, null);
					player.m_record.GiveExperience(int(xp * xpMul));
					break;
				}

				case RandomStuffEffect::GiveKeys:
				{
					player.m_record.keys[0]++;
					Stats::Add("key-found-" + 0, 1, player.m_record);
					(Network::Message("PlayerGiveKey") << 0 << 1).SendToAll();
					
					player.m_record.keys[1]++;
					Stats::Add("key-found-" + 1, 1, player.m_record);
					(Network::Message("PlayerGiveKey") << 1 << 1).SendToAll();
					
					player.m_record.keys[2]++;
					Stats::Add("key-found-" + 2, 1, player.m_record);
					(Network::Message("PlayerGiveKey") << 2 << 1).SendToAll();
					
					if (randi(100) < (15 * act))
					{
						player.m_record.keys[3]++;
						Stats::Add("key-found-" + 3, 1, player.m_record);
						(Network::Message("PlayerGiveKey") << 3 << 1).SendToAll();
					}
					break;
				}
				
				case RandomStuffEffect::DepositGold:
				{
					int takeGold = player.m_record.runGold;
					player.m_record.runGold = 0;
					
					Currency::GiveHome(player.m_record, takeGold);
					Stats::Add("gold-stored", takeGold, player.m_record);

					break;
				}

				case RandomStuffEffect::ClearCurses:
					player.m_record.GiveCurse(0 - player.m_record.curses);
					break;
				}
			}
			else if (name == "q no" || name == "q cancel")
				PauseGame(false, true);
		}

		void Use(PlayerBase@ player)
		{
			if (m_activeEffect == RandomStuffEffect::None)
			{
				array<RandomStuffEffect> possible = { GiveItem, GiveOre, GiveGold, GiveKeys
%if !HARDCORE
					, DepositGold 
%endif
				};
			
				if (player.m_record.CanGetExperience())
					possible.insertLast(RandomStuffEffect::GiveExperience);

				if (player.m_record.curses > 0)
					possible.insertLast(RandomStuffEffect::ClearCurses);
			
				m_activeEffect = possible[randi(possible.length())];
			}
			
			bool handled = true;
			switch(m_activeEffect)
			{
			case RandomStuffEffect::GiveItem:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.give_item"), 
					Resources::GetString(".menu.ok"), this);
				break;
			case RandomStuffEffect::GiveOre:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.give_ore"), 
					Resources::GetString(".menu.ok"), this);
				break;
			case RandomStuffEffect::GiveGold:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.give_gold"), 
					Resources::GetString(".menu.ok"), this);
				break;
			case RandomStuffEffect::GiveExperience:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.give_experience"), 
					Resources::GetString(".menu.ok"), this);
				break;
			case RandomStuffEffect::GiveKeys:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.give_keys"), 
					Resources::GetString(".menu.ok"), this);
				break;
			case RandomStuffEffect::DepositGold:
				g_gameMode.ShowDialog("q",
					Resources::GetString(".random_stuff.deposit_gold"),
					Resources::GetString(".misc.yes"),
					Resources::GetString(".misc.no"), this);
				break;
			case RandomStuffEffect::ClearCurses:
				g_gameMode.ShowDialog("q",
					Resources::GetString(".random_stuff.clear_curses"),
					Resources::GetString(".menu.ok"), this);
				break;
			default: handled = false; break;
			/*
			case RandomStuffEffect::DepositOre:
				g_gameMode.ShowDialog("q",
					Resources::GetString(".random_stuff.deposit_ore"),
					Resources::GetString(".misc.yes"),
					Resources::GetString(".misc.no"),
					this
				);
				break;
			case RandomStuffEffect::Rejuvenate:
				g_gameMode.ShowDialog("q", 
					Resources::GetString(".random_stuff.rejuvenate"), 
					Resources::GetString(".menu.ok"), this);
				break;
			*/
			}

			if (handled)
				PauseGame(true, true);
		}

		UsableIcon GetIcon(Player@ player)
		{
			if (!Enabled)
				return UsableIcon::None;
		
			if (!CanUse(player))
				return UsableIcon::Cross;

			return UsableIcon::Speech;
		}

		int UsePriority(IUsable@ other) { return 0; }
		
		SValue@ Save()
		{
			SValueBuilder sval;
			sval.PushArray();
			sval.PushBoolean(m_used);
			sval.PushInteger(int(m_activeEffect));
			sval.PopArray();
			return sval.Build();
		}
		
		void Load(SValue@ data)
		{
			if (data.GetType() == SValueType::Array)
			{
				auto arr = data.GetArray();
				m_used = arr[0].GetBoolean();
				m_activeEffect = RandomStuffEffect(arr[1].GetInteger());
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