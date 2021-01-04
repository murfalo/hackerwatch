namespace Upgrades
{
	class OreTraderUpgradeStep : UpgradeStep
	{
		int m_amountOre;
		int m_amountGold;

		OreTraderUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			m_amountOre = GetParamInt(UnitPtr(), params, "amount-ore", false, 0);
			m_amountGold = GetParamInt(UnitPtr(), params, "amount-gold", false, 0);
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			return false;
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			Currency::Give(record, m_amountGold, m_amountOre);
			return true;
		}
	}
}
