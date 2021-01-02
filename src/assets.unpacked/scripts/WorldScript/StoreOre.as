namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class StoreOre : IUsable, IWidgetHoster
	{
		bool Enabled;
	
		[Editable]
		array<CollisionArea@>@ Areas;
		
		[Editable]
		UnitFeed Unit;
		[Editable]
		string UseScene;
		
		
		bool m_used;
		
		void Initialize()
		{
			m_used = false;
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
			auto player = GetLocalPlayer();
			
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
			
				int takeOre = player.m_record.runOre;
				player.m_record.runOre = 0;
				Stats::Add("ores-stored", takeOre, player.m_record);
				
				AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".misc.store.ore", { { "num", takeOre } }), player.m_unit.GetPosition());

				
				int takeGold = ApplyTaxRate(Currency::GetHomeGold(), player.m_record.runGold);
				player.m_record.runGold = 0;
				Stats::Add("gold-stored", takeGold, player.m_record);

				Currency::GiveHome(player.m_record, takeGold, takeOre);
				
				AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".misc.store.gold", { { "num", takeGold } }), player.m_unit.GetPosition());

				Stats::Add("elevator-used", 1, player.m_record);
			}
			else if (name == "q no" || name == "q cancel")
				PauseGame(false, true);
		}

		void Use(PlayerBase@ player)
		{
			int oreTake = player.m_record.runOre;
			int goldTake = ApplyTaxRate(Currency::GetHomeGold(), player.m_record.runGold);
			float taxRate = (1.0f - goldTake / float(max(1, player.m_record.runGold))) * 100.0f;
			g_gameMode.ShowDialog("q",
				Resources::GetString(".misc.elevator.question", { { "ore", oreTake }, { "gold", goldTake }, { "tax", taxRate } }),
				Resources::GetString(".misc.yes"),
				Resources::GetString(".misc.no"),
				this);
			PauseGame(true, true);
		}

		UsableIcon GetIcon(Player@ player)
		{
			if (!CanUse(player))
				return Cross;

			return Generic;
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
		void DoLayout() override { }
		void Update(int dt) override { }
		void Draw(SpriteBatch& sb, int idt) override { }
		void UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override { }
	}
}
