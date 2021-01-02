namespace Upgrades
{
	class Shop
	{
		string m_id;
		string m_name;
		bool m_starsVisible;

		Shop(SValue& params)
		{
			m_id = GetParamString(UnitPtr(), params, "id");
			m_name = GetParamString(UnitPtr(), params, "name", false);
			m_starsVisible = GetParamBool(UnitPtr(), params, "stars-visible", false, true);
		}

		void OnOpenMenu(int shopLevel, PlayerRecord@ record)
		{
		}

		Upgrade@ FindUpgrade(string id, PlayerRecord@ record)
		{
			for (auto iter = Iterate(5, record); !iter.AtEnd(); iter.Next())
			{
				auto upgrade = iter.Current();
				if (upgrade.m_id == id)
					return upgrade;
			}
			return null;
		}

		ShopIterator@ Iterate(int shopLevel, PlayerRecord@ record)
		{
			return ShopIterator(this, shopLevel, record);
		}
	}

	class ShopIterator
	{
		Shop@ m_shop;
		int m_level;
		PlayerRecord@ m_record;

		ShopIterator(Shop@ shop, int level, PlayerRecord@ record)
		{
			@m_shop = shop;
			m_level = level;
			@m_record = record;
		}

		bool AtEnd() { return true; }
		Upgrade@ Current() { return null; }
		void Next() { }
	}

	array<Shop@> g_shops;

	Shop@ GetShop(string id)
	{
		for (uint i = 0; i < g_shops.length(); i++)
		{
			if (g_shops[i].m_id == id)
				return g_shops[i];
		}
		return null;
	}

	Upgrade@ GetShopUpgrade(string id, PlayerRecord@ record)
	{
		for (uint i = 0; i < g_shops.length(); i++)
		{
			auto upgrade = g_shops[i].FindUpgrade(id, record);
			if (upgrade !is null)
				return upgrade;
		}
		return null;
	}

	void LoadShop(SValue@ sval)
	{
		string className = GetParamString(UnitPtr(), sval, "class");

		auto newShop = cast<Shop>(InstantiateClass(className, sval));
		if (newShop is null)
		{
			PrintError("Failed to create shop class \"" + className + "\"");
			return;
		}

		g_shops.insertLast(newShop);
	}
}
