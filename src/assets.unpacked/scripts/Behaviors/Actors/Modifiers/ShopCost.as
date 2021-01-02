namespace Modifiers
{
	class ShopCost : Modifier
	{
		float m_mul;

		ShopCost(UnitPtr unit, SValue& params)
		{
			m_mul = GetParamFloat(unit, params, "mul");
		}

		float ShopCostMul(PlayerBase@ player, Upgrades::UpgradeStep@ step) override
		{
			return m_mul;
		}
	}
}
