namespace WorldScript
{
	enum ShopAreaType
	{
		UpgradeShop,
		Fountain,
		Statues,
		Chapel,
		Skills,
		Townhall,
		Drinks,
		GeneralStore,
		ItemForge,
		DungeonStore,
		DesertStore,

		Custom
	}

	[WorldScript color="#B0C4DE" icon="system/icons.png;384;352;32;32"]
	class ShopArea : IUsable
	{
		bool Enabled;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable type=enum default=0]
		ShopAreaType Type;
		
		[Editable]
		string Category;

		[Editable default=1]
		int ShopLevel;

		[Editable]
		UnitFeed UsedUnits;

		[Editable]
		string UsedUnitScene;

		UnitSource User;

		bool m_used;

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

			auto gm = cast<Campaign>(g_gameMode);
			if (Type == ShopAreaType::UpgradeShop)
				gm.m_shopMenu.Show(this, UpgradeShopMenuContent(gm.m_shopMenu, Category), ShopLevel);
			else if (Type == ShopAreaType::Fountain)
				gm.m_shopMenu.Show(this, FountainShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Statues)
				gm.m_shopMenu.Show(this, StatuesShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Chapel)
				gm.m_shopMenu.Show(this, ChapelShopMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Skills)
			{
%if HARDCORE
				gm.m_shopMenu.Show(this, HardcoreSkillsShopMenuContent(gm.m_shopMenu), ShopLevel);
%else
				gm.m_shopMenu.Show(this, SkillsShopMenuContent(gm.m_shopMenu), ShopLevel);
%endif
			}
			else if (Type == ShopAreaType::Townhall)
				gm.m_shopMenu.Show(this, TownhallMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::Drinks)
				gm.m_shopMenu.Show(this, DrinksMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::GeneralStore)
				gm.m_shopMenu.Show(this, GeneralStoreMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::ItemForge)
				gm.m_shopMenu.Show(this, ItemForgeMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::DungeonStore)
				gm.m_shopMenu.Show(this, DungeonStoreMenuContent(gm.m_shopMenu), ShopLevel);
			else if (Type == ShopAreaType::DesertStore)
				gm.m_shopMenu.Show(this, DesertStoreMenuContent(gm.m_shopMenu), ShopLevel);

			else if (Type == ShopAreaType::Custom)
			{
				if (Category == "")
				{
					PrintError("You forgot to set Category to a class to instantiate!");
					return;
				}

				SValueBuilder builder;
				builder.PushNull();
				auto menuContent = cast<ShopMenuContent>(InstantiateClass(Category, UnitPtr(), builder.Build()));
				if (menuContent is null)
				{
					PrintError("Couldn't instantiate class \"" + Category + "\" or is not of type ShopMenuContent!");
					return;
				}

				gm.m_shopMenu.Show(this, menuContent, ShopLevel);
			}

			User.Replace(player.m_unit);

			if (Network::IsServer())
				WorldScript::GetWorldScript(g_scene, this).Execute();
		}
		
		void NetUse(PlayerHusk@ player)
		{
			if (Network::IsServer())
				WorldScript::GetWorldScript(g_scene, this).Execute();
		}

		UsableIcon GetIcon(Player@ player)
		{
			if (!CanUse(player))
				return UsableIcon::None;

			return UsableIcon::Shop;
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

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
