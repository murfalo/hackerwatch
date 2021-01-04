namespace Upgrades
{
	class UpgradeShop : Shop
	{
		array<Upgrade@> m_upgrades;

		UpgradeShop(SValue& params)
		{
			super(params);

			auto arrUpgrades = GetParamArray(UnitPtr(), params, "upgrades", false);
			if (arrUpgrades !is null)
			{
				for (uint i = 0; i < arrUpgrades.length(); i++)
				{
					auto upgrData = cast<SValue>(arrUpgrades[i]);
					string upgrClassName = GetParamString(UnitPtr(), upgrData, "class");

					auto upgr = cast<Upgrades::Upgrade>(InstantiateClass(upgrClassName, upgrData));
					if (upgr is null)
					{
						PrintError("Class \"" + upgrClassName + "\" is not of type Upgrades::Upgrade");
						continue;
					}

					m_upgrades.insertLast(upgr);
				}
			}
		}

		ShopIterator@ Iterate(int shopLevel, PlayerRecord@ record) override
		{
			return UpgradeShopIterator(this, shopLevel, record);
		}
	}

	class UpgradeShopIterator : ShopIterator
	{
		int m_index = -1;

		UpgradeShopIterator(Shop@ shop, int level, PlayerRecord@ record)
		{
			super(shop, level, record);
			Next();
		}

		bool AtEnd() override
		{
			return m_index >= int(cast<UpgradeShop>(m_shop).m_upgrades.length());
		}

		Upgrade@ Current() override
		{
			return cast<UpgradeShop>(m_shop).m_upgrades[m_index];
		}

		void Next() override
		{
			while (true)
			{
				m_index++;

				if (AtEnd())
					break;

				auto upgrade = Current();
				auto step = upgrade.GetNextStep(m_record);

				if (step is null)
					break;

				if (step.m_restrictShopLevelMax != -1)
				{
					if (m_level > step.m_restrictShopLevelMax)
						continue;
				}

				if (m_level >= step.m_restrictShopLevelMin)
					break;
			}
		}
	}
}
