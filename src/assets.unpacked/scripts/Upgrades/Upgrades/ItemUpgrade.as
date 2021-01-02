namespace Upgrades
{
	class ItemUpgrade : SingleStepUpgrade
	{
		ActorItemQuality m_quality;

		ItemShop@ m_shop;
		ActorItem@ m_item;

		float m_costScale;

		ItemUpgrade(SValue& sval)
		{
			super(sval);

			m_costScale = GetParamFloat(UnitPtr(), sval, "cost-scale", false, 1.0f);
		}

		void Set(ItemShop@ shop, ActorItem@ item)
		{
			m_quality = item.quality;

			@m_shop = shop;
			@m_item = item;

			SValueBuilder builder;
			builder.PushDictionary();
			builder.PushString("name", item.name);
			builder.PushString("desc", item.desc);

			@m_step = ItemUpgradeStep(item, this, builder.Build(), 1);

			m_step.m_costGold = int(ceil(int(m_step.m_costGold) * m_costScale));
		}

		void Set(ItemShop@ shop)
		{
			if (m_item !is null)
				return;

			ActorItem@ item = null;
			while (true)
			{
				//print("taking a random item..");

				@item = g_items.TakeRandomItem(m_quality);

				if (item is null)
					break;

				if (item.cost == 0)
					continue;
				else if (!item.buyInTown && cast<Town>(g_gameMode) !is null)
					continue;
				else if (!item.buyInDungeon && cast<Town>(g_gameMode) is null)
					continue;
				else
					break;
			}

			if (item is null)
			{
				PrintError("Couldn't find item for quality " + int(m_quality));
				return;
			}

			Set(shop, item);
		}

		void SetApplied(PlayerRecord@ record)
		{
			m_shop.SetApplied(this, record);
		}
	}
}
