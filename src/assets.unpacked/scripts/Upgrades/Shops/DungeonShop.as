namespace Upgrades
{
	class DungeonShop : ItemShop
	{
		int m_maxItems;

		DungeonShop(SValue& params)
		{
			super(params);
		}

		int GetItemCategory() override
		{
			auto gm = cast<Campaign>(g_gameMode);
			return gm.m_levelCount + 1;
		}

		float GetCostScale() override
		{
			return 1.0f + float(g_ngp) * 0.2f;
		}

		void NewItems(SValue@ sv, PlayerRecord@ record) override
		{
			ItemShop::NewItems(sv, record);

			float costScale = GetParamFloat(UnitPtr(), sv, "cost-scale", false, 1.0f);

			if (Fountain::HasEffect("more_shop_items"))
			{
				auto arrQualities = GetParamArray(UnitPtr(), sv, "qualities");
				for (int i = 0; i < 2; i++)
				{
					int index = randi(arrQualities.length());
					ActorItemQuality quality = ParseActorItemQuality(arrQualities[index].GetString());
					AddNewItem(quality, costScale, record);
				}
			}

			CheckPlumeItems(costScale, record);

			record.generalStoreItemsBought = 0;
		}

		void ReadItems(float costScale, PlayerRecord@ record) override
		{
			ItemShop::ReadItems(costScale, record);
			CheckPlumeItems(costScale, record);
		}

		void OnOpenMenu(int shopLevel, PlayerRecord@ record) override
		{
			ItemShop::OnOpenMenu(shopLevel, record);

			auto arr = GetParamArray(UnitPtr(), m_sval, "items");
			auto svalLevel = arr[shopLevel - 1];

			m_maxItems = GetParamInt(UnitPtr(), svalLevel, "max-items", false, 0);
		}

		int GetMaxItems()
		{
			return m_maxItems + g_allModifiers.DungeonStoreItemsAdd();
		}

		void CheckPlumeItems(float costScale, PlayerRecord@ record)
		{
			if (record is null)
				return;

			if (record.items.find("fancy-plume") != -1)
				AddPlumeItem("fancy-plume", 2, costScale, record);

			//if (record.tavernDrinksBought.find("the-smirking-shopkeep") != -1)
			//	AddPlumeItem("the-smirking-shopkeep", 1, costScale, record);
		}

		void AddPlumeItem(const string &in id, int num, float costScale, PlayerRecord@ record)
		{
			int currentCategory = GetItemCategory();

			auto plumePair = record.GetPlumePair(id);
			if (plumePair !is null && plumePair.m_category == currentCategory)
				return;

			record.SetPlumePair(id, currentCategory);

			print("Adding plume items for ID \"" + id + "\"");

			costScale *= GetCostScale();

			int numCommon = 0;
			int numUncommon = 0;
			int numRare = 0;
			int numEpic = 0;
			int numLegendary = 0;
			int numTotal = 0;
			for (uint i = 0; i < m_upgrades.length(); i++)
			{
				auto upgrade = cast<ItemUpgrade>(m_upgrades[i]);
				if (upgrade is null)
					continue;

				numTotal++;
				if (upgrade.m_quality == ActorItemQuality::Common) numCommon++;
				else if (upgrade.m_quality == ActorItemQuality::Uncommon) numUncommon++;
				else if (upgrade.m_quality == ActorItemQuality::Rare) numRare++;
				else if (upgrade.m_quality == ActorItemQuality::Epic) numEpic++;
				else if (upgrade.m_quality == ActorItemQuality::Legendary) numLegendary++;
			}

			for (int c = 0; c < num; c++)
			{
				ActorItemQuality extraQuality = ActorItemQuality::Common;

				int rnd = randi(numTotal);
				if (rnd < numCommon) extraQuality = ActorItemQuality::Common;
				else if ((rnd -= numCommon) < numUncommon) extraQuality = ActorItemQuality::Uncommon;
				else if ((rnd -= numUncommon) < numRare) extraQuality = ActorItemQuality::Rare;
				else if ((rnd -= numRare) < numEpic) extraQuality = ActorItemQuality::Epic;
				else if ((rnd -= numEpic) < numLegendary) extraQuality = ActorItemQuality::Legendary;

				AddNewItem(extraQuality, costScale, record);
			}
		}
	}
}
