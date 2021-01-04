namespace Upgrades
{
	class DesertMapUpgradeStep : UpgradeStep
	{
		array<int> m_costs;

		DesertMapUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			auto arrCosts = GetParamArray(UnitPtr(), params, "costs", false);
			for (uint i = 0; i < arrCosts.length(); i++)
				m_costs.insertLast(arrCosts[i].GetInteger());

			m_costGold = 99999;
		}

		void UpdateCost(float costScale)
		{
			auto gm = cast<Campaign>(g_gameMode);
			ivec3 lvl = CalcLevel(gm.m_levelCount);

			m_costGold = int(m_costs[lvl.y] * costScale);
		}

		float PayScale(PlayerRecord@ record) override
		{
			return record.GetModifiers().ShopCostMul(cast<PlayerBase>(record.actor), this);
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			return (record.revealDesertExit > 0);
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			record.RevealDesertExit();
			return true;
		}
	}
}
